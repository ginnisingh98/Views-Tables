--------------------------------------------------------
--  DDL for Package Body BEN_CPE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPE_INS" as
/* $Header: becperhi.pkb 120.0 2005/05/28 01:12:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpe_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_copy_entity_result_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_copy_entity_result_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ben_cpe_ins.g_copy_entity_result_id_i := p_copy_entity_result_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
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
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
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
Procedure insert_dml
  (p_rec in out nocopy ben_cpe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_cpe_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_copy_entity_results
  --
  insert into ben_copy_entity_results
      (copy_entity_result_id
      ,copy_entity_txn_id
      ,src_copy_entity_result_id
      ,result_type_cd
      ,number_of_copies
      ,mirror_entity_result_id
      ,mirror_src_entity_result_id
      ,parent_entity_result_id
      ,pd_mirror_src_entity_result_id
      ,pd_parent_entity_result_id
      ,gs_mirror_src_entity_result_id
      ,gs_parent_entity_result_id
      ,table_name
      ,table_alias
      ,table_route_id
      ,status
      ,dml_operation
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
      ,information31
      ,information32
      ,information33
      ,information34
      ,information35
      ,information36
      ,information37
      ,information38
      ,information39
      ,information40
      ,information41
      ,information42
      ,information43
      ,information44
      ,information45
      ,information46
      ,information47
      ,information48
      ,information49
      ,information50
      ,information51
      ,information52
      ,information53
      ,information54
      ,information55
      ,information56
      ,information57
      ,information58
      ,information59
      ,information60
      ,information61
      ,information62
      ,information63
      ,information64
      ,information65
      ,information66
      ,information67
      ,information68
      ,information69
      ,information70
      ,information71
      ,information72
      ,information73
      ,information74
      ,information75
      ,information76
      ,information77
      ,information78
      ,information79
      ,information80
      ,information81
      ,information82
      ,information83
      ,information84
      ,information85
      ,information86
      ,information87
      ,information88
      ,information89
      ,information90
      ,information91
      ,information92
      ,information93
      ,information94
      ,information95
      ,information96
      ,information97
      ,information98
      ,information99
      ,information100
      ,information101
      ,information102
      ,information103
      ,information104
      ,information105
      ,information106
      ,information107
      ,information108
      ,information109
      ,information110
      ,information111
      ,information112
      ,information113
      ,information114
      ,information115
      ,information116
      ,information117
      ,information118
      ,information119
      ,information120
      ,information121
      ,information122
      ,information123
      ,information124
      ,information125
      ,information126
      ,information127
      ,information128
      ,information129
      ,information130
      ,information131
      ,information132
      ,information133
      ,information134
      ,information135
      ,information136
      ,information137
      ,information138
      ,information139
      ,information140
      ,information141
      ,information142

      /* Extra Reserved Columns
      ,information143
      ,information144
      ,information145
      ,information146
      ,information147
      ,information148
      ,information149
      ,information150
      */
      ,information151
      ,information152
      ,information153

      /* Extra Reserved Columns
      ,information154
      ,information155
      ,information156
      ,information157
      ,information158
      ,information159
      */
      ,information160
      ,information161
      ,information162

      /* Extra Reserved Columns
      ,information163
      ,information164
      ,information165
      */
      ,information166
      ,information167
      ,information168
      ,information169
      ,information170

      /* Extra Reserved Columns
      ,information171
      ,information172
      */
      ,information173
      ,information174
      ,information175
      ,information176
      ,information177
      ,information178
      ,information179
      ,information180
      ,information181
      ,information182

      /* Extra Reserved Columns
      ,information183
      ,information184
      */
      ,information185
      ,information186
      ,information187
      ,information188

      /* Extra Reserved Columns
      ,information189
      */
      ,information190
      ,information191
      ,information192
      ,information193
      ,information194
      ,information195
      ,information196
      ,information197
      ,information198
      ,information199

      /* Extra Reserved Columns
      ,information200
      ,information201
      ,information202
      ,information203
      ,information204
      ,information205
      ,information206
      ,information207
      ,information208
      ,information209
      ,information210
      ,information211
      ,information212
      ,information213
      ,information214
      ,information215
      */
      ,information216
      ,information217
      ,information218
      ,information219
      ,information220
      ,information221
      ,information222
      ,information223
      ,information224
      ,information225
      ,information226
      ,information227
      ,information228
      ,information229
      ,information230
      ,information231
      ,information232
      ,information233
      ,information234
      ,information235
      ,information236
      ,information237
      ,information238
      ,information239
      ,information240
      ,information241
      ,information242
      ,information243
      ,information244
      ,information245
      ,information246
      ,information247
      ,information248
      ,information249
      ,information250
      ,information251
      ,information252
      ,information253
      ,information254
      ,information255
      ,information256
      ,information257
      ,information258
      ,information259
      ,information260
      ,information261
      ,information262
      ,information263
      ,information264
      ,information265
      ,information266
      ,information267
      ,information268
      ,information269
      ,information270
      ,information271
      ,information272
      ,information273
      ,information274
      ,information275
      ,information276
      ,information277
      ,information278
      ,information279
      ,information280
      ,information281
      ,information282
      ,information283
      ,information284
      ,information285
      ,information286
      ,information287
      ,information288
      ,information289
      ,information290
      ,information291
      ,information292
      ,information293
      ,information294
      ,information295
      ,information296
      ,information297
      ,information298
      ,information299
      ,information300
      ,information301
      ,information302
      ,information303
      ,information304

      /* Extra Reserved Columns
      ,information305
      */
      ,information306
      ,information307
      ,information308
      ,information309
      ,information310
      ,information311
      ,information312
      ,information313
      ,information314
      ,information315
      ,information316
      ,information317
      ,information318
      ,information319
      ,information320

      /* Extra Reserved Columns
      ,information321
      ,information322
      */
      ,information323
      ,datetrack_mode
      ,object_version_number
      )
  Values
    (p_rec.copy_entity_result_id
    ,p_rec.copy_entity_txn_id
    ,p_rec.src_copy_entity_result_id
    ,p_rec.result_type_cd
    ,p_rec.number_of_copies
    ,nvl(p_rec.mirror_entity_result_id,p_rec.copy_entity_result_id)
    ,p_rec.mirror_src_entity_result_id
    ,p_rec.parent_entity_result_id
    ,p_rec.pd_mirror_src_entity_result_id
    ,p_rec.pd_parent_entity_result_id
    ,p_rec.gs_mirror_src_entity_result_id
    ,p_rec.gs_parent_entity_result_id
    ,p_rec.table_name
    ,p_rec.table_alias
    ,p_rec.table_route_id
    ,p_rec.status
    ,p_rec.dml_operation
    ,p_rec.information_category
    ,p_rec.information1
    ,p_rec.information2
    ,p_rec.information3
    ,p_rec.information4
    ,p_rec.information5
    ,p_rec.information6
    ,p_rec.information7
    ,p_rec.information8
    ,p_rec.information9
    ,p_rec.information10
    ,p_rec.information11
    ,p_rec.information12
    ,p_rec.information13
    ,p_rec.information14
    ,p_rec.information15
    ,p_rec.information16
    ,p_rec.information17
    ,p_rec.information18
    ,p_rec.information19
    ,p_rec.information20
    ,p_rec.information21
    ,p_rec.information22
    ,p_rec.information23
    ,p_rec.information24
    ,p_rec.information25
    ,p_rec.information26
    ,p_rec.information27
    ,p_rec.information28
    ,p_rec.information29
    ,p_rec.information30
    ,p_rec.information31
    ,p_rec.information32
    ,p_rec.information33
    ,p_rec.information34
    ,p_rec.information35
    ,p_rec.information36
    ,p_rec.information37
    ,p_rec.information38
    ,p_rec.information39
    ,p_rec.information40
    ,p_rec.information41
    ,p_rec.information42
    ,p_rec.information43
    ,p_rec.information44
    ,p_rec.information45
    ,p_rec.information46
    ,p_rec.information47
    ,p_rec.information48
    ,p_rec.information49
    ,p_rec.information50
    ,p_rec.information51
    ,p_rec.information52
    ,p_rec.information53
    ,p_rec.information54
    ,p_rec.information55
    ,p_rec.information56
    ,p_rec.information57
    ,p_rec.information58
    ,p_rec.information59
    ,p_rec.information60
    ,p_rec.information61
    ,p_rec.information62
    ,p_rec.information63
    ,p_rec.information64
    ,p_rec.information65
    ,p_rec.information66
    ,p_rec.information67
    ,p_rec.information68
    ,p_rec.information69
    ,p_rec.information70
    ,p_rec.information71
    ,p_rec.information72
    ,p_rec.information73
    ,p_rec.information74
    ,p_rec.information75
    ,p_rec.information76
    ,p_rec.information77
    ,p_rec.information78
    ,p_rec.information79
    ,p_rec.information80
    ,p_rec.information81
    ,p_rec.information82
    ,p_rec.information83
    ,p_rec.information84
    ,p_rec.information85
    ,p_rec.information86
    ,p_rec.information87
    ,p_rec.information88
    ,p_rec.information89
    ,p_rec.information90
    ,p_rec.information91
    ,p_rec.information92
    ,p_rec.information93
    ,p_rec.information94
    ,p_rec.information95
    ,p_rec.information96
    ,p_rec.information97
    ,p_rec.information98
    ,p_rec.information99
    ,p_rec.information100
    ,p_rec.information101
    ,p_rec.information102
    ,p_rec.information103
    ,p_rec.information104
    ,p_rec.information105
    ,p_rec.information106
    ,p_rec.information107
    ,p_rec.information108
    ,p_rec.information109
    ,p_rec.information110
    ,p_rec.information111
    ,p_rec.information112
    ,p_rec.information113
    ,p_rec.information114
    ,p_rec.information115
    ,p_rec.information116
    ,p_rec.information117
    ,p_rec.information118
    ,p_rec.information119
    ,p_rec.information120
    ,p_rec.information121
    ,p_rec.information122
    ,p_rec.information123
    ,p_rec.information124
    ,p_rec.information125
    ,p_rec.information126
    ,p_rec.information127
    ,p_rec.information128
    ,p_rec.information129
    ,p_rec.information130
    ,p_rec.information131
    ,p_rec.information132
    ,p_rec.information133
    ,p_rec.information134
    ,p_rec.information135
    ,p_rec.information136
    ,p_rec.information137
    ,p_rec.information138
    ,p_rec.information139
    ,p_rec.information140
    ,p_rec.information141
    ,p_rec.information142

    /* Extra Reserved Columns
    ,p_rec.information143
    ,p_rec.information144
    ,p_rec.information145
    ,p_rec.information146
    ,p_rec.information147
    ,p_rec.information148
    ,p_rec.information149
    ,p_rec.information150
    */
    ,p_rec.information151
    ,p_rec.information152
    ,p_rec.information153

    /* Extra Reserved Columns
    ,p_rec.information154
    ,p_rec.information155
    ,p_rec.information156
    ,p_rec.information157
    ,p_rec.information158
    ,p_rec.information159
    */
    ,p_rec.information160
    ,p_rec.information161
    ,p_rec.information162

    /* Extra Reserved Columns
    ,p_rec.information163
    ,p_rec.information164
    ,p_rec.information165
    */
    ,p_rec.information166
    ,p_rec.information167
    ,p_rec.information168
    ,p_rec.information169
    ,p_rec.information170

    /* Extra Reserved Columns
    ,p_rec.information171
    ,p_rec.information172
    */
    ,p_rec.information173
    ,p_rec.information174
    ,p_rec.information175
    ,p_rec.information176
    ,p_rec.information177
    ,p_rec.information178
    ,p_rec.information179
    ,p_rec.information180
    ,p_rec.information181
    ,p_rec.information182

    /* Extra Reserved Columns
    ,p_rec.information183
    ,p_rec.information184
    */
    ,p_rec.information185
    ,p_rec.information186
    ,p_rec.information187
    ,p_rec.information188

    /* Extra Reserved Columns
    ,p_rec.information189
    */
    ,p_rec.information190
    ,p_rec.information191
    ,p_rec.information192
    ,p_rec.information193
    ,p_rec.information194
    ,p_rec.information195
    ,p_rec.information196
    ,p_rec.information197
    ,p_rec.information198
    ,p_rec.information199

    /* Extra Reserved Columns
    ,p_rec.information200
    ,p_rec.information201
    ,p_rec.information202
    ,p_rec.information203
    ,p_rec.information204
    ,p_rec.information205
    ,p_rec.information206
    ,p_rec.information207
    ,p_rec.information208
    ,p_rec.information209
    ,p_rec.information210
    ,p_rec.information211
    ,p_rec.information212
    ,p_rec.information213
    ,p_rec.information214
    ,p_rec.information215
    */
    ,p_rec.information216
    ,p_rec.information217
    ,p_rec.information218
    ,p_rec.information219
    ,p_rec.information220
    ,p_rec.information221
    ,p_rec.information222
    ,p_rec.information223
    ,p_rec.information224
    ,p_rec.information225
    ,p_rec.information226
    ,p_rec.information227
    ,p_rec.information228
    ,p_rec.information229
    ,p_rec.information230
    ,p_rec.information231
    ,p_rec.information232
    ,p_rec.information233
    ,p_rec.information234
    ,p_rec.information235
    ,p_rec.information236
    ,p_rec.information237
    ,p_rec.information238
    ,p_rec.information239
    ,p_rec.information240
    ,p_rec.information241
    ,p_rec.information242
    ,p_rec.information243
    ,p_rec.information244
    ,p_rec.information245
    ,p_rec.information246
    ,p_rec.information247
    ,p_rec.information248
    ,p_rec.information249
    ,p_rec.information250
    ,p_rec.information251
    ,p_rec.information252
    ,p_rec.information253
    ,p_rec.information254
    ,p_rec.information255
    ,p_rec.information256
    ,p_rec.information257
    ,p_rec.information258
    ,p_rec.information259
    ,p_rec.information260
    ,p_rec.information261
    ,p_rec.information262
    ,p_rec.information263
    ,p_rec.information264
    ,p_rec.information265
    ,p_rec.information266
    ,p_rec.information267
    ,p_rec.information268
    ,p_rec.information269
    ,p_rec.information270
    ,p_rec.information271
    ,p_rec.information272
    ,p_rec.information273
    ,p_rec.information274
    ,p_rec.information275
    ,p_rec.information276
    ,p_rec.information277
    ,p_rec.information278
    ,p_rec.information279
    ,p_rec.information280
    ,p_rec.information281
    ,p_rec.information282
    ,p_rec.information283
    ,p_rec.information284
    ,p_rec.information285
    ,p_rec.information286
    ,p_rec.information287
    ,p_rec.information288
    ,p_rec.information289
    ,p_rec.information290
    ,p_rec.information291
    ,p_rec.information292
    ,p_rec.information293
    ,p_rec.information294
    ,p_rec.information295
    ,p_rec.information296
    ,p_rec.information297
    ,p_rec.information298
    ,p_rec.information299
    ,p_rec.information300
    ,p_rec.information301
    ,p_rec.information302
    ,p_rec.information303
    ,p_rec.information304

    /* Extra Reserved Columns
    ,p_rec.information305
    */
    ,p_rec.information306
    ,p_rec.information307
    ,p_rec.information308
    ,p_rec.information309
    ,p_rec.information310
    ,p_rec.information311
    ,p_rec.information312
    ,p_rec.information313
    ,p_rec.information314
    ,p_rec.information315
    ,p_rec.information316
    ,p_rec.information317
    ,p_rec.information318
    ,p_rec.information319
    ,p_rec.information320

    /* Extra Reserved Columns
    ,p_rec.information321
    ,p_rec.information322
    */
    ,p_rec.information323
    ,p_rec.datetrack_mode
    ,p_rec.object_version_number
    );
  --
  ben_cpe_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_cpe_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpe_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_cpe_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpe_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_cpe_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpe_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpe_shd.g_api_dml := false;   -- Unset the api dml status
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
--   A Pl/Sql record structure.
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
Procedure pre_insert
  (p_rec  in out nocopy ben_cpe_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select ben_copy_entity_results_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ben_copy_entity_results
     where copy_entity_result_id =
             ben_cpe_ins.g_copy_entity_result_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ben_cpe_ins.g_copy_entity_result_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','ben_copy_entity_results');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.copy_entity_result_id :=
      ben_cpe_ins.g_copy_entity_result_id_i;
    ben_cpe_ins.g_copy_entity_result_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.copy_entity_result_id;
    Close C_Sel1;
  End If;
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
--   This private procedure contains any processing which is required after
--   the insert dml.
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
Procedure post_insert
  (p_effective_date               in date
  ,p_rec                          in ben_cpe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_cpe_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_copy_entity_result_id
      => p_rec.copy_entity_result_id
      ,p_copy_entity_txn_id
      => p_rec.copy_entity_txn_id
      ,p_src_copy_entity_result_id
      => p_rec.src_copy_entity_result_id
      ,p_result_type_cd
      => p_rec.result_type_cd
      ,p_number_of_copies
      => p_rec.number_of_copies
      ,p_mirror_entity_result_id
      => p_rec.mirror_entity_result_id
      ,p_mirror_src_entity_result_id
      => p_rec.mirror_src_entity_result_id
      ,p_parent_entity_result_id
      => p_rec.parent_entity_result_id
      ,p_pd_mr_src_entity_result_id
      => p_rec.pd_mirror_src_entity_result_id
      ,p_pd_parent_entity_result_id
      => p_rec.pd_parent_entity_result_id
      ,p_gs_mr_src_entity_result_id
      => p_rec.gs_mirror_src_entity_result_id
      ,p_gs_parent_entity_result_id
      => p_rec.gs_parent_entity_result_id
      ,p_table_name
      => p_rec.table_name
      ,p_table_alias
      => p_rec.table_alias
      ,p_table_route_id
      => p_rec.table_route_id
      ,p_status
      => p_rec.status
      ,p_dml_operation
      => p_rec.dml_operation
      ,p_information_category
      => p_rec.information_category
      ,p_information1
      => p_rec.information1
      ,p_information2
      => p_rec.information2
      ,p_information3
      => p_rec.information3
      ,p_information4
      => p_rec.information4
      ,p_information5
      => p_rec.information5
      ,p_information6
      => p_rec.information6
      ,p_information7
      => p_rec.information7
      ,p_information8
      => p_rec.information8
      ,p_information9
      => p_rec.information9
      ,p_information10
      => p_rec.information10
      ,p_information11
      => p_rec.information11
      ,p_information12
      => p_rec.information12
      ,p_information13
      => p_rec.information13
      ,p_information14
      => p_rec.information14
      ,p_information15
      => p_rec.information15
      ,p_information16
      => p_rec.information16
      ,p_information17
      => p_rec.information17
      ,p_information18
      => p_rec.information18
      ,p_information19
      => p_rec.information19
      ,p_information20
      => p_rec.information20
      ,p_information21
      => p_rec.information21
      ,p_information22
      => p_rec.information22
      ,p_information23
      => p_rec.information23
      ,p_information24
      => p_rec.information24
      ,p_information25
      => p_rec.information25
      ,p_information26
      => p_rec.information26
      ,p_information27
      => p_rec.information27
      ,p_information28
      => p_rec.information28
      ,p_information29
      => p_rec.information29
      ,p_information30
      => p_rec.information30
      ,p_information31
      => p_rec.information31
      ,p_information32
      => p_rec.information32
      ,p_information33
      => p_rec.information33
      ,p_information34
      => p_rec.information34
      ,p_information35
      => p_rec.information35
      ,p_information36
      => p_rec.information36
      ,p_information37
      => p_rec.information37
      ,p_information38
      => p_rec.information38
      ,p_information39
      => p_rec.information39
      ,p_information40
      => p_rec.information40
      ,p_information41
      => p_rec.information41
      ,p_information42
      => p_rec.information42
      ,p_information43
      => p_rec.information43
      ,p_information44
      => p_rec.information44
      ,p_information45
      => p_rec.information45
      ,p_information46
      => p_rec.information46
      ,p_information47
      => p_rec.information47
      ,p_information48
      => p_rec.information48
      ,p_information49
      => p_rec.information49
      ,p_information50
      => p_rec.information50
      ,p_information51
      => p_rec.information51
      ,p_information52
      => p_rec.information52
      ,p_information53
      => p_rec.information53
      ,p_information54
      => p_rec.information54
      ,p_information55
      => p_rec.information55
      ,p_information56
      => p_rec.information56
      ,p_information57
      => p_rec.information57
      ,p_information58
      => p_rec.information58
      ,p_information59
      => p_rec.information59
      ,p_information60
      => p_rec.information60
      ,p_information61
      => p_rec.information61
      ,p_information62
      => p_rec.information62
      ,p_information63
      => p_rec.information63
      ,p_information64
      => p_rec.information64
      ,p_information65
      => p_rec.information65
      ,p_information66
      => p_rec.information66
      ,p_information67
      => p_rec.information67
      ,p_information68
      => p_rec.information68
      ,p_information69
      => p_rec.information69
      ,p_information70
      => p_rec.information70
      ,p_information71
      => p_rec.information71
      ,p_information72
      => p_rec.information72
      ,p_information73
      => p_rec.information73
      ,p_information74
      => p_rec.information74
      ,p_information75
      => p_rec.information75
      ,p_information76
      => p_rec.information76
      ,p_information77
      => p_rec.information77
      ,p_information78
      => p_rec.information78
      ,p_information79
      => p_rec.information79
      ,p_information80
      => p_rec.information80
      ,p_information81
      => p_rec.information81
      ,p_information82
      => p_rec.information82
      ,p_information83
      => p_rec.information83
      ,p_information84
      => p_rec.information84
      ,p_information85
      => p_rec.information85
      ,p_information86
      => p_rec.information86
      ,p_information87
      => p_rec.information87
      ,p_information88
      => p_rec.information88
      ,p_information89
      => p_rec.information89
      ,p_information90
      => p_rec.information90
      ,p_information91
      => p_rec.information91
      ,p_information92
      => p_rec.information92
      ,p_information93
      => p_rec.information93
      ,p_information94
      => p_rec.information94
      ,p_information95
      => p_rec.information95
      ,p_information96
      => p_rec.information96
      ,p_information97
      => p_rec.information97
      ,p_information98
      => p_rec.information98
      ,p_information99
      => p_rec.information99
      ,p_information100
      => p_rec.information100
      ,p_information101
      => p_rec.information101
      ,p_information102
      => p_rec.information102
      ,p_information103
      => p_rec.information103
      ,p_information104
      => p_rec.information104
      ,p_information105
      => p_rec.information105
      ,p_information106
      => p_rec.information106
      ,p_information107
      => p_rec.information107
      ,p_information108
      => p_rec.information108
      ,p_information109
      => p_rec.information109
      ,p_information110
      => p_rec.information110
      ,p_information111
      => p_rec.information111
      ,p_information112
      => p_rec.information112
      ,p_information113
      => p_rec.information113
      ,p_information114
      => p_rec.information114
      ,p_information115
      => p_rec.information115
      ,p_information116
      => p_rec.information116
      ,p_information117
      => p_rec.information117
      ,p_information118
      => p_rec.information118
      ,p_information119
      => p_rec.information119
      ,p_information120
      => p_rec.information120
      ,p_information121
      => p_rec.information121
      ,p_information122
      => p_rec.information122
      ,p_information123
      => p_rec.information123
      ,p_information124
      => p_rec.information124
      ,p_information125
      => p_rec.information125
      ,p_information126
      => p_rec.information126
      ,p_information127
      => p_rec.information127
      ,p_information128
      => p_rec.information128
      ,p_information129
      => p_rec.information129
      ,p_information130
      => p_rec.information130
      ,p_information131
      => p_rec.information131
      ,p_information132
      => p_rec.information132
      ,p_information133
      => p_rec.information133
      ,p_information134
      => p_rec.information134
      ,p_information135
      => p_rec.information135
      ,p_information136
      => p_rec.information136
      ,p_information137
      => p_rec.information137
      ,p_information138
      => p_rec.information138
      ,p_information139
      => p_rec.information139
      ,p_information140
      => p_rec.information140
      ,p_information141
      => p_rec.information141
      ,p_information142
      => p_rec.information142

      /* Extra Reserved Columns
      ,p_information143
      => p_rec.information143
      ,p_information144
      => p_rec.information144
      ,p_information145
      => p_rec.information145
      ,p_information146
      => p_rec.information146
      ,p_information147
      => p_rec.information147
      ,p_information148
      => p_rec.information148
      ,p_information149
      => p_rec.information149
      ,p_information150
      => p_rec.information150
      */

      ,p_information151
      => p_rec.information151
      ,p_information152
      => p_rec.information152
      ,p_information153
      => p_rec.information153

      /* Extra Reserved Columns
      ,p_information154
      => p_rec.information154
      ,p_information155
      => p_rec.information155
      ,p_information156
      => p_rec.information156
      ,p_information157
      => p_rec.information157
      ,p_information158
      => p_rec.information158
      ,p_information159
      => p_rec.information159
      */

      ,p_information160
      => p_rec.information160
      ,p_information161
      => p_rec.information161
      ,p_information162
      => p_rec.information162

      /* Extra Reserved Columns
      ,p_information163
      => p_rec.information163
      ,p_information164
      => p_rec.information164
      ,p_information165
      => p_rec.information165
      */

      ,p_information166
      => p_rec.information166
      ,p_information167
      => p_rec.information167
      ,p_information168
      => p_rec.information168
      ,p_information169
      => p_rec.information169
      ,p_information170
      => p_rec.information170

      /* Extra Reserved Columns
      ,p_information171
      => p_rec.information171
      ,p_information172
      => p_rec.information172
      */

      ,p_information173
      => p_rec.information173
      ,p_information174
      => p_rec.information174
      ,p_information175
      => p_rec.information175
      ,p_information176
      => p_rec.information176
      ,p_information177
      => p_rec.information177
      ,p_information178
      => p_rec.information178
      ,p_information179
      => p_rec.information179
      ,p_information180
      => p_rec.information180
      ,p_information181
      => p_rec.information181
      ,p_information182
      => p_rec.information182

      /* Extra Reserved Columns
      ,p_information183
      => p_rec.information183
      ,p_information184
      => p_rec.information184
      */

      ,p_information185
      => p_rec.information185
      ,p_information186
      => p_rec.information186
      ,p_information187
      => p_rec.information187
      ,p_information188
      => p_rec.information188

      /* Extra Reserved Columns
      ,p_information189
      => p_rec.information189
      */
      ,p_information190
      => p_rec.information190
      ,p_information191
      => p_rec.information191
      ,p_information192
      => p_rec.information192
      ,p_information193
      => p_rec.information193
      ,p_information194
      => p_rec.information194
      ,p_information195
      => p_rec.information195
      ,p_information196
      => p_rec.information196
      ,p_information197
      => p_rec.information197
      ,p_information198
      => p_rec.information198
      ,p_information199
      => p_rec.information199

      /* Extra Reserved Columns
      ,p_information200
      => p_rec.information200
      ,p_information201
      => p_rec.information201
      ,p_information202
      => p_rec.information202
      ,p_information203
      => p_rec.information203
      ,p_information204
      => p_rec.information204
      ,p_information205
      => p_rec.information205
      ,p_information206
      => p_rec.information206
      ,p_information207
      => p_rec.information207
      ,p_information208
      => p_rec.information208
      ,p_information209
      => p_rec.information209
      ,p_information210
      => p_rec.information210
      ,p_information211
      => p_rec.information211
      ,p_information212
      => p_rec.information212
      ,p_information213
      => p_rec.information213
      ,p_information214
      => p_rec.information214
      ,p_information215
      => p_rec.information215
      */

      ,p_information216
      => p_rec.information216
      ,p_information217
      => p_rec.information217
      ,p_information218
      => p_rec.information218
      ,p_information219
      => p_rec.information219
      ,p_information220
      => p_rec.information220

      ,p_information221
      => p_rec.information221
      ,p_information222
      => p_rec.information222
      ,p_information223
      => p_rec.information223
      ,p_information224
      => p_rec.information224
      ,p_information225
      => p_rec.information225
      ,p_information226
      => p_rec.information226
      ,p_information227
      => p_rec.information227
      ,p_information228
      => p_rec.information228
      ,p_information229
      => p_rec.information229
      ,p_information230
      => p_rec.information230
      ,p_information231
      => p_rec.information231
      ,p_information232
      => p_rec.information232
      ,p_information233
      => p_rec.information233
      ,p_information234
      => p_rec.information234
      ,p_information235
      => p_rec.information235
      ,p_information236
      => p_rec.information236
      ,p_information237
      => p_rec.information237
      ,p_information238
      => p_rec.information238
      ,p_information239
      => p_rec.information239
      ,p_information240
      => p_rec.information240
      ,p_information241
      => p_rec.information241
      ,p_information242
      => p_rec.information242
      ,p_information243
      => p_rec.information243
      ,p_information244
      => p_rec.information244
      ,p_information245
      => p_rec.information245
      ,p_information246
      => p_rec.information246
      ,p_information247
      => p_rec.information247
      ,p_information248
      => p_rec.information248
      ,p_information249
      => p_rec.information249
      ,p_information250
      => p_rec.information250
      ,p_information251
      => p_rec.information251
      ,p_information252
      => p_rec.information252
      ,p_information253
      => p_rec.information253
      ,p_information254
      => p_rec.information254
      ,p_information255
      => p_rec.information255
      ,p_information256
      => p_rec.information256
      ,p_information257
      => p_rec.information257
      ,p_information258
      => p_rec.information258
      ,p_information259
      => p_rec.information259
      ,p_information260
      => p_rec.information260
      ,p_information261
      => p_rec.information261
      ,p_information262
      => p_rec.information262
      ,p_information263
      => p_rec.information263
      ,p_information264
      => p_rec.information264
      ,p_information265
      => p_rec.information265
      ,p_information266
      => p_rec.information266
      ,p_information267
      => p_rec.information267
      ,p_information268
      => p_rec.information268
      ,p_information269
      => p_rec.information269
      ,p_information270
      => p_rec.information270
      ,p_information271
      => p_rec.information271
      ,p_information272
      => p_rec.information272
      ,p_information273
      => p_rec.information273
      ,p_information274
      => p_rec.information274
      ,p_information275
      => p_rec.information275
      ,p_information276
      => p_rec.information276
      ,p_information277
      => p_rec.information277
      ,p_information278
      => p_rec.information278
      ,p_information279
      => p_rec.information279
      ,p_information280
      => p_rec.information280
      ,p_information281
      => p_rec.information281
      ,p_information282
      => p_rec.information282
      ,p_information283
      => p_rec.information283
      ,p_information284
      => p_rec.information284
      ,p_information285
      => p_rec.information285
      ,p_information286
      => p_rec.information286
      ,p_information287
      => p_rec.information287
      ,p_information288
      => p_rec.information288
      ,p_information289
      => p_rec.information289
      ,p_information290
      => p_rec.information290
      ,p_information291
      => p_rec.information291
      ,p_information292
      => p_rec.information292
      ,p_information293
      => p_rec.information293
      ,p_information294
      => p_rec.information294
      ,p_information295
      => p_rec.information295
      ,p_information296
      => p_rec.information296
      ,p_information297
      => p_rec.information297
      ,p_information298
      => p_rec.information298
      ,p_information299
      => p_rec.information299
      ,p_information300
      => p_rec.information300
      ,p_information301
      => p_rec.information301
      ,p_information302
      => p_rec.information302
      ,p_information303
      => p_rec.information303
      ,p_information304
      => p_rec.information304

      /* Extra Reserved Columns
      ,p_information305
      => p_rec.information305
      */
      ,p_information306
      => p_rec.information306
      ,p_information307
      => p_rec.information307
      ,p_information308
      => p_rec.information308
      ,p_information309
      => p_rec.information309
      ,p_information310
      => p_rec.information310
      ,p_information311
      => p_rec.information311
      ,p_information312
      => p_rec.information312
      ,p_information313
      => p_rec.information313
      ,p_information314
      => p_rec.information314
      ,p_information315
      => p_rec.information315
      ,p_information316
      => p_rec.information316
      ,p_information317
      => p_rec.information317
      ,p_information318
      => p_rec.information318
      ,p_information319
      => p_rec.information319
      ,p_information320
      => p_rec.information320

      /* Extra Reserved Columns
      ,p_information321
      => p_rec.information321
      ,p_information322
      => p_rec.information322
      */
      ,p_information323
      => p_rec.information323

      ,p_datetrack_mode
      => p_rec.datetrack_mode
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_COPY_ENTITY_RESULTS'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy ben_cpe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_cpe_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ben_cpe_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ben_cpe_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_cpe_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_copy_entity_txn_id             in     number
  ,p_result_type_cd                 in     varchar2
  ,p_src_copy_entity_result_id      in     number   default null
  ,p_number_of_copies               in     number   default null
  ,p_mirror_entity_result_id        in     number   default null
  ,p_mirror_src_entity_result_id    in     number   default null
  ,p_parent_entity_result_id        in     number   default null
  ,p_pd_mr_src_entity_result_id     in     number   default null
  ,p_pd_parent_entity_result_id     in     number   default null
  ,p_gs_mr_src_entity_result_id     in     number   default null
  ,p_gs_parent_entity_result_id     in     number   default null
  ,p_table_name                     in     varchar2 default null
  ,p_table_alias                    in     varchar2 default null
  ,p_table_route_id                 in     number   default null
  ,p_status                         in     varchar2 default null
  ,p_dml_operation                  in     varchar2 default null
  ,p_information_category           in     varchar2 default null
  ,p_information1                   in     number   default null
  ,p_information2                   in     date     default null
  ,p_information3                   in     date     default null
  ,p_information4                   in     number   default null
  ,p_information5                   in     varchar2 default null
  ,p_information6                   in     varchar2 default null
  ,p_information7                   in     varchar2 default null
  ,p_information8                   in     varchar2 default null
  ,p_information9                   in     varchar2 default null
  ,p_information10                  in     date     default null
  ,p_information11                  in     varchar2 default null
  ,p_information12                  in     varchar2 default null
  ,p_information13                  in     varchar2 default null
  ,p_information14                  in     varchar2 default null
  ,p_information15                  in     varchar2 default null
  ,p_information16                  in     varchar2 default null
  ,p_information17                  in     varchar2 default null
  ,p_information18                  in     varchar2 default null
  ,p_information19                  in     varchar2 default null
  ,p_information20                  in     varchar2 default null
  ,p_information21                  in     varchar2 default null
  ,p_information22                  in     varchar2 default null
  ,p_information23                  in     varchar2 default null
  ,p_information24                  in     varchar2 default null
  ,p_information25                  in     varchar2 default null
  ,p_information26                  in     varchar2 default null
  ,p_information27                  in     varchar2 default null
  ,p_information28                  in     varchar2 default null
  ,p_information29                  in     varchar2 default null
  ,p_information30                  in     varchar2 default null
  ,p_information31                  in     varchar2 default null
  ,p_information32                  in     varchar2 default null
  ,p_information33                  in     varchar2 default null
  ,p_information34                  in     varchar2 default null
  ,p_information35                  in     varchar2 default null
  ,p_information36                  in     varchar2 default null
  ,p_information37                  in     varchar2 default null
  ,p_information38                  in     varchar2 default null
  ,p_information39                  in     varchar2 default null
  ,p_information40                  in     varchar2 default null
  ,p_information41                  in     varchar2 default null
  ,p_information42                  in     varchar2 default null
  ,p_information43                  in     varchar2 default null
  ,p_information44                  in     varchar2 default null
  ,p_information45                  in     varchar2 default null
  ,p_information46                  in     varchar2 default null
  ,p_information47                  in     varchar2 default null
  ,p_information48                  in     varchar2 default null
  ,p_information49                  in     varchar2 default null
  ,p_information50                  in     varchar2 default null
  ,p_information51                  in     varchar2 default null
  ,p_information52                  in     varchar2 default null
  ,p_information53                  in     varchar2 default null
  ,p_information54                  in     varchar2 default null
  ,p_information55                  in     varchar2 default null
  ,p_information56                  in     varchar2 default null
  ,p_information57                  in     varchar2 default null
  ,p_information58                  in     varchar2 default null
  ,p_information59                  in     varchar2 default null
  ,p_information60                  in     varchar2 default null
  ,p_information61                  in     varchar2 default null
  ,p_information62                  in     varchar2 default null
  ,p_information63                  in     varchar2 default null
  ,p_information64                  in     varchar2 default null
  ,p_information65                  in     varchar2 default null
  ,p_information66                  in     varchar2 default null
  ,p_information67                  in     varchar2 default null
  ,p_information68                  in     varchar2 default null
  ,p_information69                  in     varchar2 default null
  ,p_information70                  in     varchar2 default null
  ,p_information71                  in     varchar2 default null
  ,p_information72                  in     varchar2 default null
  ,p_information73                  in     varchar2 default null
  ,p_information74                  in     varchar2 default null
  ,p_information75                  in     varchar2 default null
  ,p_information76                  in     varchar2 default null
  ,p_information77                  in     varchar2 default null
  ,p_information78                  in     varchar2 default null
  ,p_information79                  in     varchar2 default null
  ,p_information80                  in     varchar2 default null
  ,p_information81                  in     varchar2 default null
  ,p_information82                  in     varchar2 default null
  ,p_information83                  in     varchar2 default null
  ,p_information84                  in     varchar2 default null
  ,p_information85                  in     varchar2 default null
  ,p_information86                  in     varchar2 default null
  ,p_information87                  in     varchar2 default null
  ,p_information88                  in     varchar2 default null
  ,p_information89                  in     varchar2 default null
  ,p_information90                  in     varchar2 default null
  ,p_information91                  in     varchar2 default null
  ,p_information92                  in     varchar2 default null
  ,p_information93                  in     varchar2 default null
  ,p_information94                  in     varchar2 default null
  ,p_information95                  in     varchar2 default null
  ,p_information96                  in     varchar2 default null
  ,p_information97                  in     varchar2 default null
  ,p_information98                  in     varchar2 default null
  ,p_information99                  in     varchar2 default null
  ,p_information100                 in     varchar2 default null
  ,p_information101                 in     varchar2 default null
  ,p_information102                 in     varchar2 default null
  ,p_information103                 in     varchar2 default null
  ,p_information104                 in     varchar2 default null
  ,p_information105                 in     varchar2 default null
  ,p_information106                 in     varchar2 default null
  ,p_information107                 in     varchar2 default null
  ,p_information108                 in     varchar2 default null
  ,p_information109                 in     varchar2 default null
  ,p_information110                 in     varchar2 default null
  ,p_information111                 in     varchar2 default null
  ,p_information112                 in     varchar2 default null
  ,p_information113                 in     varchar2 default null
  ,p_information114                 in     varchar2 default null
  ,p_information115                 in     varchar2 default null
  ,p_information116                 in     varchar2 default null
  ,p_information117                 in     varchar2 default null
  ,p_information118                 in     varchar2 default null
  ,p_information119                 in     varchar2 default null
  ,p_information120                 in     varchar2 default null
  ,p_information121                 in     varchar2 default null
  ,p_information122                 in     varchar2 default null
  ,p_information123                 in     varchar2 default null
  ,p_information124                 in     varchar2 default null
  ,p_information125                 in     varchar2 default null
  ,p_information126                 in     varchar2 default null
  ,p_information127                 in     varchar2 default null
  ,p_information128                 in     varchar2 default null
  ,p_information129                 in     varchar2 default null
  ,p_information130                 in     varchar2 default null
  ,p_information131                 in     varchar2 default null
  ,p_information132                 in     varchar2 default null
  ,p_information133                 in     varchar2 default null
  ,p_information134                 in     varchar2 default null
  ,p_information135                 in     varchar2 default null
  ,p_information136                 in     varchar2 default null
  ,p_information137                 in     varchar2 default null
  ,p_information138                 in     varchar2 default null
  ,p_information139                 in     varchar2 default null
  ,p_information140                 in     varchar2 default null
  ,p_information141                 in     varchar2 default null
  ,p_information142                 in     varchar2 default null

  /* Extra Reserved Columns
  ,p_information143                 in     varchar2 default null
  ,p_information144                 in     varchar2 default null
  ,p_information145                 in     varchar2 default null
  ,p_information146                 in     varchar2 default null
  ,p_information147                 in     varchar2 default null
  ,p_information148                 in     varchar2 default null
  ,p_information149                 in     varchar2 default null
  ,p_information150                 in     varchar2 default null
  */
  ,p_information151                 in     varchar2 default null
  ,p_information152                 in     varchar2 default null
  ,p_information153                 in     varchar2 default null

  /* Extra Reserved Columns
  ,p_information154                 in     varchar2 default null
  ,p_information155                 in     varchar2 default null
  ,p_information156                 in     varchar2 default null
  ,p_information157                 in     varchar2 default null
  ,p_information158                 in     varchar2 default null
  ,p_information159                 in     varchar2 default null
  */
  ,p_information160                 in     number   default null
  ,p_information161                 in     number   default null
  ,p_information162                 in     number   default null

  /* Extra Reserved Columns
  ,p_information163                 in     number   default null
  ,p_information164                 in     number   default null
  ,p_information165                 in     number   default null
  */
  ,p_information166                 in     date     default null
  ,p_information167                 in     date     default null
  ,p_information168                 in     date     default null
  ,p_information169                 in     number   default null
  ,p_information170                 in     varchar2 default null

  /* Extra Reserved Columns
  ,p_information171                 in     varchar2 default null
  ,p_information172                 in     varchar2 default null
  */
  ,p_information173                 in     varchar2 default null
  ,p_information174                 in     number   default null
  ,p_information175                 in     varchar2 default null
  ,p_information176                 in     number   default null
  ,p_information177                 in     varchar2 default null
  ,p_information178                 in     number   default null
  ,p_information179                 in     varchar2 default null
  ,p_information180                 in     number   default null
  ,p_information181                 in     varchar2 default null
  ,p_information182                 in     varchar2 default null

  /* Extra Reserved Columns
  ,p_information183                 in     varchar2 default null
  ,p_information184                 in     varchar2 default null
  */
  ,p_information185                 in     varchar2 default null
  ,p_information186                 in     varchar2 default null
  ,p_information187                 in     varchar2 default null
  ,p_information188                 in     varchar2 default null

  /* Extra Reserved Columns
  ,p_information189                 in     varchar2 default null
   */
  ,p_information190                 in     varchar2 default null
  ,p_information191                 in     varchar2 default null
  ,p_information192                 in     varchar2 default null
  ,p_information193                 in     varchar2 default null
  ,p_information194                 in     varchar2 default null
  ,p_information195                 in     varchar2 default null
  ,p_information196                 in     varchar2 default null
  ,p_information197                 in     varchar2 default null
  ,p_information198                 in     varchar2 default null
  ,p_information199                 in     varchar2 default null

  /* Extra Reserved Columns
  ,p_information200                 in     varchar2 default null
  ,p_information201                 in     varchar2 default null
  ,p_information202                 in     varchar2 default null
  ,p_information203                 in     varchar2 default null
  ,p_information204                 in     varchar2 default null
  ,p_information205                 in     varchar2 default null
  ,p_information206                 in     varchar2 default null
  ,p_information207                 in     varchar2 default null
  ,p_information208                 in     varchar2 default null
  ,p_information209                 in     varchar2 default null
  ,p_information210                 in     varchar2 default null
  ,p_information211                 in     varchar2 default null
  ,p_information212                 in     varchar2 default null
  ,p_information213                 in     varchar2 default null
  ,p_information214                 in     varchar2 default null
  ,p_information215                 in     varchar2 default null
  */
  ,p_information216                 in     varchar2 default null
  ,p_information217                 in     varchar2 default null
  ,p_information218                 in     varchar2 default null
  ,p_information219                 in     varchar2 default null
  ,p_information220                 in     varchar2 default null
  ,p_information221                 in     number   default null
  ,p_information222                 in     number   default null
  ,p_information223                 in     number   default null
  ,p_information224                 in     number   default null
  ,p_information225                 in     number   default null
  ,p_information226                 in     number   default null
  ,p_information227                 in     number   default null
  ,p_information228                 in     number   default null
  ,p_information229                 in     number   default null
  ,p_information230                 in     number   default null
  ,p_information231                 in     number   default null
  ,p_information232                 in     number   default null
  ,p_information233                 in     number   default null
  ,p_information234                 in     number   default null
  ,p_information235                 in     number   default null
  ,p_information236                 in     number   default null
  ,p_information237                 in     number   default null
  ,p_information238                 in     number   default null
  ,p_information239                 in     number   default null
  ,p_information240                 in     number   default null
  ,p_information241                 in     number   default null
  ,p_information242                 in     number   default null
  ,p_information243                 in     number   default null
  ,p_information244                 in     number   default null
  ,p_information245                 in     number   default null
  ,p_information246                 in     number   default null
  ,p_information247                 in     number   default null
  ,p_information248                 in     number   default null
  ,p_information249                 in     number   default null
  ,p_information250                 in     number   default null
  ,p_information251                 in     number   default null
  ,p_information252                 in     number   default null
  ,p_information253                 in     number   default null
  ,p_information254                 in     number   default null
  ,p_information255                 in     number   default null
  ,p_information256                 in     number   default null
  ,p_information257                 in     number   default null
  ,p_information258                 in     number   default null
  ,p_information259                 in     number   default null
  ,p_information260                 in     number   default null
  ,p_information261                 in     number   default null
  ,p_information262                 in     number   default null
  ,p_information263                 in     number   default null
  ,p_information264                 in     number   default null
  ,p_information265                 in     number   default null
  ,p_information266                 in     number   default null
  ,p_information267                 in     number   default null
  ,p_information268                 in     number   default null
  ,p_information269                 in     number   default null
  ,p_information270                 in     number   default null
  ,p_information271                 in     number   default null
  ,p_information272                 in     number   default null
  ,p_information273                 in     number   default null
  ,p_information274                 in     number   default null
  ,p_information275                 in     number   default null
  ,p_information276                 in     number   default null
  ,p_information277                 in     number   default null
  ,p_information278                 in     number   default null
  ,p_information279                 in     number   default null
  ,p_information280                 in     number   default null
  ,p_information281                 in     number   default null
  ,p_information282                 in     number   default null
  ,p_information283                 in     number   default null
  ,p_information284                 in     number   default null
  ,p_information285                 in     number   default null
  ,p_information286                 in     number   default null
  ,p_information287                 in     number   default null
  ,p_information288                 in     number   default null
  ,p_information289                 in     number   default null
  ,p_information290                 in     number   default null
  ,p_information291                 in     number   default null
  ,p_information292                 in     number   default null
  ,p_information293                 in     number   default null
  ,p_information294                 in     number   default null
  ,p_information295                 in     number   default null
  ,p_information296                 in     number   default null
  ,p_information297                 in     number   default null
  ,p_information298                 in     number   default null
  ,p_information299                 in     number   default null
  ,p_information300                 in     number   default null
  ,p_information301                 in     number   default null
  ,p_information302                 in     number   default null
  ,p_information303                 in     number   default null
  ,p_information304                 in     number   default null

  /* Extra Reserved Columns
  ,p_information305                 in     number   default null
  */
  ,p_information306                 in     date     default null
  ,p_information307                 in     date     default null
  ,p_information308                 in     date     default null
  ,p_information309                 in     date     default null
  ,p_information310                 in     date     default null
  ,p_information311                 in     date     default null
  ,p_information312                 in     date     default null
  ,p_information313                 in     date     default null
  ,p_information314                 in     date     default null
  ,p_information315                 in     date     default null
  ,p_information316                 in     date     default null
  ,p_information317                 in     date     default null
  ,p_information318                 in     date     default null
  ,p_information319                 in     date     default null
  ,p_information320                 in     date     default null

  /* Extra Reserved Columns
  ,p_information321                 in     date     default null
  ,p_information322                 in     date     default null
  */
  ,p_information323                 in     long     default null
  ,p_datetrack_mode                 in     varchar2 default null
  ,p_copy_entity_result_id             out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ben_cpe_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_cpe_shd.convert_args
    (null
    ,p_copy_entity_txn_id
    ,p_src_copy_entity_result_id
    ,p_result_type_cd
    ,p_number_of_copies
    ,p_mirror_entity_result_id
    ,p_mirror_src_entity_result_id
    ,p_parent_entity_result_id
    ,p_pd_mr_src_entity_result_id
    ,p_pd_parent_entity_result_id
    ,p_gs_mr_src_entity_result_id
    ,p_gs_parent_entity_result_id
    ,p_table_name
    ,p_table_alias
    ,p_table_route_id
    ,p_status
    ,p_dml_operation
    ,p_information_category
    ,p_information1
    ,p_information2
    ,p_information3
    ,p_information4
    ,p_information5
    ,p_information6
    ,p_information7
    ,p_information8
    ,p_information9
    ,p_information10
    ,p_information11
    ,p_information12
    ,p_information13
    ,p_information14
    ,p_information15
    ,p_information16
    ,p_information17
    ,p_information18
    ,p_information19
    ,p_information20
    ,p_information21
    ,p_information22
    ,p_information23
    ,p_information24
    ,p_information25
    ,p_information26
    ,p_information27
    ,p_information28
    ,p_information29
    ,p_information30
    ,p_information31
    ,p_information32
    ,p_information33
    ,p_information34
    ,p_information35
    ,p_information36
    ,p_information37
    ,p_information38
    ,p_information39
    ,p_information40
    ,p_information41
    ,p_information42
    ,p_information43
    ,p_information44
    ,p_information45
    ,p_information46
    ,p_information47
    ,p_information48
    ,p_information49
    ,p_information50
    ,p_information51
    ,p_information52
    ,p_information53
    ,p_information54
    ,p_information55
    ,p_information56
    ,p_information57
    ,p_information58
    ,p_information59
    ,p_information60
    ,p_information61
    ,p_information62
    ,p_information63
    ,p_information64
    ,p_information65
    ,p_information66
    ,p_information67
    ,p_information68
    ,p_information69
    ,p_information70
    ,p_information71
    ,p_information72
    ,p_information73
    ,p_information74
    ,p_information75
    ,p_information76
    ,p_information77
    ,p_information78
    ,p_information79
    ,p_information80
    ,p_information81
    ,p_information82
    ,p_information83
    ,p_information84
    ,p_information85
    ,p_information86
    ,p_information87
    ,p_information88
    ,p_information89
    ,p_information90
    ,p_information91
    ,p_information92
    ,p_information93
    ,p_information94
    ,p_information95
    ,p_information96
    ,p_information97
    ,p_information98
    ,p_information99
    ,p_information100
    ,p_information101
    ,p_information102
    ,p_information103
    ,p_information104
    ,p_information105
    ,p_information106
    ,p_information107
    ,p_information108
    ,p_information109
    ,p_information110
    ,p_information111
    ,p_information112
    ,p_information113
    ,p_information114
    ,p_information115
    ,p_information116
    ,p_information117
    ,p_information118
    ,p_information119
    ,p_information120
    ,p_information121
    ,p_information122
    ,p_information123
    ,p_information124
    ,p_information125
    ,p_information126
    ,p_information127
    ,p_information128
    ,p_information129
    ,p_information130
    ,p_information131
    ,p_information132
    ,p_information133
    ,p_information134
    ,p_information135
    ,p_information136
    ,p_information137
    ,p_information138
    ,p_information139
    ,p_information140
    ,p_information141
    ,p_information142

    /* Extra Reserved Columns
    ,p_information143
    ,p_information144
    ,p_information145
    ,p_information146
    ,p_information147
    ,p_information148
    ,p_information149
    ,p_information150
    */
    ,p_information151
    ,p_information152
    ,p_information153

    /* Extra Reserved Columns
    ,p_information154
    ,p_information155
    ,p_information156
    ,p_information157
    ,p_information158
    ,p_information159
    */
    ,p_information160
    ,p_information161
    ,p_information162

    /* Extra Reserved Columns
    ,p_information163
    ,p_information164
    ,p_information165
    */
    ,p_information166
    ,p_information167
    ,p_information168
    ,p_information169
    ,p_information170

    /* Extra Reserved Columns
    ,p_information171
    ,p_information172
    */
    ,p_information173
    ,p_information174
    ,p_information175
    ,p_information176
    ,p_information177
    ,p_information178
    ,p_information179
    ,p_information180
    ,p_information181
    ,p_information182

    /* Extra Reserved Columns
    ,p_information183
    ,p_information184
    */
    ,p_information185
    ,p_information186
    ,p_information187
    ,p_information188

    /* Extra Reserved Columns
    ,p_information189
     */
    ,p_information190
    ,p_information191
    ,p_information192
    ,p_information193
    ,p_information194
    ,p_information195
    ,p_information196
    ,p_information197
    ,p_information198
    ,p_information199

    /* Extra Reserved Columns
    ,p_information200
    ,p_information201
    ,p_information202
    ,p_information203
    ,p_information204
    ,p_information205
    ,p_information206
    ,p_information207
    ,p_information208
    ,p_information209
    ,p_information210
    ,p_information211
    ,p_information212
    ,p_information213
    ,p_information214
    ,p_information215
    */
    ,p_information216
    ,p_information217
    ,p_information218
    ,p_information219
    ,p_information220
    ,p_information221
    ,p_information222
    ,p_information223
    ,p_information224
    ,p_information225
    ,p_information226
    ,p_information227
    ,p_information228
    ,p_information229
    ,p_information230
    ,p_information231
    ,p_information232
    ,p_information233
    ,p_information234
    ,p_information235
    ,p_information236
    ,p_information237
    ,p_information238
    ,p_information239
    ,p_information240
    ,p_information241
    ,p_information242
    ,p_information243
    ,p_information244
    ,p_information245
    ,p_information246
    ,p_information247
    ,p_information248
    ,p_information249
    ,p_information250
    ,p_information251
    ,p_information252
    ,p_information253
    ,p_information254
    ,p_information255
    ,p_information256
    ,p_information257
    ,p_information258
    ,p_information259
    ,p_information260
    ,p_information261
    ,p_information262
    ,p_information263
    ,p_information264
    ,p_information265
    ,p_information266
    ,p_information267
    ,p_information268
    ,p_information269
    ,p_information270
    ,p_information271
    ,p_information272
    ,p_information273
    ,p_information274
    ,p_information275
    ,p_information276
    ,p_information277
    ,p_information278
    ,p_information279
    ,p_information280
    ,p_information281
    ,p_information282
    ,p_information283
    ,p_information284
    ,p_information285
    ,p_information286
    ,p_information287
    ,p_information288
    ,p_information289
    ,p_information290
    ,p_information291
    ,p_information292
    ,p_information293
    ,p_information294
    ,p_information295
    ,p_information296
    ,p_information297
    ,p_information298
    ,p_information299
    ,p_information300
    ,p_information301
    ,p_information302
    ,p_information303
    ,p_information304

    /* Extra Reserved Columns
    ,p_information305
    */
    ,p_information306
    ,p_information307
    ,p_information308
    ,p_information309
    ,p_information310
    ,p_information311
    ,p_information312
    ,p_information313
    ,p_information314
    ,p_information315
    ,p_information316
    ,p_information317
    ,p_information318
    ,p_information319
    ,p_information320

    /* Extra Reserved Columns
    ,p_information321
    ,p_information322
    */
    ,p_information323
    ,p_datetrack_mode
    ,null
    );
  --
  -- Having converted the arguments into the ben_cpe_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_cpe_ins.ins
     (p_effective_date
     ,l_rec
     );
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
end ben_cpe_ins;

/
