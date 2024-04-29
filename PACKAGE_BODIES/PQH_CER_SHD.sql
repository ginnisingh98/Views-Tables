--------------------------------------------------------
--  DDL for Package Body PQH_CER_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CER_SHD" as
/* $Header: pqcerrhi.pkb 115.6 2002/11/27 04:43:16 rpasapul ship $ */
--
g_package  varchar2(33)	:= '  pqh_cer_shd.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PQH_COPY_ENTITY_RESULTS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_COPY_ENTITY_RESULTS_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_COPY_ENTITY_RESULTS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_copy_entity_result_id              in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	copy_entity_result_id,
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
    from	pqh_copy_entity_results
    where	copy_entity_result_id = p_copy_entity_result_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_copy_entity_result_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_copy_entity_result_id = g_old_rec.copy_entity_result_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_copy_entity_result_id              in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	copy_entity_result_id,
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
    from	pqh_copy_entity_results
    where	copy_entity_result_id = p_copy_entity_result_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pqh_copy_entity_results');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
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
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.copy_entity_result_id            := p_copy_entity_result_id;
  l_rec.copy_entity_txn_id               := p_copy_entity_txn_id;
  l_rec.result_type_cd                   := p_result_type_cd;
  l_rec.number_of_copies                 := p_number_of_copies;
  l_rec.status                           := p_status;
  l_rec.src_copy_entity_result_id        := p_src_copy_entity_result_id;
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
  l_rec.information143                   := p_information143;
  l_rec.information144                   := p_information144;
  l_rec.information145                   := p_information145;
  l_rec.information146                   := p_information146;
  l_rec.information147                   := p_information147;
  l_rec.information148                   := p_information148;
  l_rec.information149                   := p_information149;
  l_rec.information150                   := p_information150;
  l_rec.information151                   := p_information151;
  l_rec.information152                   := p_information152;
  l_rec.information153                   := p_information153;
  l_rec.information154                   := p_information154;
  l_rec.information155                   := p_information155;
  l_rec.information156                   := p_information156;
  l_rec.information157                   := p_information157;
  l_rec.information158                   := p_information158;
  l_rec.information159                   := p_information159;
  l_rec.information160                   := p_information160;
  l_rec.information161                   := p_information161;
  l_rec.information162                   := p_information162;
  l_rec.information163                   := p_information163;
  l_rec.information164                   := p_information164;
  l_rec.information165                   := p_information165;
  l_rec.information166                   := p_information166;
  l_rec.information167                   := p_information167;
  l_rec.information168                   := p_information168;
  l_rec.information169                   := p_information169;
  l_rec.information170                   := p_information170;
  l_rec.information171                   := p_information171;
  l_rec.information172                   := p_information172;
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
  l_rec.information183                   := p_information183;
  l_rec.information184                   := p_information184;
  l_rec.information185                   := p_information185;
  l_rec.information186                   := p_information186;
  l_rec.information187                   := p_information187;
  l_rec.information188                   := p_information188;
  l_rec.information189                   := p_information189;
  l_rec.information190                   := p_information190;
  l_rec.mirror_entity_result_id          := p_mirror_entity_result_id;
  l_rec.mirror_src_entity_result_id      := p_mirror_src_entity_result_id;
  l_rec.parent_entity_result_id          := p_parent_entity_result_id;
  l_rec.table_route_id                   := p_table_route_id;
  l_rec.long_attribute1                  := p_long_attribute1;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pqh_cer_shd;

/
