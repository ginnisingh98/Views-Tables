--------------------------------------------------------
--  DDL for Package Body PQH_COPY_ENTITY_RESULTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COPY_ENTITY_RESULTS_API" as
/* $Header: pqcerapi.pkb 115.5 2002/11/27 04:43:10 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_copy_entity_results_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_result >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_copy_entity_result
  (p_validate                       in  boolean   default false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_result_type_cd                 in  varchar2  default null
  ,p_number_of_copies               in  number    default null
  ,p_status                         in  varchar2  default null
  ,p_src_copy_entity_result_id      in  number    default null
  ,p_information_category           in  varchar2  default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information31                  in  varchar2  default null
  ,p_information32                  in  varchar2  default null
  ,p_information33                  in  varchar2  default null
  ,p_information34                  in  varchar2  default null
  ,p_information35                  in  varchar2  default null
  ,p_information36                  in  varchar2  default null
  ,p_information37                  in  varchar2  default null
  ,p_information38                  in  varchar2  default null
  ,p_information39                  in  varchar2  default null
  ,p_information40                  in  varchar2  default null
  ,p_information41                  in  varchar2  default null
  ,p_information42                  in  varchar2  default null
  ,p_information43                  in  varchar2  default null
  ,p_information44                  in  varchar2  default null
  ,p_information45                  in  varchar2  default null
  ,p_information46                  in  varchar2  default null
  ,p_information47                  in  varchar2  default null
  ,p_information48                  in  varchar2  default null
  ,p_information49                  in  varchar2  default null
  ,p_information50                  in  varchar2  default null
  ,p_information51                  in  varchar2  default null
  ,p_information52                  in  varchar2  default null
  ,p_information53                  in  varchar2  default null
  ,p_information54                  in  varchar2  default null
  ,p_information55                  in  varchar2  default null
  ,p_information56                  in  varchar2  default null
  ,p_information57                  in  varchar2  default null
  ,p_information58                  in  varchar2  default null
  ,p_information59                  in  varchar2  default null
  ,p_information60                  in  varchar2  default null
  ,p_information61                  in  varchar2  default null
  ,p_information62                  in  varchar2  default null
  ,p_information63                  in  varchar2  default null
  ,p_information64                  in  varchar2  default null
  ,p_information65                  in  varchar2  default null
  ,p_information66                  in  varchar2  default null
  ,p_information67                  in  varchar2  default null
  ,p_information68                  in  varchar2  default null
  ,p_information69                  in  varchar2  default null
  ,p_information70                  in  varchar2  default null
  ,p_information71                  in  varchar2  default null
  ,p_information72                  in  varchar2  default null
  ,p_information73                  in  varchar2  default null
  ,p_information74                  in  varchar2  default null
  ,p_information75                  in  varchar2  default null
  ,p_information76                  in  varchar2  default null
  ,p_information77                  in  varchar2  default null
  ,p_information78                  in  varchar2  default null
  ,p_information79                  in  varchar2  default null
  ,p_information80                  in  varchar2  default null
  ,p_information81                  in  varchar2  default null
  ,p_information82                  in  varchar2  default null
  ,p_information83                  in  varchar2  default null
  ,p_information84                  in  varchar2  default null
  ,p_information85                  in  varchar2  default null
  ,p_information86                  in  varchar2  default null
  ,p_information87                  in  varchar2  default null
  ,p_information88                  in  varchar2  default null
  ,p_information89                  in  varchar2  default null
  ,p_information90                  in  varchar2  default null
  ,p_information91                 in varchar2 default null
  ,p_information92                 in varchar2 default null
  ,p_information93                 in varchar2 default null
  ,p_information94                 in varchar2 default null
  ,p_information95                 in varchar2 default null
  ,p_information96                 in varchar2 default null
  ,p_information97                 in varchar2 default null
  ,p_information98                 in varchar2 default null
  ,p_information99                 in varchar2 default null
  ,p_information100                in varchar2 default null
  ,p_information101                in varchar2 default null
  ,p_information102                in varchar2 default null
  ,p_information103                in varchar2 default null
  ,p_information104                in varchar2 default null
  ,p_information105                in varchar2 default null
  ,p_information106                in varchar2 default null
  ,p_information107                in varchar2 default null
  ,p_information108                in varchar2 default null
  ,p_information109                in varchar2 default null
  ,p_information110                in varchar2 default null
  ,p_information111                in varchar2 default null
  ,p_information112                in varchar2 default null
  ,p_information113                in varchar2 default null
  ,p_information114                in varchar2 default null
  ,p_information115                in varchar2 default null
  ,p_information116                in varchar2 default null
  ,p_information117                in varchar2 default null
  ,p_information118                in varchar2 default null
  ,p_information119                in varchar2 default null
  ,p_information120                in varchar2 default null
  ,p_information121                in varchar2 default null
  ,p_information122                in varchar2 default null
  ,p_information123                in varchar2 default null
  ,p_information124                in varchar2 default null
  ,p_information125                in varchar2 default null
  ,p_information126                in varchar2 default null
  ,p_information127                in varchar2 default null
  ,p_information128                in varchar2 default null
  ,p_information129                in varchar2 default null
  ,p_information130                in varchar2 default null
  ,p_information131                in varchar2 default null
  ,p_information132                in varchar2 default null
  ,p_information133                in varchar2 default null
  ,p_information134                in varchar2 default null
  ,p_information135                in varchar2 default null
  ,p_information136                in varchar2 default null
  ,p_information137                in varchar2 default null
  ,p_information138                in varchar2 default null
  ,p_information139                in varchar2 default null
  ,p_information140                in varchar2 default null
  ,p_information141                in varchar2 default null
  ,p_information142                in varchar2 default null
  ,p_information143                in varchar2 default null
  ,p_information144                in varchar2 default null
  ,p_information145                in varchar2 default null
  ,p_information146                in varchar2 default null
  ,p_information147                in varchar2 default null
  ,p_information148                in varchar2 default null
  ,p_information149                in varchar2 default null
  ,p_information150                in varchar2 default null
  ,p_information151                in varchar2 default null
  ,p_information152                in varchar2 default null
  ,p_information153                in varchar2 default null
  ,p_information154                in varchar2 default null
  ,p_information155                in varchar2 default null
  ,p_information156                in varchar2 default null
  ,p_information157                in varchar2 default null
  ,p_information158                in varchar2 default null
  ,p_information159                in varchar2 default null
  ,p_information160                in varchar2 default null
  ,p_information161                in varchar2 default null
  ,p_information162                in varchar2 default null
  ,p_information163                in varchar2 default null
  ,p_information164                in varchar2 default null
  ,p_information165                in varchar2 default null
  ,p_information166                in varchar2 default null
  ,p_information167                in varchar2 default null
  ,p_information168                in varchar2 default null
  ,p_information169                in varchar2 default null
  ,p_information170                in varchar2 default null
  ,p_information171                in varchar2 default null
  ,p_information172                in varchar2 default null
  ,p_information173                in varchar2 default null
  ,p_information174                in varchar2 default null
  ,p_information175                in varchar2 default null
  ,p_information176                in varchar2 default null
  ,p_information177                in varchar2 default null
  ,p_information178                in varchar2 default null
  ,p_information179                in varchar2 default null
  ,p_information180                in varchar2 default null
  ,p_information181                in varchar2 default null
  ,p_information182                in varchar2 default null
  ,p_information183                in varchar2 default null
  ,p_information184                in varchar2 default null
  ,p_information185                in varchar2 default null
  ,p_information186                in varchar2 default null
  ,p_information187                in varchar2 default null
  ,p_information188                in varchar2 default null
  ,p_information189                in varchar2 default null
  ,p_information190                in varchar2 default null
  ,p_mirror_entity_result_id       in  number  default null
  ,p_mirror_src_entity_result_id   in  number  default null
  ,p_parent_entity_result_id       in  number  default null
  ,p_table_route_id                in  number  default null
  ,p_long_attribute1               in  long    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_copy_entity_result_id pqh_copy_entity_results.copy_entity_result_id%TYPE;
  l_proc varchar2(72) := g_package||'create_copy_entity_result';
  l_object_version_number pqh_copy_entity_results.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_copy_entity_result;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_copy_entity_result
    --
    pqh_copy_entity_results_bk1.create_copy_entity_result_b
      (
       p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_result_type_cd                 =>  p_result_type_cd
      ,p_number_of_copies               =>  p_number_of_copies
      ,p_status                         =>  p_status
      ,p_src_copy_entity_result_id      =>  p_src_copy_entity_result_id
      ,p_information_category           =>  p_information_category
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information31                  =>  p_information31
      ,p_information32                  =>  p_information32
      ,p_information33                  =>  p_information33
      ,p_information34                  =>  p_information34
      ,p_information35                  =>  p_information35
      ,p_information36                  =>  p_information36
      ,p_information37                  =>  p_information37
      ,p_information38                  =>  p_information38
      ,p_information39                  =>  p_information39
      ,p_information40                  =>  p_information40
      ,p_information41                  =>  p_information41
      ,p_information42                  =>  p_information42
      ,p_information43                  =>  p_information43
      ,p_information44                  =>  p_information44
      ,p_information45                  =>  p_information45
      ,p_information46                  =>  p_information46
      ,p_information47                  =>  p_information47
      ,p_information48                  =>  p_information48
      ,p_information49                  =>  p_information49
      ,p_information50                  =>  p_information50
      ,p_information51                  =>  p_information51
      ,p_information52                  =>  p_information52
      ,p_information53                  =>  p_information53
      ,p_information54                  =>  p_information54
      ,p_information55                  =>  p_information55
      ,p_information56                  =>  p_information56
      ,p_information57                  =>  p_information57
      ,p_information58                  =>  p_information58
      ,p_information59                  =>  p_information59
      ,p_information60                  =>  p_information60
      ,p_information61                  =>  p_information61
      ,p_information62                  =>  p_information62
      ,p_information63                  =>  p_information63
      ,p_information64                  =>  p_information64
      ,p_information65                  =>  p_information65
      ,p_information66                  =>  p_information66
      ,p_information67                  =>  p_information67
      ,p_information68                  =>  p_information68
      ,p_information69                  =>  p_information69
      ,p_information70                  =>  p_information70
      ,p_information71                  =>  p_information71
      ,p_information72                  =>  p_information72
      ,p_information73                  =>  p_information73
      ,p_information74                  =>  p_information74
      ,p_information75                  =>  p_information75
      ,p_information76                  =>  p_information76
      ,p_information77                  =>  p_information77
      ,p_information78                  =>  p_information78
      ,p_information79                  =>  p_information79
      ,p_information80                  =>  p_information80
      ,p_information81                  =>  p_information81
      ,p_information82                  =>  p_information82
      ,p_information83                  =>  p_information83
      ,p_information84                  =>  p_information84
      ,p_information85                  =>  p_information85
      ,p_information86                  =>  p_information86
      ,p_information87                  =>  p_information87
      ,p_information88                  =>  p_information88
      ,p_information89                  =>  p_information89
      ,p_information90                  =>  p_information90
 ,p_information91                 =>p_information91
 ,p_information92                 =>p_information92
 ,p_information93                 =>p_information93
 ,p_information94                 =>p_information94
 ,p_information95                 =>p_information95
 ,p_information96                 =>p_information96
 ,p_information97                 =>p_information97
 ,p_information98                 =>p_information98
 ,p_information99                 =>p_information99
 ,p_information100                =>p_information100
 ,p_information101                =>p_information101
 ,p_information102                =>p_information102
 ,p_information103                =>p_information103
 ,p_information104                =>p_information104
 ,p_information105                =>p_information105
 ,p_information106                =>p_information106
 ,p_information107                =>p_information107
 ,p_information108                =>p_information108
 ,p_information109                =>p_information109
 ,p_information110                =>p_information110
 ,p_information111                =>p_information111
 ,p_information112                =>p_information112
 ,p_information113                =>p_information113
 ,p_information114                =>p_information114
 ,p_information115                =>p_information115
 ,p_information116                =>p_information116
 ,p_information117                =>p_information117
 ,p_information118                =>p_information118
 ,p_information119                =>p_information119
 ,p_information120                =>p_information120
 ,p_information121                =>p_information121
 ,p_information122                =>p_information122
 ,p_information123                =>p_information123
 ,p_information124                =>p_information124
 ,p_information125                =>p_information125
 ,p_information126                =>p_information126
 ,p_information127                =>p_information127
 ,p_information128                =>p_information128
 ,p_information129                =>p_information129
 ,p_information130                =>p_information130
 ,p_information131                =>p_information131
 ,p_information132                =>p_information132
 ,p_information133                =>p_information133
 ,p_information134                =>p_information134
 ,p_information135                =>p_information135
 ,p_information136                =>p_information136
 ,p_information137                =>p_information137
 ,p_information138                =>p_information138
 ,p_information139                =>p_information139
 ,p_information140                =>p_information140
 ,p_information141                =>p_information141
 ,p_information142                =>p_information142
 ,p_information143                =>p_information143
 ,p_information144                =>p_information144
 ,p_information145                =>p_information145
 ,p_information146                =>p_information146
 ,p_information147                =>p_information147
 ,p_information148                =>p_information148
 ,p_information149                =>p_information149
 ,p_information150                =>p_information150
 ,p_information151                =>p_information151
 ,p_information152                =>p_information152
 ,p_information153                =>p_information153
 ,p_information154                =>p_information154
 ,p_information155                =>p_information155
 ,p_information156                =>p_information156
 ,p_information157                =>p_information157
 ,p_information158                =>p_information158
 ,p_information159                =>p_information159
 ,p_information160                =>p_information160
 ,p_information161                =>p_information161
 ,p_information162                =>p_information162
 ,p_information163                =>p_information163
 ,p_information164                =>p_information164
 ,p_information165                =>p_information165
 ,p_information166                =>p_information166
 ,p_information167                =>p_information167
 ,p_information168                =>p_information168
 ,p_information169                =>p_information169
 ,p_information170                =>p_information170
 ,p_information171                =>p_information171
 ,p_information172                =>p_information172
 ,p_information173                =>p_information173
 ,p_information174                =>p_information174
 ,p_information175                =>p_information175
 ,p_information176                =>p_information176
 ,p_information177                =>p_information177
 ,p_information178                =>p_information178
 ,p_information179                =>p_information179
 ,p_information180                =>p_information180
 ,p_information181                =>p_information181
 ,p_information182                =>p_information182
 ,p_information183                =>p_information183
 ,p_information184                =>p_information184
 ,p_information185                =>p_information185
 ,p_information186                =>p_information186
 ,p_information187                =>p_information187
 ,p_information188                =>p_information188
 ,p_information189                =>p_information189
 ,p_information190                =>p_information190
 ,p_mirror_entity_result_id       =>p_mirror_entity_result_id
 ,p_mirror_src_entity_result_id   =>p_mirror_src_entity_result_id
 ,p_parent_entity_result_id       =>p_parent_entity_result_id
 ,p_table_route_id                =>p_table_route_id
 ,p_long_attribute1               =>p_long_attribute1
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_copy_entity_result'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_copy_entity_results
    --
  end;
  --
  pqh_cer_ins.ins
    (
     p_copy_entity_result_id         => l_copy_entity_result_id
    ,p_copy_entity_txn_id            => p_copy_entity_txn_id
    ,p_result_type_cd                => p_result_type_cd
    ,p_number_of_copies              => p_number_of_copies
    ,p_status                        => p_status
    ,p_src_copy_entity_result_id     => p_src_copy_entity_result_id
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_information31                 => p_information31
    ,p_information32                 => p_information32
    ,p_information33                 => p_information33
    ,p_information34                 => p_information34
    ,p_information35                 => p_information35
    ,p_information36                 => p_information36
    ,p_information37                 => p_information37
    ,p_information38                 => p_information38
    ,p_information39                 => p_information39
    ,p_information40                 => p_information40
    ,p_information41                 => p_information41
    ,p_information42                 => p_information42
    ,p_information43                 => p_information43
    ,p_information44                 => p_information44
    ,p_information45                 => p_information45
    ,p_information46                 => p_information46
    ,p_information47                 => p_information47
    ,p_information48                 => p_information48
    ,p_information49                 => p_information49
    ,p_information50                 => p_information50
    ,p_information51                 => p_information51
    ,p_information52                 => p_information52
    ,p_information53                 => p_information53
    ,p_information54                 => p_information54
    ,p_information55                 => p_information55
    ,p_information56                 => p_information56
    ,p_information57                 => p_information57
    ,p_information58                 => p_information58
    ,p_information59                 => p_information59
    ,p_information60                 => p_information60
    ,p_information61                 => p_information61
    ,p_information62                 => p_information62
    ,p_information63                 => p_information63
    ,p_information64                 => p_information64
    ,p_information65                 => p_information65
    ,p_information66                 => p_information66
    ,p_information67                 => p_information67
    ,p_information68                 => p_information68
    ,p_information69                 => p_information69
    ,p_information70                 => p_information70
    ,p_information71                 => p_information71
    ,p_information72                 => p_information72
    ,p_information73                 => p_information73
    ,p_information74                 => p_information74
    ,p_information75                 => p_information75
    ,p_information76                 => p_information76
    ,p_information77                 => p_information77
    ,p_information78                 => p_information78
    ,p_information79                 => p_information79
    ,p_information80                 => p_information80
    ,p_information81                 => p_information81
    ,p_information82                 => p_information82
    ,p_information83                 => p_information83
    ,p_information84                 => p_information84
    ,p_information85                 => p_information85
    ,p_information86                 => p_information86
    ,p_information87                 => p_information87
    ,p_information88                 => p_information88
    ,p_information89                 => p_information89
    ,p_information90                 => p_information90
 ,p_information91                 =>p_information91
 ,p_information92                 =>p_information92
 ,p_information93                 =>p_information93
 ,p_information94                 =>p_information94
 ,p_information95                 =>p_information95
 ,p_information96                 =>p_information96
 ,p_information97                 =>p_information97
 ,p_information98                 =>p_information98
 ,p_information99                 =>p_information99
 ,p_information100                =>p_information100
 ,p_information101                =>p_information101
 ,p_information102                =>p_information102
 ,p_information103                =>p_information103
 ,p_information104                =>p_information104
 ,p_information105                =>p_information105
 ,p_information106                =>p_information106
 ,p_information107                =>p_information107
 ,p_information108                =>p_information108
 ,p_information109                =>p_information109
 ,p_information110                =>p_information110
 ,p_information111                =>p_information111
 ,p_information112                =>p_information112
 ,p_information113                =>p_information113
 ,p_information114                =>p_information114
 ,p_information115                =>p_information115
 ,p_information116                =>p_information116
 ,p_information117                =>p_information117
 ,p_information118                =>p_information118
 ,p_information119                =>p_information119
 ,p_information120                =>p_information120
 ,p_information121                =>p_information121
 ,p_information122                =>p_information122
 ,p_information123                =>p_information123
 ,p_information124                =>p_information124
 ,p_information125                =>p_information125
 ,p_information126                =>p_information126
 ,p_information127                =>p_information127
 ,p_information128                =>p_information128
 ,p_information129                =>p_information129
 ,p_information130                =>p_information130
 ,p_information131                =>p_information131
 ,p_information132                =>p_information132
 ,p_information133                =>p_information133
 ,p_information134                =>p_information134
 ,p_information135                =>p_information135
 ,p_information136                =>p_information136
 ,p_information137                =>p_information137
 ,p_information138                =>p_information138
 ,p_information139                =>p_information139
 ,p_information140                =>p_information140
 ,p_information141                =>p_information141
 ,p_information142                =>p_information142
 ,p_information143                =>p_information143
 ,p_information144                =>p_information144
 ,p_information145                =>p_information145
 ,p_information146                =>p_information146
 ,p_information147                =>p_information147
 ,p_information148                =>p_information148
 ,p_information149                =>p_information149
 ,p_information150                =>p_information150
 ,p_information151                =>p_information151
 ,p_information152                =>p_information152
 ,p_information153                =>p_information153
 ,p_information154                =>p_information154
 ,p_information155                =>p_information155
 ,p_information156                =>p_information156
 ,p_information157                =>p_information157
 ,p_information158                =>p_information158
 ,p_information159                =>p_information159
 ,p_information160                =>p_information160
 ,p_information161                =>p_information161
 ,p_information162                =>p_information162
 ,p_information163                =>p_information163
 ,p_information164                =>p_information164
 ,p_information165                =>p_information165
 ,p_information166                =>p_information166
 ,p_information167                =>p_information167
 ,p_information168                =>p_information168
 ,p_information169                =>p_information169
 ,p_information170                =>p_information170
 ,p_information171                =>p_information171
 ,p_information172                =>p_information172
 ,p_information173                =>p_information173
 ,p_information174                =>p_information174
 ,p_information175                =>p_information175
 ,p_information176                =>p_information176
 ,p_information177                =>p_information177
 ,p_information178                =>p_information178
 ,p_information179                =>p_information179
 ,p_information180                =>p_information180
 ,p_information181                =>p_information181
 ,p_information182                =>p_information182
 ,p_information183                =>p_information183
 ,p_information184                =>p_information184
 ,p_information185                =>p_information185
 ,p_information186                =>p_information186
 ,p_information187                =>p_information187
 ,p_information188                =>p_information188
 ,p_information189                =>p_information189
 ,p_information190                =>p_information190
 ,p_mirror_entity_result_id       =>p_mirror_entity_result_id
 ,p_mirror_src_entity_result_id   =>p_mirror_src_entity_result_id
 ,p_parent_entity_result_id       =>p_parent_entity_result_id
 ,p_table_route_id                =>p_table_route_id
 ,p_long_attribute1               =>p_long_attribute1
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_copy_entity_results
    --
    pqh_copy_entity_results_bk1.create_copy_entity_result_a
      (
       p_copy_entity_result_id          =>  l_copy_entity_result_id
      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_result_type_cd                 =>  p_result_type_cd
      ,p_number_of_copies               =>  p_number_of_copies
      ,p_status                         =>  p_status
      ,p_src_copy_entity_result_id      =>  p_src_copy_entity_result_id
      ,p_information_category           =>  p_information_category
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information31                  =>  p_information31
      ,p_information32                  =>  p_information32
      ,p_information33                  =>  p_information33
      ,p_information34                  =>  p_information34
      ,p_information35                  =>  p_information35
      ,p_information36                  =>  p_information36
      ,p_information37                  =>  p_information37
      ,p_information38                  =>  p_information38
      ,p_information39                  =>  p_information39
      ,p_information40                  =>  p_information40
      ,p_information41                  =>  p_information41
      ,p_information42                  =>  p_information42
      ,p_information43                  =>  p_information43
      ,p_information44                  =>  p_information44
      ,p_information45                  =>  p_information45
      ,p_information46                  =>  p_information46
      ,p_information47                  =>  p_information47
      ,p_information48                  =>  p_information48
      ,p_information49                  =>  p_information49
      ,p_information50                  =>  p_information50
      ,p_information51                  =>  p_information51
      ,p_information52                  =>  p_information52
      ,p_information53                  =>  p_information53
      ,p_information54                  =>  p_information54
      ,p_information55                  =>  p_information55
      ,p_information56                  =>  p_information56
      ,p_information57                  =>  p_information57
      ,p_information58                  =>  p_information58
      ,p_information59                  =>  p_information59
      ,p_information60                  =>  p_information60
      ,p_information61                  =>  p_information61
      ,p_information62                  =>  p_information62
      ,p_information63                  =>  p_information63
      ,p_information64                  =>  p_information64
      ,p_information65                  =>  p_information65
      ,p_information66                  =>  p_information66
      ,p_information67                  =>  p_information67
      ,p_information68                  =>  p_information68
      ,p_information69                  =>  p_information69
      ,p_information70                  =>  p_information70
      ,p_information71                  =>  p_information71
      ,p_information72                  =>  p_information72
      ,p_information73                  =>  p_information73
      ,p_information74                  =>  p_information74
      ,p_information75                  =>  p_information75
      ,p_information76                  =>  p_information76
      ,p_information77                  =>  p_information77
      ,p_information78                  =>  p_information78
      ,p_information79                  =>  p_information79
      ,p_information80                  =>  p_information80
      ,p_information81                  =>  p_information81
      ,p_information82                  =>  p_information82
      ,p_information83                  =>  p_information83
      ,p_information84                  =>  p_information84
      ,p_information85                  =>  p_information85
      ,p_information86                  =>  p_information86
      ,p_information87                  =>  p_information87
      ,p_information88                  =>  p_information88
      ,p_information89                  =>  p_information89
      ,p_information90                  =>  p_information90
 ,p_information91                 =>p_information91
 ,p_information92                 =>p_information92
 ,p_information93                 =>p_information93
 ,p_information94                 =>p_information94
 ,p_information95                 =>p_information95
 ,p_information96                 =>p_information96
 ,p_information97                 =>p_information97
 ,p_information98                 =>p_information98
 ,p_information99                 =>p_information99
 ,p_information100                =>p_information100
 ,p_information101                =>p_information101
 ,p_information102                =>p_information102
 ,p_information103                =>p_information103
 ,p_information104                =>p_information104
 ,p_information105                =>p_information105
 ,p_information106                =>p_information106
 ,p_information107                =>p_information107
 ,p_information108                =>p_information108
 ,p_information109                =>p_information109
 ,p_information110                =>p_information110
 ,p_information111                =>p_information111
 ,p_information112                =>p_information112
 ,p_information113                =>p_information113
 ,p_information114                =>p_information114
 ,p_information115                =>p_information115
 ,p_information116                =>p_information116
 ,p_information117                =>p_information117
 ,p_information118                =>p_information118
 ,p_information119                =>p_information119
 ,p_information120                =>p_information120
 ,p_information121                =>p_information121
 ,p_information122                =>p_information122
 ,p_information123                =>p_information123
 ,p_information124                =>p_information124
 ,p_information125                =>p_information125
 ,p_information126                =>p_information126
 ,p_information127                =>p_information127
 ,p_information128                =>p_information128
 ,p_information129                =>p_information129
 ,p_information130                =>p_information130
 ,p_information131                =>p_information131
 ,p_information132                =>p_information132
 ,p_information133                =>p_information133
 ,p_information134                =>p_information134
 ,p_information135                =>p_information135
 ,p_information136                =>p_information136
 ,p_information137                =>p_information137
 ,p_information138                =>p_information138
 ,p_information139                =>p_information139
 ,p_information140                =>p_information140
 ,p_information141                =>p_information141
 ,p_information142                =>p_information142
 ,p_information143                =>p_information143
 ,p_information144                =>p_information144
 ,p_information145                =>p_information145
 ,p_information146                =>p_information146
 ,p_information147                =>p_information147
 ,p_information148                =>p_information148
 ,p_information149                =>p_information149
 ,p_information150                =>p_information150
 ,p_information151                =>p_information151
 ,p_information152                =>p_information152
 ,p_information153                =>p_information153
 ,p_information154                =>p_information154
 ,p_information155                =>p_information155
 ,p_information156                =>p_information156
 ,p_information157                =>p_information157
 ,p_information158                =>p_information158
 ,p_information159                =>p_information159
 ,p_information160                =>p_information160
 ,p_information161                =>p_information161
 ,p_information162                =>p_information162
 ,p_information163                =>p_information163
 ,p_information164                =>p_information164
 ,p_information165                =>p_information165
 ,p_information166                =>p_information166
 ,p_information167                =>p_information167
 ,p_information168                =>p_information168
 ,p_information169                =>p_information169
 ,p_information170                =>p_information170
 ,p_information171                =>p_information171
 ,p_information172                =>p_information172
 ,p_information173                =>p_information173
 ,p_information174                =>p_information174
 ,p_information175                =>p_information175
 ,p_information176                =>p_information176
 ,p_information177                =>p_information177
 ,p_information178                =>p_information178
 ,p_information179                =>p_information179
 ,p_information180                =>p_information180
 ,p_information181                =>p_information181
 ,p_information182                =>p_information182
 ,p_information183                =>p_information183
 ,p_information184                =>p_information184
 ,p_information185                =>p_information185
 ,p_information186                =>p_information186
 ,p_information187                =>p_information187
 ,p_information188                =>p_information188
 ,p_information189                =>p_information189
 ,p_information190                =>p_information190
 ,p_mirror_entity_result_id       =>p_mirror_entity_result_id
 ,p_mirror_src_entity_result_id   =>p_mirror_src_entity_result_id
 ,p_parent_entity_result_id       =>p_parent_entity_result_id
 ,p_table_route_id                =>p_table_route_id
 ,p_long_attribute1               =>p_long_attribute1
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_copy_entity_result'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_copy_entity_results
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_copy_entity_result_id := l_copy_entity_result_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_copy_entity_result;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_copy_entity_result_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
   p_copy_entity_result_id := null;
  p_object_version_number := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_copy_entity_result;
    raise;
    --
end create_copy_entity_result;
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_result >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_copy_entity_result
  (p_validate                       in  boolean   default false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number    default hr_api.g_number
  ,p_result_type_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_number_of_copies               in  number    default hr_api.g_number
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_src_copy_entity_result_id      in  number    default hr_api.g_number
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_information1                   in  varchar2  default hr_api.g_varchar2
  ,p_information2                   in  varchar2  default hr_api.g_varchar2
  ,p_information3                   in  varchar2  default hr_api.g_varchar2
  ,p_information4                   in  varchar2  default hr_api.g_varchar2
  ,p_information5                   in  varchar2  default hr_api.g_varchar2
  ,p_information6                   in  varchar2  default hr_api.g_varchar2
  ,p_information7                   in  varchar2  default hr_api.g_varchar2
  ,p_information8                   in  varchar2  default hr_api.g_varchar2
  ,p_information9                   in  varchar2  default hr_api.g_varchar2
  ,p_information10                  in  varchar2  default hr_api.g_varchar2
  ,p_information11                  in  varchar2  default hr_api.g_varchar2
  ,p_information12                  in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_information31                  in  varchar2  default hr_api.g_varchar2
  ,p_information32                  in  varchar2  default hr_api.g_varchar2
  ,p_information33                  in  varchar2  default hr_api.g_varchar2
  ,p_information34                  in  varchar2  default hr_api.g_varchar2
  ,p_information35                  in  varchar2  default hr_api.g_varchar2
  ,p_information36                  in  varchar2  default hr_api.g_varchar2
  ,p_information37                  in  varchar2  default hr_api.g_varchar2
  ,p_information38                  in  varchar2  default hr_api.g_varchar2
  ,p_information39                  in  varchar2  default hr_api.g_varchar2
  ,p_information40                  in  varchar2  default hr_api.g_varchar2
  ,p_information41                  in  varchar2  default hr_api.g_varchar2
  ,p_information42                  in  varchar2  default hr_api.g_varchar2
  ,p_information43                  in  varchar2  default hr_api.g_varchar2
  ,p_information44                  in  varchar2  default hr_api.g_varchar2
  ,p_information45                  in  varchar2  default hr_api.g_varchar2
  ,p_information46                  in  varchar2  default hr_api.g_varchar2
  ,p_information47                  in  varchar2  default hr_api.g_varchar2
  ,p_information48                  in  varchar2  default hr_api.g_varchar2
  ,p_information49                  in  varchar2  default hr_api.g_varchar2
  ,p_information50                  in  varchar2  default hr_api.g_varchar2
  ,p_information51                  in  varchar2  default hr_api.g_varchar2
  ,p_information52                  in  varchar2  default hr_api.g_varchar2
  ,p_information53                  in  varchar2  default hr_api.g_varchar2
  ,p_information54                  in  varchar2  default hr_api.g_varchar2
  ,p_information55                  in  varchar2  default hr_api.g_varchar2
  ,p_information56                  in  varchar2  default hr_api.g_varchar2
  ,p_information57                  in  varchar2  default hr_api.g_varchar2
  ,p_information58                  in  varchar2  default hr_api.g_varchar2
  ,p_information59                  in  varchar2  default hr_api.g_varchar2
  ,p_information60                  in  varchar2  default hr_api.g_varchar2
  ,p_information61                  in  varchar2  default hr_api.g_varchar2
  ,p_information62                  in  varchar2  default hr_api.g_varchar2
  ,p_information63                  in  varchar2  default hr_api.g_varchar2
  ,p_information64                  in  varchar2  default hr_api.g_varchar2
  ,p_information65                  in  varchar2  default hr_api.g_varchar2
  ,p_information66                  in  varchar2  default hr_api.g_varchar2
  ,p_information67                  in  varchar2  default hr_api.g_varchar2
  ,p_information68                  in  varchar2  default hr_api.g_varchar2
  ,p_information69                  in  varchar2  default hr_api.g_varchar2
  ,p_information70                  in  varchar2  default hr_api.g_varchar2
  ,p_information71                  in  varchar2  default hr_api.g_varchar2
  ,p_information72                  in  varchar2  default hr_api.g_varchar2
  ,p_information73                  in  varchar2  default hr_api.g_varchar2
  ,p_information74                  in  varchar2  default hr_api.g_varchar2
  ,p_information75                  in  varchar2  default hr_api.g_varchar2
  ,p_information76                  in  varchar2  default hr_api.g_varchar2
  ,p_information77                  in  varchar2  default hr_api.g_varchar2
  ,p_information78                  in  varchar2  default hr_api.g_varchar2
  ,p_information79                  in  varchar2  default hr_api.g_varchar2
  ,p_information80                  in  varchar2  default hr_api.g_varchar2
  ,p_information81                  in  varchar2  default hr_api.g_varchar2
  ,p_information82                  in  varchar2  default hr_api.g_varchar2
  ,p_information83                  in  varchar2  default hr_api.g_varchar2
  ,p_information84                  in  varchar2  default hr_api.g_varchar2
  ,p_information85                  in  varchar2  default hr_api.g_varchar2
  ,p_information86                  in  varchar2  default hr_api.g_varchar2
  ,p_information87                  in  varchar2  default hr_api.g_varchar2
  ,p_information88                  in  varchar2  default hr_api.g_varchar2
  ,p_information89                  in  varchar2  default hr_api.g_varchar2
  ,p_information90                  in  varchar2  default hr_api.g_varchar2
  ,p_information91                 in varchar2 default hr_api.g_varchar2
  ,p_information92                 in varchar2 default hr_api.g_varchar2
  ,p_information93                 in varchar2 default hr_api.g_varchar2
  ,p_information94                 in varchar2 default hr_api.g_varchar2
  ,p_information95                 in varchar2 default hr_api.g_varchar2
  ,p_information96                 in varchar2 default hr_api.g_varchar2
  ,p_information97                 in varchar2 default hr_api.g_varchar2
  ,p_information98                 in varchar2 default hr_api.g_varchar2
  ,p_information99                 in varchar2 default hr_api.g_varchar2
  ,p_information100                in varchar2 default hr_api.g_varchar2
  ,p_information101                in varchar2 default hr_api.g_varchar2
  ,p_information102                in varchar2 default hr_api.g_varchar2
  ,p_information103                in varchar2 default hr_api.g_varchar2
  ,p_information104                in varchar2 default hr_api.g_varchar2
  ,p_information105                in varchar2 default hr_api.g_varchar2
  ,p_information106                in varchar2 default hr_api.g_varchar2
  ,p_information107                in varchar2 default hr_api.g_varchar2
  ,p_information108                in varchar2 default hr_api.g_varchar2
  ,p_information109                in varchar2 default hr_api.g_varchar2
  ,p_information110                in varchar2 default hr_api.g_varchar2
  ,p_information111                in varchar2 default hr_api.g_varchar2
  ,p_information112                in varchar2 default hr_api.g_varchar2
  ,p_information113                in varchar2 default hr_api.g_varchar2
  ,p_information114                in varchar2 default hr_api.g_varchar2
  ,p_information115                in varchar2 default hr_api.g_varchar2
  ,p_information116                in varchar2 default hr_api.g_varchar2
  ,p_information117                in varchar2 default hr_api.g_varchar2
  ,p_information118                in varchar2 default hr_api.g_varchar2
  ,p_information119                in varchar2 default hr_api.g_varchar2
  ,p_information120                in varchar2 default hr_api.g_varchar2
  ,p_information121                in varchar2 default hr_api.g_varchar2
  ,p_information122                in varchar2 default hr_api.g_varchar2
  ,p_information123                in varchar2 default hr_api.g_varchar2
  ,p_information124                in varchar2 default hr_api.g_varchar2
  ,p_information125                in varchar2 default hr_api.g_varchar2
  ,p_information126                in varchar2 default hr_api.g_varchar2
  ,p_information127                in varchar2 default hr_api.g_varchar2
  ,p_information128                in varchar2 default hr_api.g_varchar2
  ,p_information129                in varchar2 default hr_api.g_varchar2
  ,p_information130                in varchar2 default hr_api.g_varchar2
  ,p_information131                in varchar2 default hr_api.g_varchar2
  ,p_information132                in varchar2 default hr_api.g_varchar2
  ,p_information133                in varchar2 default hr_api.g_varchar2
  ,p_information134                in varchar2 default hr_api.g_varchar2
  ,p_information135                in varchar2 default hr_api.g_varchar2
  ,p_information136                in varchar2 default hr_api.g_varchar2
  ,p_information137                in varchar2 default hr_api.g_varchar2
  ,p_information138                in varchar2 default hr_api.g_varchar2
  ,p_information139                in varchar2 default hr_api.g_varchar2
  ,p_information140                in varchar2 default hr_api.g_varchar2
  ,p_information141                in varchar2 default hr_api.g_varchar2
  ,p_information142                in varchar2 default hr_api.g_varchar2
  ,p_information143                in varchar2 default hr_api.g_varchar2
  ,p_information144                in varchar2 default hr_api.g_varchar2
  ,p_information145                in varchar2 default hr_api.g_varchar2
  ,p_information146                in varchar2 default hr_api.g_varchar2
  ,p_information147                in varchar2 default hr_api.g_varchar2
  ,p_information148                in varchar2 default hr_api.g_varchar2
  ,p_information149                in varchar2 default hr_api.g_varchar2
  ,p_information150                in varchar2 default hr_api.g_varchar2
  ,p_information151                in varchar2 default hr_api.g_varchar2
  ,p_information152                in varchar2 default hr_api.g_varchar2
  ,p_information153                in varchar2 default hr_api.g_varchar2
  ,p_information154                in varchar2 default hr_api.g_varchar2
  ,p_information155                in varchar2 default hr_api.g_varchar2
  ,p_information156                in varchar2 default hr_api.g_varchar2
  ,p_information157                in varchar2 default hr_api.g_varchar2
  ,p_information158                in varchar2 default hr_api.g_varchar2
  ,p_information159                in varchar2 default hr_api.g_varchar2
  ,p_information160                in varchar2 default hr_api.g_varchar2
  ,p_information161                in varchar2 default hr_api.g_varchar2
  ,p_information162                in varchar2 default hr_api.g_varchar2
  ,p_information163                in varchar2 default hr_api.g_varchar2
  ,p_information164                in varchar2 default hr_api.g_varchar2
  ,p_information165                in varchar2 default hr_api.g_varchar2
  ,p_information166                in varchar2 default hr_api.g_varchar2
  ,p_information167                in varchar2 default hr_api.g_varchar2
  ,p_information168                in varchar2 default hr_api.g_varchar2
  ,p_information169                in varchar2 default hr_api.g_varchar2
  ,p_information170                in varchar2 default hr_api.g_varchar2
  ,p_information171                in varchar2 default hr_api.g_varchar2
  ,p_information172                in varchar2 default hr_api.g_varchar2
  ,p_information173                in varchar2 default hr_api.g_varchar2
  ,p_information174                in varchar2 default hr_api.g_varchar2
  ,p_information175                in varchar2 default hr_api.g_varchar2
  ,p_information176                in varchar2 default hr_api.g_varchar2
  ,p_information177                in varchar2 default hr_api.g_varchar2
  ,p_information178                in varchar2 default hr_api.g_varchar2
  ,p_information179                in varchar2 default hr_api.g_varchar2
  ,p_information180                in varchar2 default hr_api.g_varchar2
  ,p_information181                in varchar2 default hr_api.g_varchar2
  ,p_information182                in varchar2 default hr_api.g_varchar2
  ,p_information183                in varchar2 default hr_api.g_varchar2
  ,p_information184                in varchar2 default hr_api.g_varchar2
  ,p_information185                in varchar2 default hr_api.g_varchar2
  ,p_information186                in varchar2 default hr_api.g_varchar2
  ,p_information187                in varchar2 default hr_api.g_varchar2
  ,p_information188                in varchar2 default hr_api.g_varchar2
  ,p_information189                in varchar2 default hr_api.g_varchar2
  ,p_information190                in varchar2 default hr_api.g_varchar2
  ,p_mirror_entity_result_id       in  number  default hr_api.g_number
  ,p_mirror_src_entity_result_id   in  number  default hr_api.g_number
  ,p_parent_entity_result_id       in  number  default hr_api.g_number
  ,p_table_route_id                in  number  default hr_api.g_number
  ,p_long_attribute1               in  long
  ,p_object_version_number      in out nocopy number
  ,p_effective_date                in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_copy_entity_result';
  l_object_version_number pqh_copy_entity_results.object_version_number%TYPE ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_copy_entity_result;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_copy_entity_results
    --
    pqh_copy_entity_results_bk2.update_copy_entity_result_b
      (
       p_copy_entity_result_id          =>  p_copy_entity_result_id
      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_result_type_cd                 =>  p_result_type_cd
      ,p_number_of_copies               =>  p_number_of_copies
      ,p_status                         =>  p_status
      ,p_src_copy_entity_result_id      =>  p_src_copy_entity_result_id
      ,p_information_category           =>  p_information_category
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information31                  =>  p_information31
      ,p_information32                  =>  p_information32
      ,p_information33                  =>  p_information33
      ,p_information34                  =>  p_information34
      ,p_information35                  =>  p_information35
      ,p_information36                  =>  p_information36
      ,p_information37                  =>  p_information37
      ,p_information38                  =>  p_information38
      ,p_information39                  =>  p_information39
      ,p_information40                  =>  p_information40
      ,p_information41                  =>  p_information41
      ,p_information42                  =>  p_information42
      ,p_information43                  =>  p_information43
      ,p_information44                  =>  p_information44
      ,p_information45                  =>  p_information45
      ,p_information46                  =>  p_information46
      ,p_information47                  =>  p_information47
      ,p_information48                  =>  p_information48
      ,p_information49                  =>  p_information49
      ,p_information50                  =>  p_information50
      ,p_information51                  =>  p_information51
      ,p_information52                  =>  p_information52
      ,p_information53                  =>  p_information53
      ,p_information54                  =>  p_information54
      ,p_information55                  =>  p_information55
      ,p_information56                  =>  p_information56
      ,p_information57                  =>  p_information57
      ,p_information58                  =>  p_information58
      ,p_information59                  =>  p_information59
      ,p_information60                  =>  p_information60
      ,p_information61                  =>  p_information61
      ,p_information62                  =>  p_information62
      ,p_information63                  =>  p_information63
      ,p_information64                  =>  p_information64
      ,p_information65                  =>  p_information65
      ,p_information66                  =>  p_information66
      ,p_information67                  =>  p_information67
      ,p_information68                  =>  p_information68
      ,p_information69                  =>  p_information69
      ,p_information70                  =>  p_information70
      ,p_information71                  =>  p_information71
      ,p_information72                  =>  p_information72
      ,p_information73                  =>  p_information73
      ,p_information74                  =>  p_information74
      ,p_information75                  =>  p_information75
      ,p_information76                  =>  p_information76
      ,p_information77                  =>  p_information77
      ,p_information78                  =>  p_information78
      ,p_information79                  =>  p_information79
      ,p_information80                  =>  p_information80
      ,p_information81                  =>  p_information81
      ,p_information82                  =>  p_information82
      ,p_information83                  =>  p_information83
      ,p_information84                  =>  p_information84
      ,p_information85                  =>  p_information85
      ,p_information86                  =>  p_information86
      ,p_information87                  =>  p_information87
      ,p_information88                  =>  p_information88
      ,p_information89                  =>  p_information89
      ,p_information90                  =>  p_information90
 ,p_information91                 =>p_information91
 ,p_information92                 =>p_information92
 ,p_information93                 =>p_information93
 ,p_information94                 =>p_information94
 ,p_information95                 =>p_information95
 ,p_information96                 =>p_information96
 ,p_information97                 =>p_information97
 ,p_information98                 =>p_information98
 ,p_information99                 =>p_information99
 ,p_information100                =>p_information100
 ,p_information101                =>p_information101
 ,p_information102                =>p_information102
 ,p_information103                =>p_information103
 ,p_information104                =>p_information104
 ,p_information105                =>p_information105
 ,p_information106                =>p_information106
 ,p_information107                =>p_information107
 ,p_information108                =>p_information108
 ,p_information109                =>p_information109
 ,p_information110                =>p_information110
 ,p_information111                =>p_information111
 ,p_information112                =>p_information112
 ,p_information113                =>p_information113
 ,p_information114                =>p_information114
 ,p_information115                =>p_information115
 ,p_information116                =>p_information116
 ,p_information117                =>p_information117
 ,p_information118                =>p_information118
 ,p_information119                =>p_information119
 ,p_information120                =>p_information120
 ,p_information121                =>p_information121
 ,p_information122                =>p_information122
 ,p_information123                =>p_information123
 ,p_information124                =>p_information124
 ,p_information125                =>p_information125
 ,p_information126                =>p_information126
 ,p_information127                =>p_information127
 ,p_information128                =>p_information128
 ,p_information129                =>p_information129
 ,p_information130                =>p_information130
 ,p_information131                =>p_information131
 ,p_information132                =>p_information132
 ,p_information133                =>p_information133
 ,p_information134                =>p_information134
 ,p_information135                =>p_information135
 ,p_information136                =>p_information136
 ,p_information137                =>p_information137
 ,p_information138                =>p_information138
 ,p_information139                =>p_information139
 ,p_information140                =>p_information140
 ,p_information141                =>p_information141
 ,p_information142                =>p_information142
 ,p_information143                =>p_information143
 ,p_information144                =>p_information144
 ,p_information145                =>p_information145
 ,p_information146                =>p_information146
 ,p_information147                =>p_information147
 ,p_information148                =>p_information148
 ,p_information149                =>p_information149
 ,p_information150                =>p_information150
 ,p_information151                =>p_information151
 ,p_information152                =>p_information152
 ,p_information153                =>p_information153
 ,p_information154                =>p_information154
 ,p_information155                =>p_information155
 ,p_information156                =>p_information156
 ,p_information157                =>p_information157
 ,p_information158                =>p_information158
 ,p_information159                =>p_information159
 ,p_information160                =>p_information160
 ,p_information161                =>p_information161
 ,p_information162                =>p_information162
 ,p_information163                =>p_information163
 ,p_information164                =>p_information164
 ,p_information165                =>p_information165
 ,p_information166                =>p_information166
 ,p_information167                =>p_information167
 ,p_information168                =>p_information168
 ,p_information169                =>p_information169
 ,p_information170                =>p_information170
 ,p_information171                =>p_information171
 ,p_information172                =>p_information172
 ,p_information173                =>p_information173
 ,p_information174                =>p_information174
 ,p_information175                =>p_information175
 ,p_information176                =>p_information176
 ,p_information177                =>p_information177
 ,p_information178                =>p_information178
 ,p_information179                =>p_information179
 ,p_information180                =>p_information180
 ,p_information181                =>p_information181
 ,p_information182                =>p_information182
 ,p_information183                =>p_information183
 ,p_information184                =>p_information184
 ,p_information185                =>p_information185
 ,p_information186                =>p_information186
 ,p_information187                =>p_information187
 ,p_information188                =>p_information188
 ,p_information189                =>p_information189
 ,p_information190                =>p_information190
 ,p_mirror_entity_result_id       =>p_mirror_entity_result_id
 ,p_mirror_src_entity_result_id   =>p_mirror_src_entity_result_id
 ,p_parent_entity_result_id       =>p_parent_entity_result_id
 ,p_table_route_id                =>p_table_route_id
 ,p_long_attribute1               =>p_long_attribute1
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_copy_entity_result'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_copy_entity_results
    --
  end;
  --
  pqh_cer_upd.upd
    (
     p_copy_entity_result_id         => p_copy_entity_result_id
    ,p_copy_entity_txn_id            => p_copy_entity_txn_id
    ,p_result_type_cd                => p_result_type_cd
    ,p_number_of_copies              => p_number_of_copies
    ,p_status                        => p_status
    ,p_src_copy_entity_result_id     => p_src_copy_entity_result_id
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_information31                 => p_information31
    ,p_information32                 => p_information32
    ,p_information33                 => p_information33
    ,p_information34                 => p_information34
    ,p_information35                 => p_information35
    ,p_information36                 => p_information36
    ,p_information37                 => p_information37
    ,p_information38                 => p_information38
    ,p_information39                 => p_information39
    ,p_information40                 => p_information40
    ,p_information41                 => p_information41
    ,p_information42                 => p_information42
    ,p_information43                 => p_information43
    ,p_information44                 => p_information44
    ,p_information45                 => p_information45
    ,p_information46                 => p_information46
    ,p_information47                 => p_information47
    ,p_information48                 => p_information48
    ,p_information49                 => p_information49
    ,p_information50                 => p_information50
    ,p_information51                 => p_information51
    ,p_information52                 => p_information52
    ,p_information53                 => p_information53
    ,p_information54                 => p_information54
    ,p_information55                 => p_information55
    ,p_information56                 => p_information56
    ,p_information57                 => p_information57
    ,p_information58                 => p_information58
    ,p_information59                 => p_information59
    ,p_information60                 => p_information60
    ,p_information61                 => p_information61
    ,p_information62                 => p_information62
    ,p_information63                 => p_information63
    ,p_information64                 => p_information64
    ,p_information65                 => p_information65
    ,p_information66                 => p_information66
    ,p_information67                 => p_information67
    ,p_information68                 => p_information68
    ,p_information69                 => p_information69
    ,p_information70                 => p_information70
    ,p_information71                 => p_information71
    ,p_information72                 => p_information72
    ,p_information73                 => p_information73
    ,p_information74                 => p_information74
    ,p_information75                 => p_information75
    ,p_information76                 => p_information76
    ,p_information77                 => p_information77
    ,p_information78                 => p_information78
    ,p_information79                 => p_information79
    ,p_information80                 => p_information80
    ,p_information81                 => p_information81
    ,p_information82                 => p_information82
    ,p_information83                 => p_information83
    ,p_information84                 => p_information84
    ,p_information85                 => p_information85
    ,p_information86                 => p_information86
    ,p_information87                 => p_information87
    ,p_information88                 => p_information88
    ,p_information89                 => p_information89
    ,p_information90                 => p_information90
 ,p_information91                 =>p_information91
 ,p_information92                 =>p_information92
 ,p_information93                 =>p_information93
 ,p_information94                 =>p_information94
 ,p_information95                 =>p_information95
 ,p_information96                 =>p_information96
 ,p_information97                 =>p_information97
 ,p_information98                 =>p_information98
 ,p_information99                 =>p_information99
 ,p_information100                =>p_information100
 ,p_information101                =>p_information101
 ,p_information102                =>p_information102
 ,p_information103                =>p_information103
 ,p_information104                =>p_information104
 ,p_information105                =>p_information105
 ,p_information106                =>p_information106
 ,p_information107                =>p_information107
 ,p_information108                =>p_information108
 ,p_information109                =>p_information109
 ,p_information110                =>p_information110
 ,p_information111                =>p_information111
 ,p_information112                =>p_information112
 ,p_information113                =>p_information113
 ,p_information114                =>p_information114
 ,p_information115                =>p_information115
 ,p_information116                =>p_information116
 ,p_information117                =>p_information117
 ,p_information118                =>p_information118
 ,p_information119                =>p_information119
 ,p_information120                =>p_information120
 ,p_information121                =>p_information121
 ,p_information122                =>p_information122
 ,p_information123                =>p_information123
 ,p_information124                =>p_information124
 ,p_information125                =>p_information125
 ,p_information126                =>p_information126
 ,p_information127                =>p_information127
 ,p_information128                =>p_information128
 ,p_information129                =>p_information129
 ,p_information130                =>p_information130
 ,p_information131                =>p_information131
 ,p_information132                =>p_information132
 ,p_information133                =>p_information133
 ,p_information134                =>p_information134
 ,p_information135                =>p_information135
 ,p_information136                =>p_information136
 ,p_information137                =>p_information137
 ,p_information138                =>p_information138
 ,p_information139                =>p_information139
 ,p_information140                =>p_information140
 ,p_information141                =>p_information141
 ,p_information142                =>p_information142
 ,p_information143                =>p_information143
 ,p_information144                =>p_information144
 ,p_information145                =>p_information145
 ,p_information146                =>p_information146
 ,p_information147                =>p_information147
 ,p_information148                =>p_information148
 ,p_information149                =>p_information149
 ,p_information150                =>p_information150
 ,p_information151                =>p_information151
 ,p_information152                =>p_information152
 ,p_information153                =>p_information153
 ,p_information154                =>p_information154
 ,p_information155                =>p_information155
 ,p_information156                =>p_information156
 ,p_information157                =>p_information157
 ,p_information158                =>p_information158
 ,p_information159                =>p_information159
 ,p_information160                =>p_information160
 ,p_information161                =>p_information161
 ,p_information162                =>p_information162
 ,p_information163                =>p_information163
 ,p_information164                =>p_information164
 ,p_information165                =>p_information165
 ,p_information166                =>p_information166
 ,p_information167                =>p_information167
 ,p_information168                =>p_information168
 ,p_information169                =>p_information169
 ,p_information170                =>p_information170
 ,p_information171                =>p_information171
 ,p_information172                =>p_information172
 ,p_information173                =>p_information173
 ,p_information174                =>p_information174
 ,p_information175                =>p_information175
 ,p_information176                =>p_information176
 ,p_information177                =>p_information177
 ,p_information178                =>p_information178
 ,p_information179                =>p_information179
 ,p_information180                =>p_information180
 ,p_information181                =>p_information181
 ,p_information182                =>p_information182
 ,p_information183                =>p_information183
 ,p_information184                =>p_information184
 ,p_information185                =>p_information185
 ,p_information186                =>p_information186
 ,p_information187                =>p_information187
 ,p_information188                =>p_information188
 ,p_information189                =>p_information189
 ,p_information190                =>p_information190
 ,p_mirror_entity_result_id       =>p_mirror_entity_result_id
 ,p_mirror_src_entity_result_id   =>p_mirror_src_entity_result_id
 ,p_parent_entity_result_id       =>p_parent_entity_result_id
 ,p_table_route_id                =>p_table_route_id
 ,p_long_attribute1               =>p_long_attribute1
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_copy_entity_results
    --
    pqh_copy_entity_results_bk2.update_copy_entity_result_a
      (
       p_copy_entity_result_id          =>  p_copy_entity_result_id
      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_result_type_cd                 =>  p_result_type_cd
      ,p_number_of_copies               =>  p_number_of_copies
      ,p_status                         =>  p_status
      ,p_src_copy_entity_result_id      =>  p_src_copy_entity_result_id
      ,p_information_category           =>  p_information_category
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information31                  =>  p_information31
      ,p_information32                  =>  p_information32
      ,p_information33                  =>  p_information33
      ,p_information34                  =>  p_information34
      ,p_information35                  =>  p_information35
      ,p_information36                  =>  p_information36
      ,p_information37                  =>  p_information37
      ,p_information38                  =>  p_information38
      ,p_information39                  =>  p_information39
      ,p_information40                  =>  p_information40
      ,p_information41                  =>  p_information41
      ,p_information42                  =>  p_information42
      ,p_information43                  =>  p_information43
      ,p_information44                  =>  p_information44
      ,p_information45                  =>  p_information45
      ,p_information46                  =>  p_information46
      ,p_information47                  =>  p_information47
      ,p_information48                  =>  p_information48
      ,p_information49                  =>  p_information49
      ,p_information50                  =>  p_information50
      ,p_information51                  =>  p_information51
      ,p_information52                  =>  p_information52
      ,p_information53                  =>  p_information53
      ,p_information54                  =>  p_information54
      ,p_information55                  =>  p_information55
      ,p_information56                  =>  p_information56
      ,p_information57                  =>  p_information57
      ,p_information58                  =>  p_information58
      ,p_information59                  =>  p_information59
      ,p_information60                  =>  p_information60
      ,p_information61                  =>  p_information61
      ,p_information62                  =>  p_information62
      ,p_information63                  =>  p_information63
      ,p_information64                  =>  p_information64
      ,p_information65                  =>  p_information65
      ,p_information66                  =>  p_information66
      ,p_information67                  =>  p_information67
      ,p_information68                  =>  p_information68
      ,p_information69                  =>  p_information69
      ,p_information70                  =>  p_information70
      ,p_information71                  =>  p_information71
      ,p_information72                  =>  p_information72
      ,p_information73                  =>  p_information73
      ,p_information74                  =>  p_information74
      ,p_information75                  =>  p_information75
      ,p_information76                  =>  p_information76
      ,p_information77                  =>  p_information77
      ,p_information78                  =>  p_information78
      ,p_information79                  =>  p_information79
      ,p_information80                  =>  p_information80
      ,p_information81                  =>  p_information81
      ,p_information82                  =>  p_information82
      ,p_information83                  =>  p_information83
      ,p_information84                  =>  p_information84
      ,p_information85                  =>  p_information85
      ,p_information86                  =>  p_information86
      ,p_information87                  =>  p_information87
      ,p_information88                  =>  p_information88
      ,p_information89                  =>  p_information89
      ,p_information90                  =>  p_information90
 ,p_information91                 =>p_information91
 ,p_information92                 =>p_information92
 ,p_information93                 =>p_information93
 ,p_information94                 =>p_information94
 ,p_information95                 =>p_information95
 ,p_information96                 =>p_information96
 ,p_information97                 =>p_information97
 ,p_information98                 =>p_information98
 ,p_information99                 =>p_information99
 ,p_information100                =>p_information100
 ,p_information101                =>p_information101
 ,p_information102                =>p_information102
 ,p_information103                =>p_information103
 ,p_information104                =>p_information104
 ,p_information105                =>p_information105
 ,p_information106                =>p_information106
 ,p_information107                =>p_information107
 ,p_information108                =>p_information108
 ,p_information109                =>p_information109
 ,p_information110                =>p_information110
 ,p_information111                =>p_information111
 ,p_information112                =>p_information112
 ,p_information113                =>p_information113
 ,p_information114                =>p_information114
 ,p_information115                =>p_information115
 ,p_information116                =>p_information116
 ,p_information117                =>p_information117
 ,p_information118                =>p_information118
 ,p_information119                =>p_information119
 ,p_information120                =>p_information120
 ,p_information121                =>p_information121
 ,p_information122                =>p_information122
 ,p_information123                =>p_information123
 ,p_information124                =>p_information124
 ,p_information125                =>p_information125
 ,p_information126                =>p_information126
 ,p_information127                =>p_information127
 ,p_information128                =>p_information128
 ,p_information129                =>p_information129
 ,p_information130                =>p_information130
 ,p_information131                =>p_information131
 ,p_information132                =>p_information132
 ,p_information133                =>p_information133
 ,p_information134                =>p_information134
 ,p_information135                =>p_information135
 ,p_information136                =>p_information136
 ,p_information137                =>p_information137
 ,p_information138                =>p_information138
 ,p_information139                =>p_information139
 ,p_information140                =>p_information140
 ,p_information141                =>p_information141
 ,p_information142                =>p_information142
 ,p_information143                =>p_information143
 ,p_information144                =>p_information144
 ,p_information145                =>p_information145
 ,p_information146                =>p_information146
 ,p_information147                =>p_information147
 ,p_information148                =>p_information148
 ,p_information149                =>p_information149
 ,p_information150                =>p_information150
 ,p_information151                =>p_information151
 ,p_information152                =>p_information152
 ,p_information153                =>p_information153
 ,p_information154                =>p_information154
 ,p_information155                =>p_information155
 ,p_information156                =>p_information156
 ,p_information157                =>p_information157
 ,p_information158                =>p_information158
 ,p_information159                =>p_information159
 ,p_information160                =>p_information160
 ,p_information161                =>p_information161
 ,p_information162                =>p_information162
 ,p_information163                =>p_information163
 ,p_information164                =>p_information164
 ,p_information165                =>p_information165
 ,p_information166                =>p_information166
 ,p_information167                =>p_information167
 ,p_information168                =>p_information168
 ,p_information169                =>p_information169
 ,p_information170                =>p_information170
 ,p_information171                =>p_information171
 ,p_information172                =>p_information172
 ,p_information173                =>p_information173
 ,p_information174                =>p_information174
 ,p_information175                =>p_information175
 ,p_information176                =>p_information176
 ,p_information177                =>p_information177
 ,p_information178                =>p_information178
 ,p_information179                =>p_information179
 ,p_information180                =>p_information180
 ,p_information181                =>p_information181
 ,p_information182                =>p_information182
 ,p_information183                =>p_information183
 ,p_information184                =>p_information184
 ,p_information185                =>p_information185
 ,p_information186                =>p_information186
 ,p_information187                =>p_information187
 ,p_information188                =>p_information188
 ,p_information189                =>p_information189
 ,p_information190                =>p_information190
 ,p_mirror_entity_result_id       =>p_mirror_entity_result_id
 ,p_mirror_src_entity_result_id   =>p_mirror_src_entity_result_id
 ,p_parent_entity_result_id       =>p_parent_entity_result_id
 ,p_table_route_id                =>p_table_route_id
 ,p_long_attribute1               =>p_long_attribute1
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_copy_entity_result'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_copy_entity_results
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_copy_entity_result;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
  p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_copy_entity_result;
    raise;
    --
end update_copy_entity_result;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_result >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_result
  (p_validate                       in  boolean  default false
  ,p_copy_entity_result_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_copy_entity_result';
  l_object_version_number pqh_copy_entity_results.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_copy_entity_result;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_copy_entity_results
    --
    pqh_copy_entity_results_bk3.delete_copy_entity_result_b
      (
       p_copy_entity_result_id          =>  p_copy_entity_result_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_copy_entity_result'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_copy_entity_results
    --
  end;
  --
  pqh_cer_del.del
    (
     p_copy_entity_result_id         => p_copy_entity_result_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_copy_entity_results
    --
    pqh_copy_entity_results_bk3.delete_copy_entity_result_a
      (
       p_copy_entity_result_id          =>  p_copy_entity_result_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_copy_entity_result'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_copy_entity_results
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_copy_entity_result;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_copy_entity_result;
    raise;
    --
end delete_copy_entity_result;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_copy_entity_result_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pqh_cer_shd.lck
    (
      p_copy_entity_result_id                 => p_copy_entity_result_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_copy_entity_results_api;

/
