--------------------------------------------------------
--  DDL for Package Body BEN_CPE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPE_UPD" as
/* $Header: becperhi.pkb 120.0 2005/05/28 01:12:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpe_upd.';  -- Global package name
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
Procedure update_dml
  (p_rec in out nocopy ben_cpe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ben_cpe_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_copy_entity_results Row
  --
  update ben_copy_entity_results
    set
     copy_entity_result_id           = p_rec.copy_entity_result_id
    ,copy_entity_txn_id              = p_rec.copy_entity_txn_id
    ,src_copy_entity_result_id       = p_rec.src_copy_entity_result_id
    ,result_type_cd                  = p_rec.result_type_cd
    ,number_of_copies                = p_rec.number_of_copies
    ,mirror_entity_result_id         = p_rec.mirror_entity_result_id
    ,mirror_src_entity_result_id     = p_rec.mirror_src_entity_result_id
    ,parent_entity_result_id         = p_rec.parent_entity_result_id
    ,pd_mirror_src_entity_result_id  = p_rec.pd_mirror_src_entity_result_id
    ,pd_parent_entity_result_id      = p_rec.pd_parent_entity_result_id
    ,gs_mirror_src_entity_result_id  = p_rec.gs_mirror_src_entity_result_id
    ,gs_parent_entity_result_id      = p_rec.gs_parent_entity_result_id
    ,table_name                      = p_rec.table_name
    ,table_alias                     = p_rec.table_alias
    ,table_route_id                  = p_rec.table_route_id
    ,status                          = p_rec.status
    ,dml_operation                   = p_rec.dml_operation
    ,information_category            = p_rec.information_category
    ,information1                    = p_rec.information1
    ,information2                    = p_rec.information2
    ,information3                    = p_rec.information3
    ,information4                    = p_rec.information4
    ,information5                    = p_rec.information5
    ,information6                    = p_rec.information6
    ,information7                    = p_rec.information7
    ,information8                    = p_rec.information8
    ,information9                    = p_rec.information9
    ,information10                   = p_rec.information10
    ,information11                   = p_rec.information11
    ,information12                   = p_rec.information12
    ,information13                   = p_rec.information13
    ,information14                   = p_rec.information14
    ,information15                   = p_rec.information15
    ,information16                   = p_rec.information16
    ,information17                   = p_rec.information17
    ,information18                   = p_rec.information18
    ,information19                   = p_rec.information19
    ,information20                   = p_rec.information20
    ,information21                   = p_rec.information21
    ,information22                   = p_rec.information22
    ,information23                   = p_rec.information23
    ,information24                   = p_rec.information24
    ,information25                   = p_rec.information25
    ,information26                   = p_rec.information26
    ,information27                   = p_rec.information27
    ,information28                   = p_rec.information28
    ,information29                   = p_rec.information29
    ,information30                   = p_rec.information30
    ,information31                   = p_rec.information31
    ,information32                   = p_rec.information32
    ,information33                   = p_rec.information33
    ,information34                   = p_rec.information34
    ,information35                   = p_rec.information35
    ,information36                   = p_rec.information36
    ,information37                   = p_rec.information37
    ,information38                   = p_rec.information38
    ,information39                   = p_rec.information39
    ,information40                   = p_rec.information40
    ,information41                   = p_rec.information41
    ,information42                   = p_rec.information42
    ,information43                   = p_rec.information43
    ,information44                   = p_rec.information44
    ,information45                   = p_rec.information45
    ,information46                   = p_rec.information46
    ,information47                   = p_rec.information47
    ,information48                   = p_rec.information48
    ,information49                   = p_rec.information49
    ,information50                   = p_rec.information50
    ,information51                   = p_rec.information51
    ,information52                   = p_rec.information52
    ,information53                   = p_rec.information53
    ,information54                   = p_rec.information54
    ,information55                   = p_rec.information55
    ,information56                   = p_rec.information56
    ,information57                   = p_rec.information57
    ,information58                   = p_rec.information58
    ,information59                   = p_rec.information59
    ,information60                   = p_rec.information60
    ,information61                   = p_rec.information61
    ,information62                   = p_rec.information62
    ,information63                   = p_rec.information63
    ,information64                   = p_rec.information64
    ,information65                   = p_rec.information65
    ,information66                   = p_rec.information66
    ,information67                   = p_rec.information67
    ,information68                   = p_rec.information68
    ,information69                   = p_rec.information69
    ,information70                   = p_rec.information70
    ,information71                   = p_rec.information71
    ,information72                   = p_rec.information72
    ,information73                   = p_rec.information73
    ,information74                   = p_rec.information74
    ,information75                   = p_rec.information75
    ,information76                   = p_rec.information76
    ,information77                   = p_rec.information77
    ,information78                   = p_rec.information78
    ,information79                   = p_rec.information79
    ,information80                   = p_rec.information80
    ,information81                   = p_rec.information81
    ,information82                   = p_rec.information82
    ,information83                   = p_rec.information83
    ,information84                   = p_rec.information84
    ,information85                   = p_rec.information85
    ,information86                   = p_rec.information86
    ,information87                   = p_rec.information87
    ,information88                   = p_rec.information88
    ,information89                   = p_rec.information89
    ,information90                   = p_rec.information90
    ,information91                   = p_rec.information91
    ,information92                   = p_rec.information92
    ,information93                   = p_rec.information93
    ,information94                   = p_rec.information94
    ,information95                   = p_rec.information95
    ,information96                   = p_rec.information96
    ,information97                   = p_rec.information97
    ,information98                   = p_rec.information98
    ,information99                   = p_rec.information99
    ,information100                  = p_rec.information100
    ,information101                  = p_rec.information101
    ,information102                  = p_rec.information102
    ,information103                  = p_rec.information103
    ,information104                  = p_rec.information104
    ,information105                  = p_rec.information105
    ,information106                  = p_rec.information106
    ,information107                  = p_rec.information107
    ,information108                  = p_rec.information108
    ,information109                  = p_rec.information109
    ,information110                  = p_rec.information110
    ,information111                  = p_rec.information111
    ,information112                  = p_rec.information112
    ,information113                  = p_rec.information113
    ,information114                  = p_rec.information114
    ,information115                  = p_rec.information115
    ,information116                  = p_rec.information116
    ,information117                  = p_rec.information117
    ,information118                  = p_rec.information118
    ,information119                  = p_rec.information119
    ,information120                  = p_rec.information120
    ,information121                  = p_rec.information121
    ,information122                  = p_rec.information122
    ,information123                  = p_rec.information123
    ,information124                  = p_rec.information124
    ,information125                  = p_rec.information125
    ,information126                  = p_rec.information126
    ,information127                  = p_rec.information127
    ,information128                  = p_rec.information128
    ,information129                  = p_rec.information129
    ,information130                  = p_rec.information130
    ,information131                  = p_rec.information131
    ,information132                  = p_rec.information132
    ,information133                  = p_rec.information133
    ,information134                  = p_rec.information134
    ,information135                  = p_rec.information135
    ,information136                  = p_rec.information136
    ,information137                  = p_rec.information137
    ,information138                  = p_rec.information138
    ,information139                  = p_rec.information139
    ,information140                  = p_rec.information140
    ,information141                  = p_rec.information141
    ,information142                  = p_rec.information142

    /* Extra Reserved Columns
    ,information143                  = p_rec.information143
    ,information144                  = p_rec.information144
    ,information145                  = p_rec.information145
    ,information146                  = p_rec.information146
    ,information147                  = p_rec.information147
    ,information148                  = p_rec.information148
    ,information149                  = p_rec.information149
    ,information150                  = p_rec.information150
    */
    ,information151                  = p_rec.information151
    ,information152                  = p_rec.information152
    ,information153                  = p_rec.information153

    /* Extra Reserved Columns
    ,information154                  = p_rec.information154
    ,information155                  = p_rec.information155
    ,information156                  = p_rec.information156
    ,information157                  = p_rec.information157
    ,information158                  = p_rec.information158
    ,information159                  = p_rec.information159
    */
    ,information160                  = p_rec.information160
    ,information161                  = p_rec.information161
    ,information162                  = p_rec.information162

    /* Extra Reserved Columns
    ,information163                  = p_rec.information163
    ,information164                  = p_rec.information164
    ,information165                  = p_rec.information165
    */
    ,information166                  = p_rec.information166
    ,information167                  = p_rec.information167
    ,information168                  = p_rec.information168
    ,information169                  = p_rec.information169
    ,information170                  = p_rec.information170

    /* Extra Reserved Columns
    ,information171                  = p_rec.information171
    ,information172                  = p_rec.information172
    */
    ,information173                  = p_rec.information173
    ,information174                  = p_rec.information174
    ,information175                  = p_rec.information175
    ,information176                  = p_rec.information176
    ,information177                  = p_rec.information177
    ,information178                  = p_rec.information178
    ,information179                  = p_rec.information179
    ,information180                  = p_rec.information180
    ,information181                  = p_rec.information181
    ,information182                  = p_rec.information182

    /* Extra Reserved Columns
    ,information183                  = p_rec.information183
    ,information184                  = p_rec.information184
    */
    ,information185                  = p_rec.information185
    ,information186                  = p_rec.information186
    ,information187                  = p_rec.information187
    ,information188                  = p_rec.information188

    /* Extra Reserved Columns
    ,information189                  = p_rec.information189
    */
    ,information190                  = p_rec.information190
    ,information191                  = p_rec.information191
    ,information192                  = p_rec.information192
    ,information193                  = p_rec.information193
    ,information194                  = p_rec.information194
    ,information195                  = p_rec.information195
    ,information196                  = p_rec.information196
    ,information197                  = p_rec.information197
    ,information198                  = p_rec.information198
    ,information199                  = p_rec.information199

    /* Extra Reserved Columns
    ,information200                  = p_rec.information200
    ,information201                  = p_rec.information201
    ,information202                  = p_rec.information202
    ,information203                  = p_rec.information203
    ,information204                  = p_rec.information204
    ,information205                  = p_rec.information205
    ,information206                  = p_rec.information206
    ,information207                  = p_rec.information207
    ,information208                  = p_rec.information208
    ,information209                  = p_rec.information209
    ,information210                  = p_rec.information210
    ,information211                  = p_rec.information211
    ,information212                  = p_rec.information212
    ,information213                  = p_rec.information213
    ,information214                  = p_rec.information214
    ,information215                  = p_rec.information215
    */
    ,information216                  = p_rec.information216
    ,information217                  = p_rec.information217
    ,information218                  = p_rec.information218
    ,information219                  = p_rec.information219
    ,information220                  = p_rec.information220
    ,information221                  = p_rec.information221
    ,information222                  = p_rec.information222
    ,information223                  = p_rec.information223
    ,information224                  = p_rec.information224
    ,information225                  = p_rec.information225
    ,information226                  = p_rec.information226
    ,information227                  = p_rec.information227
    ,information228                  = p_rec.information228
    ,information229                  = p_rec.information229
    ,information230                  = p_rec.information230
    ,information231                  = p_rec.information231
    ,information232                  = p_rec.information232
    ,information233                  = p_rec.information233
    ,information234                  = p_rec.information234
    ,information235                  = p_rec.information235
    ,information236                  = p_rec.information236
    ,information237                  = p_rec.information237
    ,information238                  = p_rec.information238
    ,information239                  = p_rec.information239
    ,information240                  = p_rec.information240
    ,information241                  = p_rec.information241
    ,information242                  = p_rec.information242
    ,information243                  = p_rec.information243
    ,information244                  = p_rec.information244
    ,information245                  = p_rec.information245
    ,information246                  = p_rec.information246
    ,information247                  = p_rec.information247
    ,information248                  = p_rec.information248
    ,information249                  = p_rec.information249
    ,information250                  = p_rec.information250
    ,information251                  = p_rec.information251
    ,information252                  = p_rec.information252
    ,information253                  = p_rec.information253
    ,information254                  = p_rec.information254
    ,information255                  = p_rec.information255
    ,information256                  = p_rec.information256
    ,information257                  = p_rec.information257
    ,information258                  = p_rec.information258
    ,information259                  = p_rec.information259
    ,information260                  = p_rec.information260
    ,information261                  = p_rec.information261
    ,information262                  = p_rec.information262
    ,information263                  = p_rec.information263
    ,information264                  = p_rec.information264
    ,information265                  = p_rec.information265
    ,information266                  = p_rec.information266
    ,information267                  = p_rec.information267
    ,information268                  = p_rec.information268
    ,information269                  = p_rec.information269
    ,information270                  = p_rec.information270
    ,information271                  = p_rec.information271
    ,information272                  = p_rec.information272
    ,information273                  = p_rec.information273
    ,information274                  = p_rec.information274
    ,information275                  = p_rec.information275
    ,information276                  = p_rec.information276
    ,information277                  = p_rec.information277
    ,information278                  = p_rec.information278
    ,information279                  = p_rec.information279
    ,information280                  = p_rec.information280
    ,information281                  = p_rec.information281
    ,information282                  = p_rec.information282
    ,information283                  = p_rec.information283
    ,information284                  = p_rec.information284
    ,information285                  = p_rec.information285
    ,information286                  = p_rec.information286
    ,information287                  = p_rec.information287
    ,information288                  = p_rec.information288
    ,information289                  = p_rec.information289
    ,information290                  = p_rec.information290
    ,information291                  = p_rec.information291
    ,information292                  = p_rec.information292
    ,information293                  = p_rec.information293
    ,information294                  = p_rec.information294
    ,information295                  = p_rec.information295
    ,information296                  = p_rec.information296
    ,information297                  = p_rec.information297
    ,information298                  = p_rec.information298
    ,information299                  = p_rec.information299
    ,information300                  = p_rec.information300
    ,information301                  = p_rec.information301
    ,information302                  = p_rec.information302
    ,information303                  = p_rec.information303
    ,information304                  = p_rec.information304

    /* Extra Reserved Columns
    ,information305                  = p_rec.information305
    */
    ,information306                  = p_rec.information306
    ,information307                  = p_rec.information307
    ,information308                  = p_rec.information308
    ,information309                  = p_rec.information309
    ,information310                  = p_rec.information310
    ,information311                  = p_rec.information311
    ,information312                  = p_rec.information312
    ,information313                  = p_rec.information313
    ,information314                  = p_rec.information314
    ,information315                  = p_rec.information315
    ,information316                  = p_rec.information316
    ,information317                  = p_rec.information317
    ,information318                  = p_rec.information318
    ,information319                  = p_rec.information319
    ,information320                  = p_rec.information320

    /* Extra Reserved Columns
    ,information321                  = p_rec.information321
    ,information322                  = p_rec.information322
    */
    ,information323                  = p_rec.information323
    ,datetrack_mode                  = p_rec.datetrack_mode
    ,object_version_number           = p_rec.object_version_number
    where copy_entity_result_id = p_rec.copy_entity_result_id;
  --
  ben_cpe_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
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
Procedure pre_update
  (p_rec in ben_cpe_shd.g_rec_type
  ) is
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
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_effective_date               in date
  ,p_rec                          in ben_cpe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_cpe_rku.after_update
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
      ,p_copy_entity_txn_id_o
      => ben_cpe_shd.g_old_rec.copy_entity_txn_id
      ,p_src_copy_entity_result_id_o
      => ben_cpe_shd.g_old_rec.src_copy_entity_result_id
      ,p_result_type_cd_o
      => ben_cpe_shd.g_old_rec.result_type_cd
      ,p_number_of_copies_o
      => ben_cpe_shd.g_old_rec.number_of_copies
      ,p_mirror_entity_result_id_o
      => ben_cpe_shd.g_old_rec.mirror_entity_result_id
      ,p_mirror_src_entity_result_i_o
      => ben_cpe_shd.g_old_rec.mirror_src_entity_result_id
      ,p_parent_entity_result_id_o
      => ben_cpe_shd.g_old_rec.parent_entity_result_id
      ,p_pd_mr_src_entity_result_id_o
      => ben_cpe_shd.g_old_rec.pd_mirror_src_entity_result_id
      ,p_pd_parent_entity_result_id_o
      => ben_cpe_shd.g_old_rec.pd_parent_entity_result_id
      ,p_gs_mr_src_entity_result_id_o
      => ben_cpe_shd.g_old_rec.gs_mirror_src_entity_result_id
      ,p_gs_parent_entity_result_id_o
      => ben_cpe_shd.g_old_rec.gs_parent_entity_result_id
      ,p_table_name_o
      => ben_cpe_shd.g_old_rec.table_name
      ,p_table_alias_o
      => ben_cpe_shd.g_old_rec.table_alias
      ,p_table_route_id_o
      => ben_cpe_shd.g_old_rec.table_route_id
      ,p_status_o
      => ben_cpe_shd.g_old_rec.status
      ,p_dml_operation_o
      => ben_cpe_shd.g_old_rec.dml_operation
      ,p_information_category_o
      => ben_cpe_shd.g_old_rec.information_category
      ,p_information1_o
      => ben_cpe_shd.g_old_rec.information1
      ,p_information2_o
      => ben_cpe_shd.g_old_rec.information2
      ,p_information3_o
      => ben_cpe_shd.g_old_rec.information3
      ,p_information4_o
      => ben_cpe_shd.g_old_rec.information4
      ,p_information5_o
      => ben_cpe_shd.g_old_rec.information5
      ,p_information6_o
      => ben_cpe_shd.g_old_rec.information6
      ,p_information7_o
      => ben_cpe_shd.g_old_rec.information7
      ,p_information8_o
      => ben_cpe_shd.g_old_rec.information8
      ,p_information9_o
      => ben_cpe_shd.g_old_rec.information9
      ,p_information10_o
      => ben_cpe_shd.g_old_rec.information10
      ,p_information11_o
      => ben_cpe_shd.g_old_rec.information11
      ,p_information12_o
      => ben_cpe_shd.g_old_rec.information12
      ,p_information13_o
      => ben_cpe_shd.g_old_rec.information13
      ,p_information14_o
      => ben_cpe_shd.g_old_rec.information14
      ,p_information15_o
      => ben_cpe_shd.g_old_rec.information15
      ,p_information16_o
      => ben_cpe_shd.g_old_rec.information16
      ,p_information17_o
      => ben_cpe_shd.g_old_rec.information17
      ,p_information18_o
      => ben_cpe_shd.g_old_rec.information18
      ,p_information19_o
      => ben_cpe_shd.g_old_rec.information19
      ,p_information20_o
      => ben_cpe_shd.g_old_rec.information20
      ,p_information21_o
      => ben_cpe_shd.g_old_rec.information21
      ,p_information22_o
      => ben_cpe_shd.g_old_rec.information22
      ,p_information23_o
      => ben_cpe_shd.g_old_rec.information23
      ,p_information24_o
      => ben_cpe_shd.g_old_rec.information24
      ,p_information25_o
      => ben_cpe_shd.g_old_rec.information25
      ,p_information26_o
      => ben_cpe_shd.g_old_rec.information26
      ,p_information27_o
      => ben_cpe_shd.g_old_rec.information27
      ,p_information28_o
      => ben_cpe_shd.g_old_rec.information28
      ,p_information29_o
      => ben_cpe_shd.g_old_rec.information29
      ,p_information30_o
      => ben_cpe_shd.g_old_rec.information30
      ,p_information31_o
      => ben_cpe_shd.g_old_rec.information31
      ,p_information32_o
      => ben_cpe_shd.g_old_rec.information32
      ,p_information33_o
      => ben_cpe_shd.g_old_rec.information33
      ,p_information34_o
      => ben_cpe_shd.g_old_rec.information34
      ,p_information35_o
      => ben_cpe_shd.g_old_rec.information35
      ,p_information36_o
      => ben_cpe_shd.g_old_rec.information36
      ,p_information37_o
      => ben_cpe_shd.g_old_rec.information37
      ,p_information38_o
      => ben_cpe_shd.g_old_rec.information38
      ,p_information39_o
      => ben_cpe_shd.g_old_rec.information39
      ,p_information40_o
      => ben_cpe_shd.g_old_rec.information40
      ,p_information41_o
      => ben_cpe_shd.g_old_rec.information41
      ,p_information42_o
      => ben_cpe_shd.g_old_rec.information42
      ,p_information43_o
      => ben_cpe_shd.g_old_rec.information43
      ,p_information44_o
      => ben_cpe_shd.g_old_rec.information44
      ,p_information45_o
      => ben_cpe_shd.g_old_rec.information45
      ,p_information46_o
      => ben_cpe_shd.g_old_rec.information46
      ,p_information47_o
      => ben_cpe_shd.g_old_rec.information47
      ,p_information48_o
      => ben_cpe_shd.g_old_rec.information48
      ,p_information49_o
      => ben_cpe_shd.g_old_rec.information49
      ,p_information50_o
      => ben_cpe_shd.g_old_rec.information50
      ,p_information51_o
      => ben_cpe_shd.g_old_rec.information51
      ,p_information52_o
      => ben_cpe_shd.g_old_rec.information52
      ,p_information53_o
      => ben_cpe_shd.g_old_rec.information53
      ,p_information54_o
      => ben_cpe_shd.g_old_rec.information54
      ,p_information55_o
      => ben_cpe_shd.g_old_rec.information55
      ,p_information56_o
      => ben_cpe_shd.g_old_rec.information56
      ,p_information57_o
      => ben_cpe_shd.g_old_rec.information57
      ,p_information58_o
      => ben_cpe_shd.g_old_rec.information58
      ,p_information59_o
      => ben_cpe_shd.g_old_rec.information59
      ,p_information60_o
      => ben_cpe_shd.g_old_rec.information60
      ,p_information61_o
      => ben_cpe_shd.g_old_rec.information61
      ,p_information62_o
      => ben_cpe_shd.g_old_rec.information62
      ,p_information63_o
      => ben_cpe_shd.g_old_rec.information63
      ,p_information64_o
      => ben_cpe_shd.g_old_rec.information64
      ,p_information65_o
      => ben_cpe_shd.g_old_rec.information65
      ,p_information66_o
      => ben_cpe_shd.g_old_rec.information66
      ,p_information67_o
      => ben_cpe_shd.g_old_rec.information67
      ,p_information68_o
      => ben_cpe_shd.g_old_rec.information68
      ,p_information69_o
      => ben_cpe_shd.g_old_rec.information69
      ,p_information70_o
      => ben_cpe_shd.g_old_rec.information70
      ,p_information71_o
      => ben_cpe_shd.g_old_rec.information71
      ,p_information72_o
      => ben_cpe_shd.g_old_rec.information72
      ,p_information73_o
      => ben_cpe_shd.g_old_rec.information73
      ,p_information74_o
      => ben_cpe_shd.g_old_rec.information74
      ,p_information75_o
      => ben_cpe_shd.g_old_rec.information75
      ,p_information76_o
      => ben_cpe_shd.g_old_rec.information76
      ,p_information77_o
      => ben_cpe_shd.g_old_rec.information77
      ,p_information78_o
      => ben_cpe_shd.g_old_rec.information78
      ,p_information79_o
      => ben_cpe_shd.g_old_rec.information79
      ,p_information80_o
      => ben_cpe_shd.g_old_rec.information80
      ,p_information81_o
      => ben_cpe_shd.g_old_rec.information81
      ,p_information82_o
      => ben_cpe_shd.g_old_rec.information82
      ,p_information83_o
      => ben_cpe_shd.g_old_rec.information83
      ,p_information84_o
      => ben_cpe_shd.g_old_rec.information84
      ,p_information85_o
      => ben_cpe_shd.g_old_rec.information85
      ,p_information86_o
      => ben_cpe_shd.g_old_rec.information86
      ,p_information87_o
      => ben_cpe_shd.g_old_rec.information87
      ,p_information88_o
      => ben_cpe_shd.g_old_rec.information88
      ,p_information89_o
      => ben_cpe_shd.g_old_rec.information89
      ,p_information90_o
      => ben_cpe_shd.g_old_rec.information90
      ,p_information91_o
      => ben_cpe_shd.g_old_rec.information91
      ,p_information92_o
      => ben_cpe_shd.g_old_rec.information92
      ,p_information93_o
      => ben_cpe_shd.g_old_rec.information93
      ,p_information94_o
      => ben_cpe_shd.g_old_rec.information94
      ,p_information95_o
      => ben_cpe_shd.g_old_rec.information95
      ,p_information96_o
      => ben_cpe_shd.g_old_rec.information96
      ,p_information97_o
      => ben_cpe_shd.g_old_rec.information97
      ,p_information98_o
      => ben_cpe_shd.g_old_rec.information98
      ,p_information99_o
      => ben_cpe_shd.g_old_rec.information99
      ,p_information100_o
      => ben_cpe_shd.g_old_rec.information100
      ,p_information101_o
      => ben_cpe_shd.g_old_rec.information101
      ,p_information102_o
      => ben_cpe_shd.g_old_rec.information102
      ,p_information103_o
      => ben_cpe_shd.g_old_rec.information103
      ,p_information104_o
      => ben_cpe_shd.g_old_rec.information104
      ,p_information105_o
      => ben_cpe_shd.g_old_rec.information105
      ,p_information106_o
      => ben_cpe_shd.g_old_rec.information106
      ,p_information107_o
      => ben_cpe_shd.g_old_rec.information107
      ,p_information108_o
      => ben_cpe_shd.g_old_rec.information108
      ,p_information109_o
      => ben_cpe_shd.g_old_rec.information109
      ,p_information110_o
      => ben_cpe_shd.g_old_rec.information110
      ,p_information111_o
      => ben_cpe_shd.g_old_rec.information111
      ,p_information112_o
      => ben_cpe_shd.g_old_rec.information112
      ,p_information113_o
      => ben_cpe_shd.g_old_rec.information113
      ,p_information114_o
      => ben_cpe_shd.g_old_rec.information114
      ,p_information115_o
      => ben_cpe_shd.g_old_rec.information115
      ,p_information116_o
      => ben_cpe_shd.g_old_rec.information116
      ,p_information117_o
      => ben_cpe_shd.g_old_rec.information117
      ,p_information118_o
      => ben_cpe_shd.g_old_rec.information118
      ,p_information119_o
      => ben_cpe_shd.g_old_rec.information119
      ,p_information120_o
      => ben_cpe_shd.g_old_rec.information120
      ,p_information121_o
      => ben_cpe_shd.g_old_rec.information121
      ,p_information122_o
      => ben_cpe_shd.g_old_rec.information122
      ,p_information123_o
      => ben_cpe_shd.g_old_rec.information123
      ,p_information124_o
      => ben_cpe_shd.g_old_rec.information124
      ,p_information125_o
      => ben_cpe_shd.g_old_rec.information125
      ,p_information126_o
      => ben_cpe_shd.g_old_rec.information126
      ,p_information127_o
      => ben_cpe_shd.g_old_rec.information127
      ,p_information128_o
      => ben_cpe_shd.g_old_rec.information128
      ,p_information129_o
      => ben_cpe_shd.g_old_rec.information129
      ,p_information130_o
      => ben_cpe_shd.g_old_rec.information130
      ,p_information131_o
      => ben_cpe_shd.g_old_rec.information131
      ,p_information132_o
      => ben_cpe_shd.g_old_rec.information132
      ,p_information133_o
      => ben_cpe_shd.g_old_rec.information133
      ,p_information134_o
      => ben_cpe_shd.g_old_rec.information134
      ,p_information135_o
      => ben_cpe_shd.g_old_rec.information135
      ,p_information136_o
      => ben_cpe_shd.g_old_rec.information136
      ,p_information137_o
      => ben_cpe_shd.g_old_rec.information137
      ,p_information138_o
      => ben_cpe_shd.g_old_rec.information138
      ,p_information139_o
      => ben_cpe_shd.g_old_rec.information139
      ,p_information140_o
      => ben_cpe_shd.g_old_rec.information140
      ,p_information141_o
      => ben_cpe_shd.g_old_rec.information141
      ,p_information142_o
      => ben_cpe_shd.g_old_rec.information142

      /* Extra Reserved Columns
      ,p_information143_o
      => ben_cpe_shd.g_old_rec.information143
      ,p_information144_o
      => ben_cpe_shd.g_old_rec.information144
      ,p_information145_o
      => ben_cpe_shd.g_old_rec.information145
      ,p_information146_o
      => ben_cpe_shd.g_old_rec.information146
      ,p_information147_o
      => ben_cpe_shd.g_old_rec.information147
      ,p_information148_o
      => ben_cpe_shd.g_old_rec.information148
      ,p_information149_o
      => ben_cpe_shd.g_old_rec.information149
      ,p_information150_o
      => ben_cpe_shd.g_old_rec.information150
      */
      ,p_information151_o
      => ben_cpe_shd.g_old_rec.information151
      ,p_information152_o
      => ben_cpe_shd.g_old_rec.information152
      ,p_information153_o
      => ben_cpe_shd.g_old_rec.information153

      /* Extra Reserved Columns
      ,p_information154_o
      => ben_cpe_shd.g_old_rec.information154
      ,p_information155_o
      => ben_cpe_shd.g_old_rec.information155
      ,p_information156_o
      => ben_cpe_shd.g_old_rec.information156
      ,p_information157_o
      => ben_cpe_shd.g_old_rec.information157
      ,p_information158_o
      => ben_cpe_shd.g_old_rec.information158
      ,p_information159_o
      => ben_cpe_shd.g_old_rec.information159
      */

      ,p_information160_o
      => ben_cpe_shd.g_old_rec.information160
      ,p_information161_o
      => ben_cpe_shd.g_old_rec.information161
      ,p_information162_o
      => ben_cpe_shd.g_old_rec.information162

      /* Extra Reserved Columns
      ,p_information163_o
      => ben_cpe_shd.g_old_rec.information163
      ,p_information164_o
      => ben_cpe_shd.g_old_rec.information164
      ,p_information165_o
      => ben_cpe_shd.g_old_rec.information165
      */

      ,p_information166_o
      => ben_cpe_shd.g_old_rec.information166
      ,p_information167_o
      => ben_cpe_shd.g_old_rec.information167
      ,p_information168_o
      => ben_cpe_shd.g_old_rec.information168
      ,p_information169_o
      => ben_cpe_shd.g_old_rec.information169
      ,p_information170_o
      => ben_cpe_shd.g_old_rec.information170

      /* Extra Reserved Columns
      ,p_information171_o
      => ben_cpe_shd.g_old_rec.information171
      ,p_information172_o
      => ben_cpe_shd.g_old_rec.information172
      */

      ,p_information173_o
      => ben_cpe_shd.g_old_rec.information173
      ,p_information174_o
      => ben_cpe_shd.g_old_rec.information174
      ,p_information175_o
      => ben_cpe_shd.g_old_rec.information175
      ,p_information176_o
      => ben_cpe_shd.g_old_rec.information176
      ,p_information177_o
      => ben_cpe_shd.g_old_rec.information177
      ,p_information178_o
      => ben_cpe_shd.g_old_rec.information178
      ,p_information179_o
      => ben_cpe_shd.g_old_rec.information179
      ,p_information180_o
      => ben_cpe_shd.g_old_rec.information180
      ,p_information181_o
      => ben_cpe_shd.g_old_rec.information181
      ,p_information182_o
      => ben_cpe_shd.g_old_rec.information182

      /* Extra Reserved Columns
      ,p_information183_o
      => ben_cpe_shd.g_old_rec.information183
      ,p_information184_o
      => ben_cpe_shd.g_old_rec.information184
      */
      ,p_information185_o
      => ben_cpe_shd.g_old_rec.information185
      ,p_information186_o
      => ben_cpe_shd.g_old_rec.information186
      ,p_information187_o
      => ben_cpe_shd.g_old_rec.information187
      ,p_information188_o
      => ben_cpe_shd.g_old_rec.information188

      /* Extra Reserved Columns
      ,p_information189_o
      => ben_cpe_shd.g_old_rec.information189
      */
      ,p_information190_o
      => ben_cpe_shd.g_old_rec.information190
      ,p_information191_o
      => ben_cpe_shd.g_old_rec.information191
      ,p_information192_o
      => ben_cpe_shd.g_old_rec.information192
      ,p_information193_o
      => ben_cpe_shd.g_old_rec.information193
      ,p_information194_o
      => ben_cpe_shd.g_old_rec.information194
      ,p_information195_o
      => ben_cpe_shd.g_old_rec.information195
      ,p_information196_o
      => ben_cpe_shd.g_old_rec.information196
      ,p_information197_o
      => ben_cpe_shd.g_old_rec.information197
      ,p_information198_o
      => ben_cpe_shd.g_old_rec.information198
      ,p_information199_o
      => ben_cpe_shd.g_old_rec.information199

      /* Extra Reserved Columns
      ,p_information200_o
      => ben_cpe_shd.g_old_rec.information200
      ,p_information201_o
      => ben_cpe_shd.g_old_rec.information201
      ,p_information202_o
      => ben_cpe_shd.g_old_rec.information202
      ,p_information203_o
      => ben_cpe_shd.g_old_rec.information203
      ,p_information204_o
      => ben_cpe_shd.g_old_rec.information204
      ,p_information205_o
      => ben_cpe_shd.g_old_rec.information205
      ,p_information206_o
      => ben_cpe_shd.g_old_rec.information206
      ,p_information207_o
      => ben_cpe_shd.g_old_rec.information207
      ,p_information208_o
      => ben_cpe_shd.g_old_rec.information208
      ,p_information209_o
      => ben_cpe_shd.g_old_rec.information209
      ,p_information210_o
      => ben_cpe_shd.g_old_rec.information210
      ,p_information211_o
      => ben_cpe_shd.g_old_rec.information211
      ,p_information212_o
      => ben_cpe_shd.g_old_rec.information212
      ,p_information213_o
      => ben_cpe_shd.g_old_rec.information213
      ,p_information214_o
      => ben_cpe_shd.g_old_rec.information214
      ,p_information215_o
      => ben_cpe_shd.g_old_rec.information215
      */

      ,p_information216_o
      => ben_cpe_shd.g_old_rec.information216
      ,p_information217_o
      => ben_cpe_shd.g_old_rec.information217
      ,p_information218_o
      => ben_cpe_shd.g_old_rec.information218
      ,p_information219_o
      => ben_cpe_shd.g_old_rec.information219
      ,p_information220_o
      => ben_cpe_shd.g_old_rec.information220

      ,p_information221_o
      => ben_cpe_shd.g_old_rec.information221
      ,p_information222_o
      => ben_cpe_shd.g_old_rec.information222
      ,p_information223_o
      => ben_cpe_shd.g_old_rec.information223
      ,p_information224_o
      => ben_cpe_shd.g_old_rec.information224
      ,p_information225_o
      => ben_cpe_shd.g_old_rec.information225
      ,p_information226_o
      => ben_cpe_shd.g_old_rec.information226
      ,p_information227_o
      => ben_cpe_shd.g_old_rec.information227
      ,p_information228_o
      => ben_cpe_shd.g_old_rec.information228
      ,p_information229_o
      => ben_cpe_shd.g_old_rec.information229
      ,p_information230_o
      => ben_cpe_shd.g_old_rec.information230
      ,p_information231_o
      => ben_cpe_shd.g_old_rec.information231
      ,p_information232_o
      => ben_cpe_shd.g_old_rec.information232
      ,p_information233_o
      => ben_cpe_shd.g_old_rec.information233
      ,p_information234_o
      => ben_cpe_shd.g_old_rec.information234
      ,p_information235_o
      => ben_cpe_shd.g_old_rec.information235
      ,p_information236_o
      => ben_cpe_shd.g_old_rec.information236
      ,p_information237_o
      => ben_cpe_shd.g_old_rec.information237
      ,p_information238_o
      => ben_cpe_shd.g_old_rec.information238
      ,p_information239_o
      => ben_cpe_shd.g_old_rec.information239
      ,p_information240_o
      => ben_cpe_shd.g_old_rec.information240
      ,p_information241_o
      => ben_cpe_shd.g_old_rec.information241
      ,p_information242_o
      => ben_cpe_shd.g_old_rec.information242
      ,p_information243_o
      => ben_cpe_shd.g_old_rec.information243
      ,p_information244_o
      => ben_cpe_shd.g_old_rec.information244
      ,p_information245_o
      => ben_cpe_shd.g_old_rec.information245
      ,p_information246_o
      => ben_cpe_shd.g_old_rec.information246
      ,p_information247_o
      => ben_cpe_shd.g_old_rec.information247
      ,p_information248_o
      => ben_cpe_shd.g_old_rec.information248
      ,p_information249_o
      => ben_cpe_shd.g_old_rec.information249
      ,p_information250_o
      => ben_cpe_shd.g_old_rec.information250
      ,p_information251_o
      => ben_cpe_shd.g_old_rec.information251
      ,p_information252_o
      => ben_cpe_shd.g_old_rec.information252
      ,p_information253_o
      => ben_cpe_shd.g_old_rec.information253
      ,p_information254_o
      => ben_cpe_shd.g_old_rec.information254
      ,p_information255_o
      => ben_cpe_shd.g_old_rec.information255
      ,p_information256_o
      => ben_cpe_shd.g_old_rec.information256
      ,p_information257_o
      => ben_cpe_shd.g_old_rec.information257
      ,p_information258_o
      => ben_cpe_shd.g_old_rec.information258
      ,p_information259_o
      => ben_cpe_shd.g_old_rec.information259
      ,p_information260_o
      => ben_cpe_shd.g_old_rec.information260
      ,p_information261_o
      => ben_cpe_shd.g_old_rec.information261
      ,p_information262_o
      => ben_cpe_shd.g_old_rec.information262
      ,p_information263_o
      => ben_cpe_shd.g_old_rec.information263
      ,p_information264_o
      => ben_cpe_shd.g_old_rec.information264
      ,p_information265_o
      => ben_cpe_shd.g_old_rec.information265
      ,p_information266_o
      => ben_cpe_shd.g_old_rec.information266
      ,p_information267_o
      => ben_cpe_shd.g_old_rec.information267
      ,p_information268_o
      => ben_cpe_shd.g_old_rec.information268
      ,p_information269_o
      => ben_cpe_shd.g_old_rec.information269
      ,p_information270_o
      => ben_cpe_shd.g_old_rec.information270
      ,p_information271_o
      => ben_cpe_shd.g_old_rec.information271
      ,p_information272_o
      => ben_cpe_shd.g_old_rec.information272
      ,p_information273_o
      => ben_cpe_shd.g_old_rec.information273
      ,p_information274_o
      => ben_cpe_shd.g_old_rec.information274
      ,p_information275_o
      => ben_cpe_shd.g_old_rec.information275
      ,p_information276_o
      => ben_cpe_shd.g_old_rec.information276
      ,p_information277_o
      => ben_cpe_shd.g_old_rec.information277
      ,p_information278_o
      => ben_cpe_shd.g_old_rec.information278
      ,p_information279_o
      => ben_cpe_shd.g_old_rec.information279
      ,p_information280_o
      => ben_cpe_shd.g_old_rec.information280
      ,p_information281_o
      => ben_cpe_shd.g_old_rec.information281
      ,p_information282_o
      => ben_cpe_shd.g_old_rec.information282
      ,p_information283_o
      => ben_cpe_shd.g_old_rec.information283
      ,p_information284_o
      => ben_cpe_shd.g_old_rec.information284
      ,p_information285_o
      => ben_cpe_shd.g_old_rec.information285
      ,p_information286_o
      => ben_cpe_shd.g_old_rec.information286
      ,p_information287_o
      => ben_cpe_shd.g_old_rec.information287
      ,p_information288_o
      => ben_cpe_shd.g_old_rec.information288
      ,p_information289_o
      => ben_cpe_shd.g_old_rec.information289
      ,p_information290_o
      => ben_cpe_shd.g_old_rec.information290
      ,p_information291_o
      => ben_cpe_shd.g_old_rec.information291
      ,p_information292_o
      => ben_cpe_shd.g_old_rec.information292
      ,p_information293_o
      => ben_cpe_shd.g_old_rec.information293
      ,p_information294_o
      => ben_cpe_shd.g_old_rec.information294
      ,p_information295_o
      => ben_cpe_shd.g_old_rec.information295
      ,p_information296_o
      => ben_cpe_shd.g_old_rec.information296
      ,p_information297_o
      => ben_cpe_shd.g_old_rec.information297
      ,p_information298_o
      => ben_cpe_shd.g_old_rec.information298
      ,p_information299_o
      => ben_cpe_shd.g_old_rec.information299
      ,p_information300_o
      => ben_cpe_shd.g_old_rec.information300
      ,p_information301_o
      => ben_cpe_shd.g_old_rec.information301
      ,p_information302_o
      => ben_cpe_shd.g_old_rec.information302
      ,p_information303_o
      => ben_cpe_shd.g_old_rec.information303
      ,p_information304_o
      => ben_cpe_shd.g_old_rec.information304

      /* Extra Reserved Columns
      ,p_information305_o
      => ben_cpe_shd.g_old_rec.information305
      */

      ,p_information306_o
      => ben_cpe_shd.g_old_rec.information306
      ,p_information307_o
      => ben_cpe_shd.g_old_rec.information307
      ,p_information308_o
      => ben_cpe_shd.g_old_rec.information308
      ,p_information309_o
      => ben_cpe_shd.g_old_rec.information309
      ,p_information310_o
      => ben_cpe_shd.g_old_rec.information310
      ,p_information311_o
      => ben_cpe_shd.g_old_rec.information311
      ,p_information312_o
      => ben_cpe_shd.g_old_rec.information312
      ,p_information313_o
      => ben_cpe_shd.g_old_rec.information313
      ,p_information314_o
      => ben_cpe_shd.g_old_rec.information314
      ,p_information315_o
      => ben_cpe_shd.g_old_rec.information315
      ,p_information316_o
      => ben_cpe_shd.g_old_rec.information316
      ,p_information317_o
      => ben_cpe_shd.g_old_rec.information317
      ,p_information318_o
      => ben_cpe_shd.g_old_rec.information318
      ,p_information319_o
      => ben_cpe_shd.g_old_rec.information319
      ,p_information320_o
      => ben_cpe_shd.g_old_rec.information320

      /* Extra Reserved Columns
      ,p_information321_o
      => ben_cpe_shd.g_old_rec.information321
      ,p_information322_o
      => ben_cpe_shd.g_old_rec.information322
      */

      ,p_information323_o
      => ben_cpe_shd.g_old_rec.information323

      ,p_datetrack_mode_o
      => ben_cpe_shd.g_old_rec.datetrack_mode
      ,p_object_version_number_o
      => ben_cpe_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_COPY_ENTITY_RESULTS'
        ,p_hook_type   => 'AU');
      --
  end;
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
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
Procedure convert_defs
  (p_rec in out nocopy ben_cpe_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.copy_entity_txn_id = hr_api.g_number) then
    p_rec.copy_entity_txn_id :=
    ben_cpe_shd.g_old_rec.copy_entity_txn_id;
  End If;
  If (p_rec.src_copy_entity_result_id = hr_api.g_number) then
    p_rec.src_copy_entity_result_id :=
    ben_cpe_shd.g_old_rec.src_copy_entity_result_id;
  End If;
  If (p_rec.result_type_cd = hr_api.g_varchar2) then
    p_rec.result_type_cd :=
    ben_cpe_shd.g_old_rec.result_type_cd;
  End If;
  If (p_rec.number_of_copies = hr_api.g_number) then
    p_rec.number_of_copies :=
    ben_cpe_shd.g_old_rec.number_of_copies;
  End If;
  If (p_rec.mirror_entity_result_id = hr_api.g_number) then
    p_rec.mirror_entity_result_id :=
    ben_cpe_shd.g_old_rec.mirror_entity_result_id;
  End If;
  If (p_rec.mirror_src_entity_result_id = hr_api.g_number) then
    p_rec.mirror_src_entity_result_id :=
    ben_cpe_shd.g_old_rec.mirror_src_entity_result_id;
  End If;
  If (p_rec.parent_entity_result_id = hr_api.g_number) then
    p_rec.parent_entity_result_id :=
    ben_cpe_shd.g_old_rec.parent_entity_result_id;
  End If;
  If (p_rec.pd_mirror_src_entity_result_id = hr_api.g_number) then
    p_rec.pd_mirror_src_entity_result_id :=
    ben_cpe_shd.g_old_rec.pd_mirror_src_entity_result_id;
  End If;
  If (p_rec.pd_parent_entity_result_id = hr_api.g_number) then
    p_rec.pd_parent_entity_result_id :=
    ben_cpe_shd.g_old_rec.pd_parent_entity_result_id;
  End If;
  If (p_rec.gs_mirror_src_entity_result_id = hr_api.g_number) then
    p_rec.gs_mirror_src_entity_result_id :=
    ben_cpe_shd.g_old_rec.gs_mirror_src_entity_result_id;
  End If;
  If (p_rec.gs_parent_entity_result_id = hr_api.g_number) then
    p_rec.gs_parent_entity_result_id :=
    ben_cpe_shd.g_old_rec.gs_parent_entity_result_id;
  End If;
  If (p_rec.table_name = hr_api.g_varchar2) then
    p_rec.table_name :=
    ben_cpe_shd.g_old_rec.table_name;
  End If;
  If (p_rec.table_alias = hr_api.g_varchar2) then
    p_rec.table_alias :=
    ben_cpe_shd.g_old_rec.table_alias;
  End If;
  If (p_rec.table_route_id = hr_api.g_number) then
    p_rec.table_route_id :=
    ben_cpe_shd.g_old_rec.table_route_id;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    ben_cpe_shd.g_old_rec.status;
  End If;
  If (p_rec.dml_operation = hr_api.g_varchar2) then
    p_rec.dml_operation :=
    ben_cpe_shd.g_old_rec.dml_operation;
  End If;
  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category :=
    ben_cpe_shd.g_old_rec.information_category;
  End If;
  If (p_rec.information1 = hr_api.g_number) then
    p_rec.information1 :=
    ben_cpe_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_date) then
    p_rec.information2 :=
    ben_cpe_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_date) then
    p_rec.information3 :=
    ben_cpe_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_number) then
    p_rec.information4 :=
    ben_cpe_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    ben_cpe_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    ben_cpe_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    ben_cpe_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    ben_cpe_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    ben_cpe_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_date) then
    p_rec.information10 :=
    ben_cpe_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    ben_cpe_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    ben_cpe_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    ben_cpe_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    ben_cpe_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    ben_cpe_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    ben_cpe_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    ben_cpe_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    ben_cpe_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    ben_cpe_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    ben_cpe_shd.g_old_rec.information20;
  End If;
  If (p_rec.information21 = hr_api.g_varchar2) then
    p_rec.information21 :=
    ben_cpe_shd.g_old_rec.information21;
  End If;
  If (p_rec.information22 = hr_api.g_varchar2) then
    p_rec.information22 :=
    ben_cpe_shd.g_old_rec.information22;
  End If;
  If (p_rec.information23 = hr_api.g_varchar2) then
    p_rec.information23 :=
    ben_cpe_shd.g_old_rec.information23;
  End If;
  If (p_rec.information24 = hr_api.g_varchar2) then
    p_rec.information24 :=
    ben_cpe_shd.g_old_rec.information24;
  End If;
  If (p_rec.information25 = hr_api.g_varchar2) then
    p_rec.information25 :=
    ben_cpe_shd.g_old_rec.information25;
  End If;
  If (p_rec.information26 = hr_api.g_varchar2) then
    p_rec.information26 :=
    ben_cpe_shd.g_old_rec.information26;
  End If;
  If (p_rec.information27 = hr_api.g_varchar2) then
    p_rec.information27 :=
    ben_cpe_shd.g_old_rec.information27;
  End If;
  If (p_rec.information28 = hr_api.g_varchar2) then
    p_rec.information28 :=
    ben_cpe_shd.g_old_rec.information28;
  End If;
  If (p_rec.information29 = hr_api.g_varchar2) then
    p_rec.information29 :=
    ben_cpe_shd.g_old_rec.information29;
  End If;
  If (p_rec.information30 = hr_api.g_varchar2) then
    p_rec.information30 :=
    ben_cpe_shd.g_old_rec.information30;
  End If;
  If (p_rec.information31 = hr_api.g_varchar2) then
    p_rec.information31 :=
    ben_cpe_shd.g_old_rec.information31;
  End If;
  If (p_rec.information32 = hr_api.g_varchar2) then
    p_rec.information32 :=
    ben_cpe_shd.g_old_rec.information32;
  End If;
  If (p_rec.information33 = hr_api.g_varchar2) then
    p_rec.information33 :=
    ben_cpe_shd.g_old_rec.information33;
  End If;
  If (p_rec.information34 = hr_api.g_varchar2) then
    p_rec.information34 :=
    ben_cpe_shd.g_old_rec.information34;
  End If;
  If (p_rec.information35 = hr_api.g_varchar2) then
    p_rec.information35 :=
    ben_cpe_shd.g_old_rec.information35;
  End If;
  If (p_rec.information36 = hr_api.g_varchar2) then
    p_rec.information36 :=
    ben_cpe_shd.g_old_rec.information36;
  End If;
  If (p_rec.information37 = hr_api.g_varchar2) then
    p_rec.information37 :=
    ben_cpe_shd.g_old_rec.information37;
  End If;
  If (p_rec.information38 = hr_api.g_varchar2) then
    p_rec.information38 :=
    ben_cpe_shd.g_old_rec.information38;
  End If;
  If (p_rec.information39 = hr_api.g_varchar2) then
    p_rec.information39 :=
    ben_cpe_shd.g_old_rec.information39;
  End If;
  If (p_rec.information40 = hr_api.g_varchar2) then
    p_rec.information40 :=
    ben_cpe_shd.g_old_rec.information40;
  End If;
  If (p_rec.information41 = hr_api.g_varchar2) then
    p_rec.information41 :=
    ben_cpe_shd.g_old_rec.information41;
  End If;
  If (p_rec.information42 = hr_api.g_varchar2) then
    p_rec.information42 :=
    ben_cpe_shd.g_old_rec.information42;
  End If;
  If (p_rec.information43 = hr_api.g_varchar2) then
    p_rec.information43 :=
    ben_cpe_shd.g_old_rec.information43;
  End If;
  If (p_rec.information44 = hr_api.g_varchar2) then
    p_rec.information44 :=
    ben_cpe_shd.g_old_rec.information44;
  End If;
  If (p_rec.information45 = hr_api.g_varchar2) then
    p_rec.information45 :=
    ben_cpe_shd.g_old_rec.information45;
  End If;
  If (p_rec.information46 = hr_api.g_varchar2) then
    p_rec.information46 :=
    ben_cpe_shd.g_old_rec.information46;
  End If;
  If (p_rec.information47 = hr_api.g_varchar2) then
    p_rec.information47 :=
    ben_cpe_shd.g_old_rec.information47;
  End If;
  If (p_rec.information48 = hr_api.g_varchar2) then
    p_rec.information48 :=
    ben_cpe_shd.g_old_rec.information48;
  End If;
  If (p_rec.information49 = hr_api.g_varchar2) then
    p_rec.information49 :=
    ben_cpe_shd.g_old_rec.information49;
  End If;
  If (p_rec.information50 = hr_api.g_varchar2) then
    p_rec.information50 :=
    ben_cpe_shd.g_old_rec.information50;
  End If;
  If (p_rec.information51 = hr_api.g_varchar2) then
    p_rec.information51 :=
    ben_cpe_shd.g_old_rec.information51;
  End If;
  If (p_rec.information52 = hr_api.g_varchar2) then
    p_rec.information52 :=
    ben_cpe_shd.g_old_rec.information52;
  End If;
  If (p_rec.information53 = hr_api.g_varchar2) then
    p_rec.information53 :=
    ben_cpe_shd.g_old_rec.information53;
  End If;
  If (p_rec.information54 = hr_api.g_varchar2) then
    p_rec.information54 :=
    ben_cpe_shd.g_old_rec.information54;
  End If;
  If (p_rec.information55 = hr_api.g_varchar2) then
    p_rec.information55 :=
    ben_cpe_shd.g_old_rec.information55;
  End If;
  If (p_rec.information56 = hr_api.g_varchar2) then
    p_rec.information56 :=
    ben_cpe_shd.g_old_rec.information56;
  End If;
  If (p_rec.information57 = hr_api.g_varchar2) then
    p_rec.information57 :=
    ben_cpe_shd.g_old_rec.information57;
  End If;
  If (p_rec.information58 = hr_api.g_varchar2) then
    p_rec.information58 :=
    ben_cpe_shd.g_old_rec.information58;
  End If;
  If (p_rec.information59 = hr_api.g_varchar2) then
    p_rec.information59 :=
    ben_cpe_shd.g_old_rec.information59;
  End If;
  If (p_rec.information60 = hr_api.g_varchar2) then
    p_rec.information60 :=
    ben_cpe_shd.g_old_rec.information60;
  End If;
  If (p_rec.information61 = hr_api.g_varchar2) then
    p_rec.information61 :=
    ben_cpe_shd.g_old_rec.information61;
  End If;
  If (p_rec.information62 = hr_api.g_varchar2) then
    p_rec.information62 :=
    ben_cpe_shd.g_old_rec.information62;
  End If;
  If (p_rec.information63 = hr_api.g_varchar2) then
    p_rec.information63 :=
    ben_cpe_shd.g_old_rec.information63;
  End If;
  If (p_rec.information64 = hr_api.g_varchar2) then
    p_rec.information64 :=
    ben_cpe_shd.g_old_rec.information64;
  End If;
  If (p_rec.information65 = hr_api.g_varchar2) then
    p_rec.information65 :=
    ben_cpe_shd.g_old_rec.information65;
  End If;
  If (p_rec.information66 = hr_api.g_varchar2) then
    p_rec.information66 :=
    ben_cpe_shd.g_old_rec.information66;
  End If;
  If (p_rec.information67 = hr_api.g_varchar2) then
    p_rec.information67 :=
    ben_cpe_shd.g_old_rec.information67;
  End If;
  If (p_rec.information68 = hr_api.g_varchar2) then
    p_rec.information68 :=
    ben_cpe_shd.g_old_rec.information68;
  End If;
  If (p_rec.information69 = hr_api.g_varchar2) then
    p_rec.information69 :=
    ben_cpe_shd.g_old_rec.information69;
  End If;
  If (p_rec.information70 = hr_api.g_varchar2) then
    p_rec.information70 :=
    ben_cpe_shd.g_old_rec.information70;
  End If;
  If (p_rec.information71 = hr_api.g_varchar2) then
    p_rec.information71 :=
    ben_cpe_shd.g_old_rec.information71;
  End If;
  If (p_rec.information72 = hr_api.g_varchar2) then
    p_rec.information72 :=
    ben_cpe_shd.g_old_rec.information72;
  End If;
  If (p_rec.information73 = hr_api.g_varchar2) then
    p_rec.information73 :=
    ben_cpe_shd.g_old_rec.information73;
  End If;
  If (p_rec.information74 = hr_api.g_varchar2) then
    p_rec.information74 :=
    ben_cpe_shd.g_old_rec.information74;
  End If;
  If (p_rec.information75 = hr_api.g_varchar2) then
    p_rec.information75 :=
    ben_cpe_shd.g_old_rec.information75;
  End If;
  If (p_rec.information76 = hr_api.g_varchar2) then
    p_rec.information76 :=
    ben_cpe_shd.g_old_rec.information76;
  End If;
  If (p_rec.information77 = hr_api.g_varchar2) then
    p_rec.information77 :=
    ben_cpe_shd.g_old_rec.information77;
  End If;
  If (p_rec.information78 = hr_api.g_varchar2) then
    p_rec.information78 :=
    ben_cpe_shd.g_old_rec.information78;
  End If;
  If (p_rec.information79 = hr_api.g_varchar2) then
    p_rec.information79 :=
    ben_cpe_shd.g_old_rec.information79;
  End If;
  If (p_rec.information80 = hr_api.g_varchar2) then
    p_rec.information80 :=
    ben_cpe_shd.g_old_rec.information80;
  End If;
  If (p_rec.information81 = hr_api.g_varchar2) then
    p_rec.information81 :=
    ben_cpe_shd.g_old_rec.information81;
  End If;
  If (p_rec.information82 = hr_api.g_varchar2) then
    p_rec.information82 :=
    ben_cpe_shd.g_old_rec.information82;
  End If;
  If (p_rec.information83 = hr_api.g_varchar2) then
    p_rec.information83 :=
    ben_cpe_shd.g_old_rec.information83;
  End If;
  If (p_rec.information84 = hr_api.g_varchar2) then
    p_rec.information84 :=
    ben_cpe_shd.g_old_rec.information84;
  End If;
  If (p_rec.information85 = hr_api.g_varchar2) then
    p_rec.information85 :=
    ben_cpe_shd.g_old_rec.information85;
  End If;
  If (p_rec.information86 = hr_api.g_varchar2) then
    p_rec.information86 :=
    ben_cpe_shd.g_old_rec.information86;
  End If;
  If (p_rec.information87 = hr_api.g_varchar2) then
    p_rec.information87 :=
    ben_cpe_shd.g_old_rec.information87;
  End If;
  If (p_rec.information88 = hr_api.g_varchar2) then
    p_rec.information88 :=
    ben_cpe_shd.g_old_rec.information88;
  End If;
  If (p_rec.information89 = hr_api.g_varchar2) then
    p_rec.information89 :=
    ben_cpe_shd.g_old_rec.information89;
  End If;
  If (p_rec.information90 = hr_api.g_varchar2) then
    p_rec.information90 :=
    ben_cpe_shd.g_old_rec.information90;
  End If;
  If (p_rec.information91 = hr_api.g_varchar2) then
    p_rec.information91 :=
    ben_cpe_shd.g_old_rec.information91;
  End If;
  If (p_rec.information92 = hr_api.g_varchar2) then
    p_rec.information92 :=
    ben_cpe_shd.g_old_rec.information92;
  End If;
  If (p_rec.information93 = hr_api.g_varchar2) then
    p_rec.information93 :=
    ben_cpe_shd.g_old_rec.information93;
  End If;
  If (p_rec.information94 = hr_api.g_varchar2) then
    p_rec.information94 :=
    ben_cpe_shd.g_old_rec.information94;
  End If;
  If (p_rec.information95 = hr_api.g_varchar2) then
    p_rec.information95 :=
    ben_cpe_shd.g_old_rec.information95;
  End If;
  If (p_rec.information96 = hr_api.g_varchar2) then
    p_rec.information96 :=
    ben_cpe_shd.g_old_rec.information96;
  End If;
  If (p_rec.information97 = hr_api.g_varchar2) then
    p_rec.information97 :=
    ben_cpe_shd.g_old_rec.information97;
  End If;
  If (p_rec.information98 = hr_api.g_varchar2) then
    p_rec.information98 :=
    ben_cpe_shd.g_old_rec.information98;
  End If;
  If (p_rec.information99 = hr_api.g_varchar2) then
    p_rec.information99 :=
    ben_cpe_shd.g_old_rec.information99;
  End If;
  If (p_rec.information100 = hr_api.g_varchar2) then
    p_rec.information100 :=
    ben_cpe_shd.g_old_rec.information100;
  End If;
  If (p_rec.information101 = hr_api.g_varchar2) then
    p_rec.information101 :=
    ben_cpe_shd.g_old_rec.information101;
  End If;
  If (p_rec.information102 = hr_api.g_varchar2) then
    p_rec.information102 :=
    ben_cpe_shd.g_old_rec.information102;
  End If;
  If (p_rec.information103 = hr_api.g_varchar2) then
    p_rec.information103 :=
    ben_cpe_shd.g_old_rec.information103;
  End If;
  If (p_rec.information104 = hr_api.g_varchar2) then
    p_rec.information104 :=
    ben_cpe_shd.g_old_rec.information104;
  End If;
  If (p_rec.information105 = hr_api.g_varchar2) then
    p_rec.information105 :=
    ben_cpe_shd.g_old_rec.information105;
  End If;
  If (p_rec.information106 = hr_api.g_varchar2) then
    p_rec.information106 :=
    ben_cpe_shd.g_old_rec.information106;
  End If;
  If (p_rec.information107 = hr_api.g_varchar2) then
    p_rec.information107 :=
    ben_cpe_shd.g_old_rec.information107;
  End If;
  If (p_rec.information108 = hr_api.g_varchar2) then
    p_rec.information108 :=
    ben_cpe_shd.g_old_rec.information108;
  End If;
  If (p_rec.information109 = hr_api.g_varchar2) then
    p_rec.information109 :=
    ben_cpe_shd.g_old_rec.information109;
  End If;
  If (p_rec.information110 = hr_api.g_varchar2) then
    p_rec.information110 :=
    ben_cpe_shd.g_old_rec.information110;
  End If;
  If (p_rec.information111 = hr_api.g_varchar2) then
    p_rec.information111 :=
    ben_cpe_shd.g_old_rec.information111;
  End If;
  If (p_rec.information112 = hr_api.g_varchar2) then
    p_rec.information112 :=
    ben_cpe_shd.g_old_rec.information112;
  End If;
  If (p_rec.information113 = hr_api.g_varchar2) then
    p_rec.information113 :=
    ben_cpe_shd.g_old_rec.information113;
  End If;
  If (p_rec.information114 = hr_api.g_varchar2) then
    p_rec.information114 :=
    ben_cpe_shd.g_old_rec.information114;
  End If;
  If (p_rec.information115 = hr_api.g_varchar2) then
    p_rec.information115 :=
    ben_cpe_shd.g_old_rec.information115;
  End If;
  If (p_rec.information116 = hr_api.g_varchar2) then
    p_rec.information116 :=
    ben_cpe_shd.g_old_rec.information116;
  End If;
  If (p_rec.information117 = hr_api.g_varchar2) then
    p_rec.information117 :=
    ben_cpe_shd.g_old_rec.information117;
  End If;
  If (p_rec.information118 = hr_api.g_varchar2) then
    p_rec.information118 :=
    ben_cpe_shd.g_old_rec.information118;
  End If;
  If (p_rec.information119 = hr_api.g_varchar2) then
    p_rec.information119 :=
    ben_cpe_shd.g_old_rec.information119;
  End If;
  If (p_rec.information120 = hr_api.g_varchar2) then
    p_rec.information120 :=
    ben_cpe_shd.g_old_rec.information120;
  End If;
  If (p_rec.information121 = hr_api.g_varchar2) then
    p_rec.information121 :=
    ben_cpe_shd.g_old_rec.information121;
  End If;
  If (p_rec.information122 = hr_api.g_varchar2) then
    p_rec.information122 :=
    ben_cpe_shd.g_old_rec.information122;
  End If;
  If (p_rec.information123 = hr_api.g_varchar2) then
    p_rec.information123 :=
    ben_cpe_shd.g_old_rec.information123;
  End If;
  If (p_rec.information124 = hr_api.g_varchar2) then
    p_rec.information124 :=
    ben_cpe_shd.g_old_rec.information124;
  End If;
  If (p_rec.information125 = hr_api.g_varchar2) then
    p_rec.information125 :=
    ben_cpe_shd.g_old_rec.information125;
  End If;
  If (p_rec.information126 = hr_api.g_varchar2) then
    p_rec.information126 :=
    ben_cpe_shd.g_old_rec.information126;
  End If;
  If (p_rec.information127 = hr_api.g_varchar2) then
    p_rec.information127 :=
    ben_cpe_shd.g_old_rec.information127;
  End If;
  If (p_rec.information128 = hr_api.g_varchar2) then
    p_rec.information128 :=
    ben_cpe_shd.g_old_rec.information128;
  End If;
  If (p_rec.information129 = hr_api.g_varchar2) then
    p_rec.information129 :=
    ben_cpe_shd.g_old_rec.information129;
  End If;
  If (p_rec.information130 = hr_api.g_varchar2) then
    p_rec.information130 :=
    ben_cpe_shd.g_old_rec.information130;
  End If;
  If (p_rec.information131 = hr_api.g_varchar2) then
    p_rec.information131 :=
    ben_cpe_shd.g_old_rec.information131;
  End If;
  If (p_rec.information132 = hr_api.g_varchar2) then
    p_rec.information132 :=
    ben_cpe_shd.g_old_rec.information132;
  End If;
  If (p_rec.information133 = hr_api.g_varchar2) then
    p_rec.information133 :=
    ben_cpe_shd.g_old_rec.information133;
  End If;
  If (p_rec.information134 = hr_api.g_varchar2) then
    p_rec.information134 :=
    ben_cpe_shd.g_old_rec.information134;
  End If;
  If (p_rec.information135 = hr_api.g_varchar2) then
    p_rec.information135 :=
    ben_cpe_shd.g_old_rec.information135;
  End If;
  If (p_rec.information136 = hr_api.g_varchar2) then
    p_rec.information136 :=
    ben_cpe_shd.g_old_rec.information136;
  End If;
  If (p_rec.information137 = hr_api.g_varchar2) then
    p_rec.information137 :=
    ben_cpe_shd.g_old_rec.information137;
  End If;
  If (p_rec.information138 = hr_api.g_varchar2) then
    p_rec.information138 :=
    ben_cpe_shd.g_old_rec.information138;
  End If;
  If (p_rec.information139 = hr_api.g_varchar2) then
    p_rec.information139 :=
    ben_cpe_shd.g_old_rec.information139;
  End If;
  If (p_rec.information140 = hr_api.g_varchar2) then
    p_rec.information140 :=
    ben_cpe_shd.g_old_rec.information140;
  End If;
  If (p_rec.information141 = hr_api.g_varchar2) then
    p_rec.information141 :=
    ben_cpe_shd.g_old_rec.information141;
  End If;
  If (p_rec.information142 = hr_api.g_varchar2) then
    p_rec.information142 :=
    ben_cpe_shd.g_old_rec.information142;
  End If;

  /* Extra Reserved Columns
  If (p_rec.information143 = hr_api.g_varchar2) then
    p_rec.information143 :=
    ben_cpe_shd.g_old_rec.information143;
  End If;
  If (p_rec.information144 = hr_api.g_varchar2) then
    p_rec.information144 :=
    ben_cpe_shd.g_old_rec.information144;
  End If;
  If (p_rec.information145 = hr_api.g_varchar2) then
    p_rec.information145 :=
    ben_cpe_shd.g_old_rec.information145;
  End If;
  If (p_rec.information146 = hr_api.g_varchar2) then
    p_rec.information146 :=
    ben_cpe_shd.g_old_rec.information146;
  End If;
  If (p_rec.information147 = hr_api.g_varchar2) then
    p_rec.information147 :=
    ben_cpe_shd.g_old_rec.information147;
  End If;
  If (p_rec.information148 = hr_api.g_varchar2) then
    p_rec.information148 :=
    ben_cpe_shd.g_old_rec.information148;
  End If;
  If (p_rec.information149 = hr_api.g_varchar2) then
    p_rec.information149 :=
    ben_cpe_shd.g_old_rec.information149;
  End If;
  If (p_rec.information150 = hr_api.g_varchar2) then
    p_rec.information150 :=
    ben_cpe_shd.g_old_rec.information150;
  End If;

  */

  If (p_rec.information151 = hr_api.g_varchar2) then
    p_rec.information151 :=
    ben_cpe_shd.g_old_rec.information151;
  End If;
  If (p_rec.information152 = hr_api.g_varchar2) then
    p_rec.information152 :=
    ben_cpe_shd.g_old_rec.information152;
  End If;
  If (p_rec.information153 = hr_api.g_varchar2) then
    p_rec.information153 :=
    ben_cpe_shd.g_old_rec.information153;
  End If;

  /* Extra Reserved Columns
  If (p_rec.information154 = hr_api.g_varchar2) then
    p_rec.information154 :=
    ben_cpe_shd.g_old_rec.information154;
  End If;
  If (p_rec.information155 = hr_api.g_varchar2) then
    p_rec.information155 :=
    ben_cpe_shd.g_old_rec.information155;
  End If;
  If (p_rec.information156 = hr_api.g_varchar2) then
    p_rec.information156 :=
    ben_cpe_shd.g_old_rec.information156;
  End If;
  If (p_rec.information157 = hr_api.g_varchar2) then
    p_rec.information157 :=
    ben_cpe_shd.g_old_rec.information157;
  End If;
  If (p_rec.information158 = hr_api.g_varchar2) then
    p_rec.information158 :=
    ben_cpe_shd.g_old_rec.information158;
  End If;
  If (p_rec.information159 = hr_api.g_varchar2) then
    p_rec.information159 :=
    ben_cpe_shd.g_old_rec.information159;
  End If;
  */

  If (p_rec.information160 = hr_api.g_number) then
    p_rec.information160 :=
    ben_cpe_shd.g_old_rec.information160;
  End If;
  If (p_rec.information161 = hr_api.g_number) then
    p_rec.information161 :=
    ben_cpe_shd.g_old_rec.information161;
  End If;
  If (p_rec.information162 = hr_api.g_number) then
    p_rec.information162 :=
    ben_cpe_shd.g_old_rec.information162;
  End If;

  /* Extra Reserved Columns
  If (p_rec.information163 = hr_api.g_number) then
    p_rec.information163 :=
    ben_cpe_shd.g_old_rec.information163;
  End If;
  If (p_rec.information164 = hr_api.g_number) then
    p_rec.information164 :=
    ben_cpe_shd.g_old_rec.information164;
  End If;
  If (p_rec.information165 = hr_api.g_number) then
    p_rec.information165 :=
    ben_cpe_shd.g_old_rec.information165;
  End If;
  */

  If (p_rec.information166 = hr_api.g_date) then
    p_rec.information166 :=
    ben_cpe_shd.g_old_rec.information166;
  End If;
  If (p_rec.information167 = hr_api.g_date) then
    p_rec.information167 :=
    ben_cpe_shd.g_old_rec.information167;
  End If;
  If (p_rec.information168 = hr_api.g_date) then
    p_rec.information168 :=
    ben_cpe_shd.g_old_rec.information168;
  End If;
  If (p_rec.information169 = hr_api.g_number) then
    p_rec.information169 :=
    ben_cpe_shd.g_old_rec.information169;
  End If;
  If (p_rec.information170 = hr_api.g_varchar2) then
    p_rec.information170 :=
    ben_cpe_shd.g_old_rec.information170;
  End If;

  /* Extra Reserved Columns
  If (p_rec.information171 = hr_api.g_varchar2) then
    p_rec.information171 :=
    ben_cpe_shd.g_old_rec.information171;
  End If;
  If (p_rec.information172 = hr_api.g_varchar2) then
    p_rec.information172 :=
    ben_cpe_shd.g_old_rec.information172;
  End If;
  */

  If (p_rec.information173 = hr_api.g_varchar2) then
    p_rec.information173 :=
    ben_cpe_shd.g_old_rec.information173;
  End If;
  If (p_rec.information174 = hr_api.g_number) then
    p_rec.information174 :=
    ben_cpe_shd.g_old_rec.information174;
  End If;
  If (p_rec.information175 = hr_api.g_varchar2) then
    p_rec.information175 :=
    ben_cpe_shd.g_old_rec.information175;
  End If;
  If (p_rec.information176 = hr_api.g_number) then
    p_rec.information176 :=
    ben_cpe_shd.g_old_rec.information176;
  End If;
  If (p_rec.information177 = hr_api.g_varchar2) then
    p_rec.information177 :=
    ben_cpe_shd.g_old_rec.information177;
  End If;
  If (p_rec.information178 = hr_api.g_number) then
    p_rec.information178 :=
    ben_cpe_shd.g_old_rec.information178;
  End If;
  If (p_rec.information179 = hr_api.g_varchar2) then
    p_rec.information179 :=
    ben_cpe_shd.g_old_rec.information179;
  End If;
  If (p_rec.information180 = hr_api.g_number) then
    p_rec.information180 :=
    ben_cpe_shd.g_old_rec.information180;
  End If;
  If (p_rec.information181 = hr_api.g_varchar2) then
    p_rec.information181 :=
    ben_cpe_shd.g_old_rec.information181;
  End If;
  If (p_rec.information182 = hr_api.g_varchar2) then
    p_rec.information182 :=
    ben_cpe_shd.g_old_rec.information182;
  End If;

  /* Extra Reserved Columns
  If (p_rec.information183 = hr_api.g_varchar2) then
    p_rec.information183 :=
    ben_cpe_shd.g_old_rec.information183;
  End If;
  If (p_rec.information184 = hr_api.g_varchar2) then
    p_rec.information184 :=
    ben_cpe_shd.g_old_rec.information184;
  End If;
  */

  If (p_rec.information185 = hr_api.g_varchar2) then
    p_rec.information185 :=
    ben_cpe_shd.g_old_rec.information185;
  End If;
  If (p_rec.information186 = hr_api.g_varchar2) then
    p_rec.information186 :=
    ben_cpe_shd.g_old_rec.information186;
  End If;
  If (p_rec.information187 = hr_api.g_varchar2) then
    p_rec.information187 :=
    ben_cpe_shd.g_old_rec.information187;
  End If;
  If (p_rec.information188 = hr_api.g_varchar2) then
    p_rec.information188 :=
    ben_cpe_shd.g_old_rec.information188;
  End If;

  /* Extra Reserved Columns
  If (p_rec.information189 = hr_api.g_varchar2) then
    p_rec.information189 :=
    ben_cpe_shd.g_old_rec.information189;
  End If;
  */
  If (p_rec.information190 = hr_api.g_varchar2) then
    p_rec.information190 :=
    ben_cpe_shd.g_old_rec.information190;
  End If;
  If (p_rec.information191 = hr_api.g_varchar2) then
    p_rec.information191 :=
    ben_cpe_shd.g_old_rec.information191;
  End If;
  If (p_rec.information192 = hr_api.g_varchar2) then
    p_rec.information192 :=
    ben_cpe_shd.g_old_rec.information192;
  End If;
  If (p_rec.information193 = hr_api.g_varchar2) then
    p_rec.information193 :=
    ben_cpe_shd.g_old_rec.information193;
  End If;
  If (p_rec.information194 = hr_api.g_varchar2) then
    p_rec.information194 :=
    ben_cpe_shd.g_old_rec.information194;
  End If;
  If (p_rec.information195 = hr_api.g_varchar2) then
    p_rec.information195 :=
    ben_cpe_shd.g_old_rec.information195;
  End If;
  If (p_rec.information196 = hr_api.g_varchar2) then
    p_rec.information196 :=
    ben_cpe_shd.g_old_rec.information196;
  End If;
  If (p_rec.information197 = hr_api.g_varchar2) then
    p_rec.information197 :=
    ben_cpe_shd.g_old_rec.information197;
  End If;
  If (p_rec.information198 = hr_api.g_varchar2) then
    p_rec.information198 :=
    ben_cpe_shd.g_old_rec.information198;
  End If;
  If (p_rec.information199 = hr_api.g_varchar2) then
    p_rec.information199 :=
    ben_cpe_shd.g_old_rec.information199;
  End If;

  /* Extra Reserved Columns
  If (p_rec.information200 = hr_api.g_varchar2) then
    p_rec.information200 :=
    ben_cpe_shd.g_old_rec.information200;
  End If;
  If (p_rec.information201 = hr_api.g_varchar2) then
    p_rec.information201 :=
    ben_cpe_shd.g_old_rec.information201;
  End If;
  If (p_rec.information202 = hr_api.g_varchar2) then
    p_rec.information202 :=
    ben_cpe_shd.g_old_rec.information202;
  End If;
  If (p_rec.information203 = hr_api.g_varchar2) then
    p_rec.information203 :=
    ben_cpe_shd.g_old_rec.information203;
  End If;
  If (p_rec.information204 = hr_api.g_varchar2) then
    p_rec.information204 :=
    ben_cpe_shd.g_old_rec.information204;
  End If;
  If (p_rec.information205 = hr_api.g_varchar2) then
    p_rec.information205 :=
    ben_cpe_shd.g_old_rec.information205;
  End If;
  If (p_rec.information206 = hr_api.g_varchar2) then
    p_rec.information206 :=
    ben_cpe_shd.g_old_rec.information206;
  End If;
  If (p_rec.information207 = hr_api.g_varchar2) then
    p_rec.information207 :=
    ben_cpe_shd.g_old_rec.information207;
  End If;
  If (p_rec.information208 = hr_api.g_varchar2) then
    p_rec.information208 :=
    ben_cpe_shd.g_old_rec.information208;
  End If;
  If (p_rec.information209 = hr_api.g_varchar2) then
    p_rec.information209 :=
    ben_cpe_shd.g_old_rec.information209;
  End If;
  If (p_rec.information210 = hr_api.g_varchar2) then
    p_rec.information210 :=
    ben_cpe_shd.g_old_rec.information210;
  End If;
  If (p_rec.information211 = hr_api.g_varchar2) then
    p_rec.information211 :=
    ben_cpe_shd.g_old_rec.information211;
  End If;
  If (p_rec.information212 = hr_api.g_varchar2) then
    p_rec.information212 :=
    ben_cpe_shd.g_old_rec.information212;
  End If;
  If (p_rec.information213 = hr_api.g_varchar2) then
    p_rec.information213 :=
    ben_cpe_shd.g_old_rec.information213;
  End If;
  If (p_rec.information214 = hr_api.g_varchar2) then
    p_rec.information214 :=
    ben_cpe_shd.g_old_rec.information214;
  End If;
  If (p_rec.information215 = hr_api.g_varchar2) then
    p_rec.information215 :=
    ben_cpe_shd.g_old_rec.information215;
  End If;
  */

  If (p_rec.information216 = hr_api.g_varchar2) then
    p_rec.information216 :=
    ben_cpe_shd.g_old_rec.information216;
  End If;
  If (p_rec.information217 = hr_api.g_varchar2) then
    p_rec.information217 :=
    ben_cpe_shd.g_old_rec.information217;
  End If;
  If (p_rec.information218 = hr_api.g_varchar2) then
    p_rec.information218 :=
    ben_cpe_shd.g_old_rec.information218;
  End If;
  If (p_rec.information219 = hr_api.g_varchar2) then
    p_rec.information219 :=
    ben_cpe_shd.g_old_rec.information219;
  End If;
  If (p_rec.information220 = hr_api.g_varchar2) then
    p_rec.information220 :=
    ben_cpe_shd.g_old_rec.information220;
  End If;
  If (p_rec.information221 = hr_api.g_number) then
    p_rec.information221 :=
    ben_cpe_shd.g_old_rec.information221;
  End If;
  If (p_rec.information222 = hr_api.g_number) then
    p_rec.information222 :=
    ben_cpe_shd.g_old_rec.information222;
  End If;
  If (p_rec.information223 = hr_api.g_number) then
    p_rec.information223 :=
    ben_cpe_shd.g_old_rec.information223;
  End If;
  If (p_rec.information224 = hr_api.g_number) then
    p_rec.information224 :=
    ben_cpe_shd.g_old_rec.information224;
  End If;
  If (p_rec.information225 = hr_api.g_number) then
    p_rec.information225 :=
    ben_cpe_shd.g_old_rec.information225;
  End If;
  If (p_rec.information226 = hr_api.g_number) then
    p_rec.information226 :=
    ben_cpe_shd.g_old_rec.information226;
  End If;
  If (p_rec.information227 = hr_api.g_number) then
    p_rec.information227 :=
    ben_cpe_shd.g_old_rec.information227;
  End If;
  If (p_rec.information228 = hr_api.g_number) then
    p_rec.information228 :=
    ben_cpe_shd.g_old_rec.information228;
  End If;
  If (p_rec.information229 = hr_api.g_number) then
    p_rec.information229 :=
    ben_cpe_shd.g_old_rec.information229;
  End If;
  If (p_rec.information230 = hr_api.g_number) then
    p_rec.information230 :=
    ben_cpe_shd.g_old_rec.information230;
  End If;
  If (p_rec.information231 = hr_api.g_number) then
    p_rec.information231 :=
    ben_cpe_shd.g_old_rec.information231;
  End If;
  If (p_rec.information232 = hr_api.g_number) then
    p_rec.information232 :=
    ben_cpe_shd.g_old_rec.information232;
  End If;
  If (p_rec.information233 = hr_api.g_number) then
    p_rec.information233 :=
    ben_cpe_shd.g_old_rec.information233;
  End If;
  If (p_rec.information234 = hr_api.g_number) then
    p_rec.information234 :=
    ben_cpe_shd.g_old_rec.information234;
  End If;
  If (p_rec.information235 = hr_api.g_number) then
    p_rec.information235 :=
    ben_cpe_shd.g_old_rec.information235;
  End If;
  If (p_rec.information236 = hr_api.g_number) then
    p_rec.information236 :=
    ben_cpe_shd.g_old_rec.information236;
  End If;
  If (p_rec.information237 = hr_api.g_number) then
    p_rec.information237 :=
    ben_cpe_shd.g_old_rec.information237;
  End If;
  If (p_rec.information238 = hr_api.g_number) then
    p_rec.information238 :=
    ben_cpe_shd.g_old_rec.information238;
  End If;
  If (p_rec.information239 = hr_api.g_number) then
    p_rec.information239 :=
    ben_cpe_shd.g_old_rec.information239;
  End If;
  If (p_rec.information240 = hr_api.g_number) then
    p_rec.information240 :=
    ben_cpe_shd.g_old_rec.information240;
  End If;
  If (p_rec.information241 = hr_api.g_number) then
    p_rec.information241 :=
    ben_cpe_shd.g_old_rec.information241;
  End If;
  If (p_rec.information242 = hr_api.g_number) then
    p_rec.information242 :=
    ben_cpe_shd.g_old_rec.information242;
  End If;
  If (p_rec.information243 = hr_api.g_number) then
    p_rec.information243 :=
    ben_cpe_shd.g_old_rec.information243;
  End If;
  If (p_rec.information244 = hr_api.g_number) then
    p_rec.information244 :=
    ben_cpe_shd.g_old_rec.information244;
  End If;
  If (p_rec.information245 = hr_api.g_number) then
    p_rec.information245 :=
    ben_cpe_shd.g_old_rec.information245;
  End If;
  If (p_rec.information246 = hr_api.g_number) then
    p_rec.information246 :=
    ben_cpe_shd.g_old_rec.information246;
  End If;
  If (p_rec.information247 = hr_api.g_number) then
    p_rec.information247 :=
    ben_cpe_shd.g_old_rec.information247;
  End If;
  If (p_rec.information248 = hr_api.g_number) then
    p_rec.information248 :=
    ben_cpe_shd.g_old_rec.information248;
  End If;
  If (p_rec.information249 = hr_api.g_number) then
    p_rec.information249 :=
    ben_cpe_shd.g_old_rec.information249;
  End If;
  If (p_rec.information250 = hr_api.g_number) then
    p_rec.information250 :=
    ben_cpe_shd.g_old_rec.information250;
  End If;
  If (p_rec.information251 = hr_api.g_number) then
    p_rec.information251 :=
    ben_cpe_shd.g_old_rec.information251;
  End If;
  If (p_rec.information252 = hr_api.g_number) then
    p_rec.information252 :=
    ben_cpe_shd.g_old_rec.information252;
  End If;
  If (p_rec.information253 = hr_api.g_number) then
    p_rec.information253 :=
    ben_cpe_shd.g_old_rec.information253;
  End If;
  If (p_rec.information254 = hr_api.g_number) then
    p_rec.information254 :=
    ben_cpe_shd.g_old_rec.information254;
  End If;
  If (p_rec.information255 = hr_api.g_number) then
    p_rec.information255 :=
    ben_cpe_shd.g_old_rec.information255;
  End If;
  If (p_rec.information256 = hr_api.g_number) then
    p_rec.information256 :=
    ben_cpe_shd.g_old_rec.information256;
  End If;
  If (p_rec.information257 = hr_api.g_number) then
    p_rec.information257 :=
    ben_cpe_shd.g_old_rec.information257;
  End If;
  If (p_rec.information258 = hr_api.g_number) then
    p_rec.information258 :=
    ben_cpe_shd.g_old_rec.information258;
  End If;
  If (p_rec.information259 = hr_api.g_number) then
    p_rec.information259 :=
    ben_cpe_shd.g_old_rec.information259;
  End If;
  If (p_rec.information260 = hr_api.g_number) then
    p_rec.information260 :=
    ben_cpe_shd.g_old_rec.information260;
  End If;
  If (p_rec.information261 = hr_api.g_number) then
    p_rec.information261 :=
    ben_cpe_shd.g_old_rec.information261;
  End If;
  If (p_rec.information262 = hr_api.g_number) then
    p_rec.information262 :=
    ben_cpe_shd.g_old_rec.information262;
  End If;
  If (p_rec.information263 = hr_api.g_number) then
    p_rec.information263 :=
    ben_cpe_shd.g_old_rec.information263;
  End If;
  If (p_rec.information264 = hr_api.g_number) then
    p_rec.information264 :=
    ben_cpe_shd.g_old_rec.information264;
  End If;
  If (p_rec.information265 = hr_api.g_number) then
    p_rec.information265 :=
    ben_cpe_shd.g_old_rec.information265;
  End If;
  If (p_rec.information266 = hr_api.g_number) then
    p_rec.information266 :=
    ben_cpe_shd.g_old_rec.information266;
  End If;
  If (p_rec.information267 = hr_api.g_number) then
    p_rec.information267 :=
    ben_cpe_shd.g_old_rec.information267;
  End If;
  If (p_rec.information268 = hr_api.g_number) then
    p_rec.information268 :=
    ben_cpe_shd.g_old_rec.information268;
  End If;
  If (p_rec.information269 = hr_api.g_number) then
    p_rec.information269 :=
    ben_cpe_shd.g_old_rec.information269;
  End If;
  If (p_rec.information270 = hr_api.g_number) then
    p_rec.information270 :=
    ben_cpe_shd.g_old_rec.information270;
  End If;
  If (p_rec.information271 = hr_api.g_number) then
    p_rec.information271 :=
    ben_cpe_shd.g_old_rec.information271;
  End If;
  If (p_rec.information272 = hr_api.g_number) then
    p_rec.information272 :=
    ben_cpe_shd.g_old_rec.information272;
  End If;
  If (p_rec.information273 = hr_api.g_number) then
    p_rec.information273 :=
    ben_cpe_shd.g_old_rec.information273;
  End If;
  If (p_rec.information274 = hr_api.g_number) then
    p_rec.information274 :=
    ben_cpe_shd.g_old_rec.information274;
  End If;
  If (p_rec.information275 = hr_api.g_number) then
    p_rec.information275 :=
    ben_cpe_shd.g_old_rec.information275;
  End If;
  If (p_rec.information276 = hr_api.g_number) then
    p_rec.information276 :=
    ben_cpe_shd.g_old_rec.information276;
  End If;
  If (p_rec.information277 = hr_api.g_number) then
    p_rec.information277 :=
    ben_cpe_shd.g_old_rec.information277;
  End If;
  If (p_rec.information278 = hr_api.g_number) then
    p_rec.information278 :=
    ben_cpe_shd.g_old_rec.information278;
  End If;
  If (p_rec.information279 = hr_api.g_number) then
    p_rec.information279 :=
    ben_cpe_shd.g_old_rec.information279;
  End If;
  If (p_rec.information280 = hr_api.g_number) then
    p_rec.information280 :=
    ben_cpe_shd.g_old_rec.information280;
  End If;
  If (p_rec.information281 = hr_api.g_number) then
    p_rec.information281 :=
    ben_cpe_shd.g_old_rec.information281;
  End If;
  If (p_rec.information282 = hr_api.g_number) then
    p_rec.information282 :=
    ben_cpe_shd.g_old_rec.information282;
  End If;
  If (p_rec.information283 = hr_api.g_number) then
    p_rec.information283 :=
    ben_cpe_shd.g_old_rec.information283;
  End If;
  If (p_rec.information284 = hr_api.g_number) then
    p_rec.information284 :=
    ben_cpe_shd.g_old_rec.information284;
  End If;
  If (p_rec.information285 = hr_api.g_number) then
    p_rec.information285 :=
    ben_cpe_shd.g_old_rec.information285;
  End If;
  If (p_rec.information286 = hr_api.g_number) then
    p_rec.information286 :=
    ben_cpe_shd.g_old_rec.information286;
  End If;
  If (p_rec.information287 = hr_api.g_number) then
    p_rec.information287 :=
    ben_cpe_shd.g_old_rec.information287;
  End If;
  If (p_rec.information288 = hr_api.g_number) then
    p_rec.information288 :=
    ben_cpe_shd.g_old_rec.information288;
  End If;
  If (p_rec.information289 = hr_api.g_number) then
    p_rec.information289 :=
    ben_cpe_shd.g_old_rec.information289;
  End If;
  If (p_rec.information290 = hr_api.g_number) then
    p_rec.information290 :=
    ben_cpe_shd.g_old_rec.information290;
  End If;
  If (p_rec.information291 = hr_api.g_number) then
    p_rec.information291 :=
    ben_cpe_shd.g_old_rec.information291;
  End If;
  If (p_rec.information292 = hr_api.g_number) then
    p_rec.information292 :=
    ben_cpe_shd.g_old_rec.information292;
  End If;
  If (p_rec.information293 = hr_api.g_number) then
    p_rec.information293 :=
    ben_cpe_shd.g_old_rec.information293;
  End If;
  If (p_rec.information294 = hr_api.g_number) then
    p_rec.information294 :=
    ben_cpe_shd.g_old_rec.information294;
  End If;
  If (p_rec.information295 = hr_api.g_number) then
    p_rec.information295 :=
    ben_cpe_shd.g_old_rec.information295;
  End If;
  If (p_rec.information296 = hr_api.g_number) then
    p_rec.information296 :=
    ben_cpe_shd.g_old_rec.information296;
  End If;
  If (p_rec.information297 = hr_api.g_number) then
    p_rec.information297 :=
    ben_cpe_shd.g_old_rec.information297;
  End If;
  If (p_rec.information298 = hr_api.g_number) then
    p_rec.information298 :=
    ben_cpe_shd.g_old_rec.information298;
  End If;
  If (p_rec.information299 = hr_api.g_number) then
    p_rec.information299 :=
    ben_cpe_shd.g_old_rec.information299;
  End If;
  If (p_rec.information300 = hr_api.g_number) then
    p_rec.information300 :=
    ben_cpe_shd.g_old_rec.information300;
  End If;
  If (p_rec.information301 = hr_api.g_number) then
    p_rec.information301 :=
    ben_cpe_shd.g_old_rec.information301;
  End If;
  If (p_rec.information302 = hr_api.g_number) then
    p_rec.information302 :=
    ben_cpe_shd.g_old_rec.information302;
  End If;
  If (p_rec.information303 = hr_api.g_number) then
    p_rec.information303 :=
    ben_cpe_shd.g_old_rec.information303;
  End If;
  If (p_rec.information304 = hr_api.g_number) then
    p_rec.information304 :=
    ben_cpe_shd.g_old_rec.information304;
  End If;

  /* Extra Reserved Columns
  If (p_rec.information305 = hr_api.g_number) then
    p_rec.information305 :=
    ben_cpe_shd.g_old_rec.information305;
  End If;
  */

  If (p_rec.information306 = hr_api.g_date) then
    p_rec.information306 :=
    ben_cpe_shd.g_old_rec.information306;
  End If;
  If (p_rec.information307 = hr_api.g_date) then
    p_rec.information307 :=
    ben_cpe_shd.g_old_rec.information307;
  End If;
  If (p_rec.information308 = hr_api.g_date) then
    p_rec.information308 :=
    ben_cpe_shd.g_old_rec.information308;
  End If;
  If (p_rec.information309 = hr_api.g_date) then
    p_rec.information309 :=
    ben_cpe_shd.g_old_rec.information309;
  End If;
  If (p_rec.information310 = hr_api.g_date) then
    p_rec.information310 :=
    ben_cpe_shd.g_old_rec.information310;
  End If;
  If (p_rec.information311 = hr_api.g_date) then
    p_rec.information311 :=
    ben_cpe_shd.g_old_rec.information311;
  End If;
  If (p_rec.information312 = hr_api.g_date) then
    p_rec.information312 :=
    ben_cpe_shd.g_old_rec.information312;
  End If;
  If (p_rec.information313 = hr_api.g_date) then
    p_rec.information313 :=
    ben_cpe_shd.g_old_rec.information313;
  End If;
  If (p_rec.information314 = hr_api.g_date) then
    p_rec.information314 :=
    ben_cpe_shd.g_old_rec.information314;
  End If;
  If (p_rec.information315 = hr_api.g_date) then
    p_rec.information315 :=
    ben_cpe_shd.g_old_rec.information315;
  End If;
  If (p_rec.information316 = hr_api.g_date) then
    p_rec.information316 :=
    ben_cpe_shd.g_old_rec.information316;
  End If;
  If (p_rec.information317 = hr_api.g_date) then
    p_rec.information317 :=
    ben_cpe_shd.g_old_rec.information317;
  End If;
  If (p_rec.information318 = hr_api.g_date) then
    p_rec.information318 :=
    ben_cpe_shd.g_old_rec.information318;
  End If;
  If (p_rec.information319 = hr_api.g_date) then
    p_rec.information319 :=
    ben_cpe_shd.g_old_rec.information319;
  End If;
  If (p_rec.information320 = hr_api.g_date) then
    p_rec.information320 :=
    ben_cpe_shd.g_old_rec.information320;
  End If;

  /* Extra Reserved Columns
  If (p_rec.information321 = hr_api.g_date) then
    p_rec.information321 :=
    ben_cpe_shd.g_old_rec.information321;
  End If;
  If (p_rec.information322 = hr_api.g_date) then
    p_rec.information322 :=
    ben_cpe_shd.g_old_rec.information322;
  End If;
  */

  /*
  If (p_rec.information323 = hr_api.g_long) then
    p_rec.information323 :=
    ben_cpe_shd.g_old_rec.information323;
  End If;
  */
  If (p_rec.datetrack_mode = hr_api.g_varchar2) then
    p_rec.datetrack_mode :=
    ben_cpe_shd.g_old_rec.datetrack_mode;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ben_cpe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_cpe_shd.lck
    (p_rec.copy_entity_result_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_cpe_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ben_cpe_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ben_cpe_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ben_cpe_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_copy_entity_result_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_copy_entity_txn_id           in     number    default hr_api.g_number
  ,p_result_type_cd               in     varchar2  default hr_api.g_varchar2
  ,p_src_copy_entity_result_id    in     number    default hr_api.g_number
  ,p_number_of_copies             in     number    default hr_api.g_number
  ,p_mirror_entity_result_id      in     number    default hr_api.g_number
  ,p_mirror_src_entity_result_id  in     number    default hr_api.g_number
  ,p_parent_entity_result_id      in     number    default hr_api.g_number
  ,p_pd_mr_src_entity_result_id   in     number    default hr_api.g_number
  ,p_pd_parent_entity_result_id   in     number    default hr_api.g_number
  ,p_gs_mr_src_entity_result_id   in     number    default hr_api.g_number
  ,p_gs_parent_entity_result_id   in     number    default hr_api.g_number
  ,p_table_name                   in     varchar2  default hr_api.g_varchar2
  ,p_table_alias                  in     varchar2  default hr_api.g_varchar2
  ,p_table_route_id               in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_dml_operation                in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     number    default hr_api.g_number
  ,p_information2                 in     date      default hr_api.g_date
  ,p_information3                 in     date      default hr_api.g_date
  ,p_information4                 in     number    default hr_api.g_number
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     date      default hr_api.g_date
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_information31                in     varchar2  default hr_api.g_varchar2
  ,p_information32                in     varchar2  default hr_api.g_varchar2
  ,p_information33                in     varchar2  default hr_api.g_varchar2
  ,p_information34                in     varchar2  default hr_api.g_varchar2
  ,p_information35                in     varchar2  default hr_api.g_varchar2
  ,p_information36                in     varchar2  default hr_api.g_varchar2
  ,p_information37                in     varchar2  default hr_api.g_varchar2
  ,p_information38                in     varchar2  default hr_api.g_varchar2
  ,p_information39                in     varchar2  default hr_api.g_varchar2
  ,p_information40                in     varchar2  default hr_api.g_varchar2
  ,p_information41                in     varchar2  default hr_api.g_varchar2
  ,p_information42                in     varchar2  default hr_api.g_varchar2
  ,p_information43                in     varchar2  default hr_api.g_varchar2
  ,p_information44                in     varchar2  default hr_api.g_varchar2
  ,p_information45                in     varchar2  default hr_api.g_varchar2
  ,p_information46                in     varchar2  default hr_api.g_varchar2
  ,p_information47                in     varchar2  default hr_api.g_varchar2
  ,p_information48                in     varchar2  default hr_api.g_varchar2
  ,p_information49                in     varchar2  default hr_api.g_varchar2
  ,p_information50                in     varchar2  default hr_api.g_varchar2
  ,p_information51                in     varchar2  default hr_api.g_varchar2
  ,p_information52                in     varchar2  default hr_api.g_varchar2
  ,p_information53                in     varchar2  default hr_api.g_varchar2
  ,p_information54                in     varchar2  default hr_api.g_varchar2
  ,p_information55                in     varchar2  default hr_api.g_varchar2
  ,p_information56                in     varchar2  default hr_api.g_varchar2
  ,p_information57                in     varchar2  default hr_api.g_varchar2
  ,p_information58                in     varchar2  default hr_api.g_varchar2
  ,p_information59                in     varchar2  default hr_api.g_varchar2
  ,p_information60                in     varchar2  default hr_api.g_varchar2
  ,p_information61                in     varchar2  default hr_api.g_varchar2
  ,p_information62                in     varchar2  default hr_api.g_varchar2
  ,p_information63                in     varchar2  default hr_api.g_varchar2
  ,p_information64                in     varchar2  default hr_api.g_varchar2
  ,p_information65                in     varchar2  default hr_api.g_varchar2
  ,p_information66                in     varchar2  default hr_api.g_varchar2
  ,p_information67                in     varchar2  default hr_api.g_varchar2
  ,p_information68                in     varchar2  default hr_api.g_varchar2
  ,p_information69                in     varchar2  default hr_api.g_varchar2
  ,p_information70                in     varchar2  default hr_api.g_varchar2
  ,p_information71                in     varchar2  default hr_api.g_varchar2
  ,p_information72                in     varchar2  default hr_api.g_varchar2
  ,p_information73                in     varchar2  default hr_api.g_varchar2
  ,p_information74                in     varchar2  default hr_api.g_varchar2
  ,p_information75                in     varchar2  default hr_api.g_varchar2
  ,p_information76                in     varchar2  default hr_api.g_varchar2
  ,p_information77                in     varchar2  default hr_api.g_varchar2
  ,p_information78                in     varchar2  default hr_api.g_varchar2
  ,p_information79                in     varchar2  default hr_api.g_varchar2
  ,p_information80                in     varchar2  default hr_api.g_varchar2
  ,p_information81                in     varchar2  default hr_api.g_varchar2
  ,p_information82                in     varchar2  default hr_api.g_varchar2
  ,p_information83                in     varchar2  default hr_api.g_varchar2
  ,p_information84                in     varchar2  default hr_api.g_varchar2
  ,p_information85                in     varchar2  default hr_api.g_varchar2
  ,p_information86                in     varchar2  default hr_api.g_varchar2
  ,p_information87                in     varchar2  default hr_api.g_varchar2
  ,p_information88                in     varchar2  default hr_api.g_varchar2
  ,p_information89                in     varchar2  default hr_api.g_varchar2
  ,p_information90                in     varchar2  default hr_api.g_varchar2
  ,p_information91                in     varchar2  default hr_api.g_varchar2
  ,p_information92                in     varchar2  default hr_api.g_varchar2
  ,p_information93                in     varchar2  default hr_api.g_varchar2
  ,p_information94                in     varchar2  default hr_api.g_varchar2
  ,p_information95                in     varchar2  default hr_api.g_varchar2
  ,p_information96                in     varchar2  default hr_api.g_varchar2
  ,p_information97                in     varchar2  default hr_api.g_varchar2
  ,p_information98                in     varchar2  default hr_api.g_varchar2
  ,p_information99                in     varchar2  default hr_api.g_varchar2
  ,p_information100               in     varchar2  default hr_api.g_varchar2
  ,p_information101               in     varchar2  default hr_api.g_varchar2
  ,p_information102               in     varchar2  default hr_api.g_varchar2
  ,p_information103               in     varchar2  default hr_api.g_varchar2
  ,p_information104               in     varchar2  default hr_api.g_varchar2
  ,p_information105               in     varchar2  default hr_api.g_varchar2
  ,p_information106               in     varchar2  default hr_api.g_varchar2
  ,p_information107               in     varchar2  default hr_api.g_varchar2
  ,p_information108               in     varchar2  default hr_api.g_varchar2
  ,p_information109               in     varchar2  default hr_api.g_varchar2
  ,p_information110               in     varchar2  default hr_api.g_varchar2
  ,p_information111               in     varchar2  default hr_api.g_varchar2
  ,p_information112               in     varchar2  default hr_api.g_varchar2
  ,p_information113               in     varchar2  default hr_api.g_varchar2
  ,p_information114               in     varchar2  default hr_api.g_varchar2
  ,p_information115               in     varchar2  default hr_api.g_varchar2
  ,p_information116               in     varchar2  default hr_api.g_varchar2
  ,p_information117               in     varchar2  default hr_api.g_varchar2
  ,p_information118               in     varchar2  default hr_api.g_varchar2
  ,p_information119               in     varchar2  default hr_api.g_varchar2
  ,p_information120               in     varchar2  default hr_api.g_varchar2
  ,p_information121               in     varchar2  default hr_api.g_varchar2
  ,p_information122               in     varchar2  default hr_api.g_varchar2
  ,p_information123               in     varchar2  default hr_api.g_varchar2
  ,p_information124               in     varchar2  default hr_api.g_varchar2
  ,p_information125               in     varchar2  default hr_api.g_varchar2
  ,p_information126               in     varchar2  default hr_api.g_varchar2
  ,p_information127               in     varchar2  default hr_api.g_varchar2
  ,p_information128               in     varchar2  default hr_api.g_varchar2
  ,p_information129               in     varchar2  default hr_api.g_varchar2
  ,p_information130               in     varchar2  default hr_api.g_varchar2
  ,p_information131               in     varchar2  default hr_api.g_varchar2
  ,p_information132               in     varchar2  default hr_api.g_varchar2
  ,p_information133               in     varchar2  default hr_api.g_varchar2
  ,p_information134               in     varchar2  default hr_api.g_varchar2
  ,p_information135               in     varchar2  default hr_api.g_varchar2
  ,p_information136               in     varchar2  default hr_api.g_varchar2
  ,p_information137               in     varchar2  default hr_api.g_varchar2
  ,p_information138               in     varchar2  default hr_api.g_varchar2
  ,p_information139               in     varchar2  default hr_api.g_varchar2
  ,p_information140               in     varchar2  default hr_api.g_varchar2
  ,p_information141               in     varchar2  default hr_api.g_varchar2
  ,p_information142               in     varchar2  default hr_api.g_varchar2

  /* Extra Reserved Columns
  ,p_information143               in     varchar2  default hr_api.g_varchar2
  ,p_information144               in     varchar2  default hr_api.g_varchar2
  ,p_information145               in     varchar2  default hr_api.g_varchar2
  ,p_information146               in     varchar2  default hr_api.g_varchar2
  ,p_information147               in     varchar2  default hr_api.g_varchar2
  ,p_information148               in     varchar2  default hr_api.g_varchar2
  ,p_information149               in     varchar2  default hr_api.g_varchar2
  ,p_information150               in     varchar2  default hr_api.g_varchar2
  */
  ,p_information151               in     varchar2  default hr_api.g_varchar2
  ,p_information152               in     varchar2  default hr_api.g_varchar2
  ,p_information153               in     varchar2  default hr_api.g_varchar2

  /* Extra Reserved Columns
  ,p_information154               in     varchar2  default hr_api.g_varchar2
  ,p_information155               in     varchar2  default hr_api.g_varchar2
  ,p_information156               in     varchar2  default hr_api.g_varchar2
  ,p_information157               in     varchar2  default hr_api.g_varchar2
  ,p_information158               in     varchar2  default hr_api.g_varchar2
  ,p_information159               in     varchar2  default hr_api.g_varchar2
  */
  ,p_information160               in     number    default hr_api.g_number
  ,p_information161               in     number    default hr_api.g_number
  ,p_information162               in     number    default hr_api.g_number

  /* Extra Reserved Columns
  ,p_information163               in     number    default hr_api.g_number
  ,p_information164               in     number    default hr_api.g_number
  ,p_information165               in     number    default hr_api.g_number
  */
  ,p_information166               in     date      default hr_api.g_date
  ,p_information167               in     date      default hr_api.g_date
  ,p_information168               in     date      default hr_api.g_date
  ,p_information169               in     number    default hr_api.g_number
  ,p_information170               in     varchar2  default hr_api.g_varchar2

  /* Extra Reserved Columns
  ,p_information171               in     varchar2  default hr_api.g_varchar2
  ,p_information172               in     varchar2  default hr_api.g_varchar2
  */
  ,p_information173               in     varchar2  default hr_api.g_varchar2
  ,p_information174               in     number    default hr_api.g_number
  ,p_information175               in     varchar2  default hr_api.g_varchar2
  ,p_information176               in     number    default hr_api.g_number
  ,p_information177               in     varchar2  default hr_api.g_varchar2
  ,p_information178               in     number    default hr_api.g_number
  ,p_information179               in     varchar2  default hr_api.g_varchar2
  ,p_information180               in     number    default hr_api.g_number
  ,p_information181               in     varchar2  default hr_api.g_varchar2
  ,p_information182               in     varchar2  default hr_api.g_varchar2

  /* Extra Reserved Columns
  ,p_information183               in     varchar2  default hr_api.g_varchar2
  ,p_information184               in     varchar2  default hr_api.g_varchar2
  */
  ,p_information185               in     varchar2  default hr_api.g_varchar2
  ,p_information186               in     varchar2  default hr_api.g_varchar2
  ,p_information187               in     varchar2  default hr_api.g_varchar2
  ,p_information188               in     varchar2  default hr_api.g_varchar2

  /* Extra Reserved Columns
  ,p_information189               in     varchar2  default hr_api.g_varchar2
  */
  ,p_information190               in     varchar2  default hr_api.g_varchar2
  ,p_information191               in     varchar2  default hr_api.g_varchar2
  ,p_information192               in     varchar2  default hr_api.g_varchar2
  ,p_information193               in     varchar2  default hr_api.g_varchar2
  ,p_information194               in     varchar2  default hr_api.g_varchar2
  ,p_information195               in     varchar2  default hr_api.g_varchar2
  ,p_information196               in     varchar2  default hr_api.g_varchar2
  ,p_information197               in     varchar2  default hr_api.g_varchar2
  ,p_information198               in     varchar2  default hr_api.g_varchar2
  ,p_information199               in     varchar2  default hr_api.g_varchar2

  /* Extra Reserved Columns
  ,p_information200               in     varchar2  default hr_api.g_varchar2
  ,p_information201               in     varchar2  default hr_api.g_varchar2
  ,p_information202               in     varchar2  default hr_api.g_varchar2
  ,p_information203               in     varchar2  default hr_api.g_varchar2
  ,p_information204               in     varchar2  default hr_api.g_varchar2
  ,p_information205               in     varchar2  default hr_api.g_varchar2
  ,p_information206               in     varchar2  default hr_api.g_varchar2
  ,p_information207               in     varchar2  default hr_api.g_varchar2
  ,p_information208               in     varchar2  default hr_api.g_varchar2
  ,p_information209               in     varchar2  default hr_api.g_varchar2
  ,p_information210               in     varchar2  default hr_api.g_varchar2
  ,p_information211               in     varchar2  default hr_api.g_varchar2
  ,p_information212               in     varchar2  default hr_api.g_varchar2
  ,p_information213               in     varchar2  default hr_api.g_varchar2
  ,p_information214               in     varchar2  default hr_api.g_varchar2
  ,p_information215               in     varchar2  default hr_api.g_varchar2
  */
  ,p_information216               in     varchar2  default hr_api.g_varchar2
  ,p_information217               in     varchar2  default hr_api.g_varchar2
  ,p_information218               in     varchar2  default hr_api.g_varchar2
  ,p_information219               in     varchar2  default hr_api.g_varchar2
  ,p_information220               in     varchar2  default hr_api.g_varchar2
  ,p_information221               in     number    default hr_api.g_number
  ,p_information222               in     number    default hr_api.g_number
  ,p_information223               in     number    default hr_api.g_number
  ,p_information224               in     number    default hr_api.g_number
  ,p_information225               in     number    default hr_api.g_number
  ,p_information226               in     number    default hr_api.g_number
  ,p_information227               in     number    default hr_api.g_number
  ,p_information228               in     number    default hr_api.g_number
  ,p_information229               in     number    default hr_api.g_number
  ,p_information230               in     number    default hr_api.g_number
  ,p_information231               in     number    default hr_api.g_number
  ,p_information232               in     number    default hr_api.g_number
  ,p_information233               in     number    default hr_api.g_number
  ,p_information234               in     number    default hr_api.g_number
  ,p_information235               in     number    default hr_api.g_number
  ,p_information236               in     number    default hr_api.g_number
  ,p_information237               in     number    default hr_api.g_number
  ,p_information238               in     number    default hr_api.g_number
  ,p_information239               in     number    default hr_api.g_number
  ,p_information240               in     number    default hr_api.g_number
  ,p_information241               in     number    default hr_api.g_number
  ,p_information242               in     number    default hr_api.g_number
  ,p_information243               in     number    default hr_api.g_number
  ,p_information244               in     number    default hr_api.g_number
  ,p_information245               in     number    default hr_api.g_number
  ,p_information246               in     number    default hr_api.g_number
  ,p_information247               in     number    default hr_api.g_number
  ,p_information248               in     number    default hr_api.g_number
  ,p_information249               in     number    default hr_api.g_number
  ,p_information250               in     number    default hr_api.g_number
  ,p_information251               in     number    default hr_api.g_number
  ,p_information252               in     number    default hr_api.g_number
  ,p_information253               in     number    default hr_api.g_number
  ,p_information254               in     number    default hr_api.g_number
  ,p_information255               in     number    default hr_api.g_number
  ,p_information256               in     number    default hr_api.g_number
  ,p_information257               in     number    default hr_api.g_number
  ,p_information258               in     number    default hr_api.g_number
  ,p_information259               in     number    default hr_api.g_number
  ,p_information260               in     number    default hr_api.g_number
  ,p_information261               in     number    default hr_api.g_number
  ,p_information262               in     number    default hr_api.g_number
  ,p_information263               in     number    default hr_api.g_number
  ,p_information264               in     number    default hr_api.g_number
  ,p_information265               in     number    default hr_api.g_number
  ,p_information266               in     number    default hr_api.g_number
  ,p_information267               in     number    default hr_api.g_number
  ,p_information268               in     number    default hr_api.g_number
  ,p_information269               in     number    default hr_api.g_number
  ,p_information270               in     number    default hr_api.g_number
  ,p_information271               in     number    default hr_api.g_number
  ,p_information272               in     number    default hr_api.g_number
  ,p_information273               in     number    default hr_api.g_number
  ,p_information274               in     number    default hr_api.g_number
  ,p_information275               in     number    default hr_api.g_number
  ,p_information276               in     number    default hr_api.g_number
  ,p_information277               in     number    default hr_api.g_number
  ,p_information278               in     number    default hr_api.g_number
  ,p_information279               in     number    default hr_api.g_number
  ,p_information280               in     number    default hr_api.g_number
  ,p_information281               in     number    default hr_api.g_number
  ,p_information282               in     number    default hr_api.g_number
  ,p_information283               in     number    default hr_api.g_number
  ,p_information284               in     number    default hr_api.g_number
  ,p_information285               in     number    default hr_api.g_number
  ,p_information286               in     number    default hr_api.g_number
  ,p_information287               in     number    default hr_api.g_number
  ,p_information288               in     number    default hr_api.g_number
  ,p_information289               in     number    default hr_api.g_number
  ,p_information290               in     number    default hr_api.g_number
  ,p_information291               in     number    default hr_api.g_number
  ,p_information292               in     number    default hr_api.g_number
  ,p_information293               in     number    default hr_api.g_number
  ,p_information294               in     number    default hr_api.g_number
  ,p_information295               in     number    default hr_api.g_number
  ,p_information296               in     number    default hr_api.g_number
  ,p_information297               in     number    default hr_api.g_number
  ,p_information298               in     number    default hr_api.g_number
  ,p_information299               in     number    default hr_api.g_number
  ,p_information300               in     number    default hr_api.g_number
  ,p_information301               in     number    default hr_api.g_number
  ,p_information302               in     number    default hr_api.g_number
  ,p_information303               in     number    default hr_api.g_number
  ,p_information304               in     number    default hr_api.g_number

  /* Extra Reserved Columns
  ,p_information305               in     number    default hr_api.g_number
  */
  ,p_information306               in     date      default hr_api.g_date
  ,p_information307               in     date      default hr_api.g_date
  ,p_information308               in     date      default hr_api.g_date
  ,p_information309               in     date      default hr_api.g_date
  ,p_information310               in     date      default hr_api.g_date
  ,p_information311               in     date      default hr_api.g_date
  ,p_information312               in     date      default hr_api.g_date
  ,p_information313               in     date      default hr_api.g_date
  ,p_information314               in     date      default hr_api.g_date
  ,p_information315               in     date      default hr_api.g_date
  ,p_information316               in     date      default hr_api.g_date
  ,p_information317               in     date      default hr_api.g_date
  ,p_information318               in     date      default hr_api.g_date
  ,p_information319               in     date      default hr_api.g_date
  ,p_information320               in     date      default hr_api.g_date

  /* Extra Reserved Columns
  ,p_information321               in     date      default hr_api.g_date
  ,p_information322               in     date      default hr_api.g_date
  */
  ,p_information323               in     long
  ,p_datetrack_mode               in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   ben_cpe_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_cpe_shd.convert_args
  (p_copy_entity_result_id
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
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ben_cpe_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_cpe_upd;

/
