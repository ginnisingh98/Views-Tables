--------------------------------------------------------
--  DDL for Package Body BEN_CPE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPE_SHD" as
/* $Header: becperhi.pkb 120.0 2005/05/28 01:12:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpe_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'BEN_COPY_ENTITY_RESULTS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_copy_entity_result_id                in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       copy_entity_result_id
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
    from        ben_copy_entity_results
    where       copy_entity_result_id = p_copy_entity_result_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_copy_entity_result_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_copy_entity_result_id
        = ben_cpe_shd.g_old_rec.copy_entity_result_id and
        p_object_version_number
        = ben_cpe_shd.g_old_rec.object_version_number
       ) Then
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
      Fetch C_Sel1 Into ben_cpe_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> ben_cpe_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_copy_entity_result_id                in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       copy_entity_result_id
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
    from        ben_copy_entity_results
    where       copy_entity_result_id = p_copy_entity_result_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'COPY_ENTITY_RESULT_ID'
    ,p_argument_value     => p_copy_entity_result_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_cpe_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> ben_cpe_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_copy_entity_results');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
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
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.copy_entity_result_id            := p_copy_entity_result_id;
  l_rec.copy_entity_txn_id               := p_copy_entity_txn_id;
  l_rec.src_copy_entity_result_id        := p_src_copy_entity_result_id;
  l_rec.result_type_cd                   := p_result_type_cd;
  l_rec.number_of_copies                 := p_number_of_copies;
  l_rec.mirror_entity_result_id          := p_mirror_entity_result_id;
  l_rec.mirror_src_entity_result_id      := p_mirror_src_entity_result_id;
  l_rec.parent_entity_result_id          := p_parent_entity_result_id;
  l_rec.pd_mirror_src_entity_result_id   := p_pd_mr_src_entity_result_id;
  l_rec.pd_parent_entity_result_id       := p_pd_parent_entity_result_id;
  l_rec.gs_mirror_src_entity_result_id   := p_gs_mr_src_entity_result_id;
  l_rec.gs_parent_entity_result_id       := p_gs_parent_entity_result_id;
  l_rec.table_name                       := p_table_name;
  l_rec.table_alias                      := p_table_alias;
  l_rec.table_route_id                   := p_table_route_id;
  l_rec.status                           := p_status;
  l_rec.dml_operation                    := p_dml_operation;
  l_rec.information_category             := p_information_category;
  l_rec.information1                     := p_information1;
  l_rec.information2                     := p_information2;
  l_rec.information3                     := p_information3;
  l_rec.information4                     := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6                     := p_information6;
  l_rec.information7                     := p_information7;
  l_rec.information8                     := p_information8;
  l_rec.information9                     := p_information9;
  l_rec.information10                    := p_information10;
  l_rec.information11                    := p_information11;
  l_rec.information12                    := p_information12;
  l_rec.information13                    := p_information13;
  l_rec.information14                    := p_information14;
  l_rec.information15                    := p_information15;
  l_rec.information16                    := p_information16;
  l_rec.information17                    := p_information17;
  l_rec.information18                    := p_information18;
  l_rec.information19                    := p_information19;
  l_rec.information20                    := p_information20;
  l_rec.information21                    := p_information21;
  l_rec.information22                    := p_information22;
  l_rec.information23                    := p_information23;
  l_rec.information24                    := p_information24;
  l_rec.information25                    := p_information25;
  l_rec.information26                    := p_information26;
  l_rec.information27                    := p_information27;
  l_rec.information28                    := p_information28;
  l_rec.information29                    := p_information29;
  l_rec.information30                    := p_information30;
  l_rec.information31                    := p_information31;
  l_rec.information32                    := p_information32;
  l_rec.information33                    := p_information33;
  l_rec.information34                    := p_information34;
  l_rec.information35                    := p_information35;
  l_rec.information36                    := p_information36;
  l_rec.information37                    := p_information37;
  l_rec.information38                    := p_information38;
  l_rec.information39                    := p_information39;
  l_rec.information40                    := p_information40;
  l_rec.information41                    := p_information41;
  l_rec.information42                    := p_information42;
  l_rec.information43                    := p_information43;
  l_rec.information44                    := p_information44;
  l_rec.information45                    := p_information45;
  l_rec.information46                    := p_information46;
  l_rec.information47                    := p_information47;
  l_rec.information48                    := p_information48;
  l_rec.information49                    := p_information49;
  l_rec.information50                    := p_information50;
  l_rec.information51                    := p_information51;
  l_rec.information52                    := p_information52;
  l_rec.information53                    := p_information53;
  l_rec.information54                    := p_information54;
  l_rec.information55                    := p_information55;
  l_rec.information56                    := p_information56;
  l_rec.information57                    := p_information57;
  l_rec.information58                    := p_information58;
  l_rec.information59                    := p_information59;
  l_rec.information60                    := p_information60;
  l_rec.information61                    := p_information61;
  l_rec.information62                    := p_information62;
  l_rec.information63                    := p_information63;
  l_rec.information64                    := p_information64;
  l_rec.information65                    := p_information65;
  l_rec.information66                    := p_information66;
  l_rec.information67                    := p_information67;
  l_rec.information68                    := p_information68;
  l_rec.information69                    := p_information69;
  l_rec.information70                    := p_information70;
  l_rec.information71                    := p_information71;
  l_rec.information72                    := p_information72;
  l_rec.information73                    := p_information73;
  l_rec.information74                    := p_information74;
  l_rec.information75                    := p_information75;
  l_rec.information76                    := p_information76;
  l_rec.information77                    := p_information77;
  l_rec.information78                    := p_information78;
  l_rec.information79                    := p_information79;
  l_rec.information80                    := p_information80;
  l_rec.information81                    := p_information81;
  l_rec.information82                    := p_information82;
  l_rec.information83                    := p_information83;
  l_rec.information84                    := p_information84;
  l_rec.information85                    := p_information85;
  l_rec.information86                    := p_information86;
  l_rec.information87                    := p_information87;
  l_rec.information88                    := p_information88;
  l_rec.information89                    := p_information89;
  l_rec.information90                    := p_information90;
  l_rec.information91                    := p_information91;
  l_rec.information92                    := p_information92;
  l_rec.information93                    := p_information93;
  l_rec.information94                    := p_information94;
  l_rec.information95                    := p_information95;
  l_rec.information96                    := p_information96;
  l_rec.information97                    := p_information97;
  l_rec.information98                    := p_information98;
  l_rec.information99                    := p_information99;
  l_rec.information100                   := p_information100;
  l_rec.information101                   := p_information101;
  l_rec.information102                   := p_information102;
  l_rec.information103                   := p_information103;
  l_rec.information104                   := p_information104;
  l_rec.information105                   := p_information105;
  l_rec.information106                   := p_information106;
  l_rec.information107                   := p_information107;
  l_rec.information108                   := p_information108;
  l_rec.information109                   := p_information109;
  l_rec.information110                   := p_information110;
  l_rec.information111                   := p_information111;
  l_rec.information112                   := p_information112;
  l_rec.information113                   := p_information113;
  l_rec.information114                   := p_information114;
  l_rec.information115                   := p_information115;
  l_rec.information116                   := p_information116;
  l_rec.information117                   := p_information117;
  l_rec.information118                   := p_information118;
  l_rec.information119                   := p_information119;
  l_rec.information120                   := p_information120;
  l_rec.information121                   := p_information121;
  l_rec.information122                   := p_information122;
  l_rec.information123                   := p_information123;
  l_rec.information124                   := p_information124;
  l_rec.information125                   := p_information125;
  l_rec.information126                   := p_information126;
  l_rec.information127                   := p_information127;
  l_rec.information128                   := p_information128;
  l_rec.information129                   := p_information129;
  l_rec.information130                   := p_information130;
  l_rec.information131                   := p_information131;
  l_rec.information132                   := p_information132;
  l_rec.information133                   := p_information133;
  l_rec.information134                   := p_information134;
  l_rec.information135                   := p_information135;
  l_rec.information136                   := p_information136;
  l_rec.information137                   := p_information137;
  l_rec.information138                   := p_information138;
  l_rec.information139                   := p_information139;
  l_rec.information140                   := p_information140;
  l_rec.information141                   := p_information141;
  l_rec.information142                   := p_information142;

  /* Extra Reserved Columns
  l_rec.information143                   := p_information143;
  l_rec.information144                   := p_information144;
  l_rec.information145                   := p_information145;
  l_rec.information146                   := p_information146;
  l_rec.information147                   := p_information147;
  l_rec.information148                   := p_information148;
  l_rec.information149                   := p_information149;
  l_rec.information150                   := p_information150;
  */
  l_rec.information151                   := p_information151;
  l_rec.information152                   := p_information152;
  l_rec.information153                   := p_information153;

  /* Extra Reserved Columns
  l_rec.information154                   := p_information154;
  l_rec.information155                   := p_information155;
  l_rec.information156                   := p_information156;
  l_rec.information157                   := p_information157;
  l_rec.information158                   := p_information158;
  l_rec.information159                   := p_information159;
  */
  l_rec.information160                   := p_information160;
  l_rec.information161                   := p_information161;
  l_rec.information162                   := p_information162;

  /* Extra Reserved Columns
  l_rec.information163                   := p_information163;
  l_rec.information164                   := p_information164;
  l_rec.information165                   := p_information165;
  */
  l_rec.information166                   := p_information166;
  l_rec.information167                   := p_information167;
  l_rec.information168                   := p_information168;
  l_rec.information169                   := p_information169;
  l_rec.information170                   := p_information170;

  /* Extra Reserved Columns
  l_rec.information171                   := p_information171;
  l_rec.information172                   := p_information172;
  */
  l_rec.information173                   := p_information173;
  l_rec.information174                   := p_information174;
  l_rec.information175                   := p_information175;
  l_rec.information176                   := p_information176;
  l_rec.information177                   := p_information177;
  l_rec.information178                   := p_information178;
  l_rec.information179                   := p_information179;
  l_rec.information180                   := p_information180;
  l_rec.information181                   := p_information181;
  l_rec.information182                   := p_information182;

  /* Extra Reserved Columns
  l_rec.information183                   := p_information183;
  l_rec.information184                   := p_information184;
  */
  l_rec.information185                   := p_information185;
  l_rec.information186                   := p_information186;
  l_rec.information187                   := p_information187;
  l_rec.information188                   := p_information188;

  /* Extra Reserved Columns
  l_rec.information189                   := p_information189;
  */
  l_rec.information190                   := p_information190;
  l_rec.information191                   := p_information191;
  l_rec.information192                   := p_information192;
  l_rec.information193                   := p_information193;
  l_rec.information194                   := p_information194;
  l_rec.information195                   := p_information195;
  l_rec.information196                   := p_information196;
  l_rec.information197                   := p_information197;
  l_rec.information198                   := p_information198;
  l_rec.information199                   := p_information199;

  /* Extra Reserved Columns
  l_rec.information200                   := p_information200;
  l_rec.information201                   := p_information201;
  l_rec.information202                   := p_information202;
  l_rec.information203                   := p_information203;
  l_rec.information204                   := p_information204;
  l_rec.information205                   := p_information205;
  l_rec.information206                   := p_information206;
  l_rec.information207                   := p_information207;
  l_rec.information208                   := p_information208;
  l_rec.information209                   := p_information209;
  l_rec.information210                   := p_information210;
  l_rec.information211                   := p_information211;
  l_rec.information212                   := p_information212;
  l_rec.information213                   := p_information213;
  l_rec.information214                   := p_information214;
  l_rec.information215                   := p_information215;
  */
  l_rec.information216                   := p_information216;
  l_rec.information217                   := p_information217;
  l_rec.information218                   := p_information218;
  l_rec.information219                   := p_information219;
  l_rec.information220                   := p_information220;
  l_rec.information221                   := p_information221;
  l_rec.information222                   := p_information222;
  l_rec.information223                   := p_information223;
  l_rec.information224                   := p_information224;
  l_rec.information225                   := p_information225;
  l_rec.information226                   := p_information226;
  l_rec.information227                   := p_information227;
  l_rec.information228                   := p_information228;
  l_rec.information229                   := p_information229;
  l_rec.information230                   := p_information230;
  l_rec.information231                   := p_information231;
  l_rec.information232                   := p_information232;
  l_rec.information233                   := p_information233;
  l_rec.information234                   := p_information234;
  l_rec.information235                   := p_information235;
  l_rec.information236                   := p_information236;
  l_rec.information237                   := p_information237;
  l_rec.information238                   := p_information238;
  l_rec.information239                   := p_information239;
  l_rec.information240                   := p_information240;
  l_rec.information241                   := p_information241;
  l_rec.information242                   := p_information242;
  l_rec.information243                   := p_information243;
  l_rec.information244                   := p_information244;
  l_rec.information245                   := p_information245;
  l_rec.information246                   := p_information246;
  l_rec.information247                   := p_information247;
  l_rec.information248                   := p_information248;
  l_rec.information249                   := p_information249;
  l_rec.information250                   := p_information250;
  l_rec.information251                   := p_information251;
  l_rec.information252                   := p_information252;
  l_rec.information253                   := p_information253;
  l_rec.information254                   := p_information254;
  l_rec.information255                   := p_information255;
  l_rec.information256                   := p_information256;
  l_rec.information257                   := p_information257;
  l_rec.information258                   := p_information258;
  l_rec.information259                   := p_information259;
  l_rec.information260                   := p_information260;
  l_rec.information261                   := p_information261;
  l_rec.information262                   := p_information262;
  l_rec.information263                   := p_information263;
  l_rec.information264                   := p_information264;
  l_rec.information265                   := p_information265;
  l_rec.information266                   := p_information266;
  l_rec.information267                   := p_information267;
  l_rec.information268                   := p_information268;
  l_rec.information269                   := p_information269;
  l_rec.information270                   := p_information270;
  l_rec.information271                   := p_information271;
  l_rec.information272                   := p_information272;
  l_rec.information273                   := p_information273;
  l_rec.information274                   := p_information274;
  l_rec.information275                   := p_information275;
  l_rec.information276                   := p_information276;
  l_rec.information277                   := p_information277;
  l_rec.information278                   := p_information278;
  l_rec.information279                   := p_information279;
  l_rec.information280                   := p_information280;
  l_rec.information281                   := p_information281;
  l_rec.information282                   := p_information282;
  l_rec.information283                   := p_information283;
  l_rec.information284                   := p_information284;
  l_rec.information285                   := p_information285;
  l_rec.information286                   := p_information286;
  l_rec.information287                   := p_information287;
  l_rec.information288                   := p_information288;
  l_rec.information289                   := p_information289;
  l_rec.information290                   := p_information290;
  l_rec.information291                   := p_information291;
  l_rec.information292                   := p_information292;
  l_rec.information293                   := p_information293;
  l_rec.information294                   := p_information294;
  l_rec.information295                   := p_information295;
  l_rec.information296                   := p_information296;
  l_rec.information297                   := p_information297;
  l_rec.information298                   := p_information298;
  l_rec.information299                   := p_information299;
  l_rec.information300                   := p_information300;
  l_rec.information301                   := p_information301;
  l_rec.information302                   := p_information302;
  l_rec.information303                   := p_information303;
  l_rec.information304                   := p_information304;

  /* Extra Reserved Columns
  l_rec.information305                   := p_information305;
  */
  l_rec.information306                   := p_information306;
  l_rec.information307                   := p_information307;
  l_rec.information308                   := p_information308;
  l_rec.information309                   := p_information309;
  l_rec.information310                   := p_information310;
  l_rec.information311                   := p_information311;
  l_rec.information312                   := p_information312;
  l_rec.information313                   := p_information313;
  l_rec.information314                   := p_information314;
  l_rec.information315                   := p_information315;
  l_rec.information316                   := p_information316;
  l_rec.information317                   := p_information317;
  l_rec.information318                   := p_information318;
  l_rec.information319                   := p_information319;
  l_rec.information320                   := p_information320;

  /* Extra Reserved Columns
  l_rec.information321                   := p_information321;
  l_rec.information322                   := p_information322;
  */
  l_rec.information323                   := p_information323;
  l_rec.datetrack_mode                   := p_datetrack_mode;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_cpe_shd;

/
