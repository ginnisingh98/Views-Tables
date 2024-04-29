--------------------------------------------------------
--  DDL for Package Body BEN_COPY_ENTITY_RESULTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COPY_ENTITY_RESULTS_API" as
/* $Header: becpeapi.pkb 120.0 2005/05/28 01:12:04 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_copy_entity_results_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_results >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_copy_entity_results
  (p_validate                       in  boolean   default false
  ,p_effective_date               in     date
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
  -- Declare cursors and local variables
  --
  l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
  l_proc varchar2(72) := g_package||'create_copy_entity_results';
  l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
  --
  cursor c_tbl_rt_id_with_alias is
  select table_route_id
  from pqh_table_route
  where table_alias = p_table_alias;
  --
  cursor c_tbl_rt_id_with_name is
  select table_route_id
  from pqh_table_route
  where where_clause = p_table_name;
  --
  cursor c_tbl_rt_alias_with_id is
  select table_alias
  from pqh_table_route
  where table_route_id = p_table_route_id;
  --
  l_table_route_id pqh_table_route.table_route_id%type;
  l_table_alias pqh_table_route.table_alias%type;
  --
  l_dml_operation  ben_copy_entity_results.dml_operation%type := 'REUSE';
  l_status         ben_copy_entity_results.status%type := 'VALID';
  l_datetrack_mode ben_copy_entity_results.datetrack_mode%type := 'INSERT';

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_copy_entity_results;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- get the table_route_id if it is null
  --
  if p_table_route_id is null then
     --
     if p_table_alias is not null then
        open c_tbl_rt_id_with_alias;
        fetch c_tbl_rt_id_with_alias into l_table_route_id;
        close c_tbl_rt_id_with_alias;
     end if;
     --
     if p_table_name is not null then
        open c_tbl_rt_id_with_name;
        fetch c_tbl_rt_id_with_name into l_table_route_id;
        close c_tbl_rt_id_with_name;
     end if;
     --
   else
    --
    l_table_route_id := p_table_route_id;
    --
  end if;
  --
  -- Plan Copy did not had the requirement to store the table alias
  -- but the PDW requires, to fill this gap need to get the table alias
  --
  if p_table_alias is null then
     --
     open c_tbl_rt_alias_with_id;
     fetch c_tbl_rt_alias_with_id into l_table_alias;
     close c_tbl_rt_alias_with_id;
     --
  else
     --
     l_table_alias := p_table_alias;
     --
  end if;

  --
  -- Process Logic
  --
  ben_cpe_ins.ins
    (
     p_copy_entity_result_id         => l_copy_entity_result_id
    ,p_copy_entity_txn_id              => p_copy_entity_txn_id
    ,p_src_copy_entity_result_id       => p_src_copy_entity_result_id
    ,p_result_type_cd                  => p_result_type_cd
    ,p_number_of_copies                => p_number_of_copies
    ,p_mirror_entity_result_id         => p_mirror_entity_result_id
    ,p_mirror_src_entity_result_id     => p_mirror_src_entity_result_id
    ,p_parent_entity_result_id         => p_parent_entity_result_id
    ,p_pd_mr_src_entity_result_id      => p_pd_mr_src_entity_result_id
    ,p_pd_parent_entity_result_id      => p_pd_parent_entity_result_id
    ,p_gs_mr_src_entity_result_id      => p_gs_mr_src_entity_result_id
    ,p_gs_parent_entity_result_id      => p_gs_parent_entity_result_id
    ,p_table_name                      => p_table_name
    ,p_table_alias                     => l_table_alias
    ,p_table_route_id                  => l_table_route_id
    ,p_status                          => NVL(p_status,l_status)
    ,p_dml_operation                   => NVL(p_dml_operation,l_dml_operation)
    ,p_information_category            => p_information_category
    ,p_information1                    => p_information1
    ,p_information2                    => p_information2
    ,p_information3                    => p_information3
    ,p_information4                    => p_information4
    ,p_information5                    => p_information5
    ,p_information6                    => p_information6
    ,p_information7                    => p_information7
    ,p_information8                    => p_information8
    ,p_information9                    => p_information9
    ,p_information10                   => p_information10
    ,p_information11                   => p_information11
    ,p_information12                   => p_information12
    ,p_information13                   => p_information13
    ,p_information14                   => p_information14
    ,p_information15                   => p_information15
    ,p_information16                   => p_information16
    ,p_information17                   => p_information17
    ,p_information18                   => p_information18
    ,p_information19                   => p_information19
    ,p_information20                   => p_information20
    ,p_information21                   => p_information21
    ,p_information22                   => p_information22
    ,p_information23                   => p_information23
    ,p_information24                   => p_information24
    ,p_information25                   => p_information25
    ,p_information26                   => p_information26
    ,p_information27                   => p_information27
    ,p_information28                   => p_information28
    ,p_information29                   => p_information29
    ,p_information30                   => p_information30
    ,p_information31                   => p_information31
    ,p_information32                   => p_information32
    ,p_information33                   => p_information33
    ,p_information34                   => p_information34
    ,p_information35                   => p_information35
    ,p_information36                   => p_information36
    ,p_information37                   => p_information37
    ,p_information38                   => p_information38
    ,p_information39                   => p_information39
    ,p_information40                   => p_information40
    ,p_information41                   => p_information41
    ,p_information42                   => p_information42
    ,p_information43                   => p_information43
    ,p_information44                   => p_information44
    ,p_information45                   => p_information45
    ,p_information46                   => p_information46
    ,p_information47                   => p_information47
    ,p_information48                   => p_information48
    ,p_information49                   => p_information49
    ,p_information50                   => p_information50
    ,p_information51                   => p_information51
    ,p_information52                   => p_information52
    ,p_information53                   => p_information53
    ,p_information54                   => p_information54
    ,p_information55                   => p_information55
    ,p_information56                   => p_information56
    ,p_information57                   => p_information57
    ,p_information58                   => p_information58
    ,p_information59                   => p_information59
    ,p_information60                   => p_information60
    ,p_information61                   => p_information61
    ,p_information62                   => p_information62
    ,p_information63                   => p_information63
    ,p_information64                   => p_information64
    ,p_information65                   => p_information65
    ,p_information66                   => p_information66
    ,p_information67                   => p_information67
    ,p_information68                   => p_information68
    ,p_information69                   => p_information69
    ,p_information70                   => p_information70
    ,p_information71                   => p_information71
    ,p_information72                   => p_information72
    ,p_information73                   => p_information73
    ,p_information74                   => p_information74
    ,p_information75                   => p_information75
    ,p_information76                   => p_information76
    ,p_information77                   => p_information77
    ,p_information78                   => p_information78
    ,p_information79                   => p_information79
    ,p_information80                   => p_information80
    ,p_information81                   => p_information81
    ,p_information82                   => p_information82
    ,p_information83                   => p_information83
    ,p_information84                   => p_information84
    ,p_information85                   => p_information85
    ,p_information86                   => p_information86
    ,p_information87                   => p_information87
    ,p_information88                   => p_information88
    ,p_information89                   => p_information89
    ,p_information90                   => p_information90
    ,p_information91                   => p_information91
    ,p_information92                   => p_information92
    ,p_information93                   => p_information93
    ,p_information94                   => p_information94
    ,p_information95                   => p_information95
    ,p_information96                   => p_information96
    ,p_information97                   => p_information97
    ,p_information98                   => p_information98
    ,p_information99                   => p_information99
    ,p_information100                  => p_information100
    ,p_information101                  => p_information101
    ,p_information102                  => p_information102
    ,p_information103                  => p_information103
    ,p_information104                  => p_information104
    ,p_information105                  => p_information105
    ,p_information106                  => p_information106
    ,p_information107                  => p_information107
    ,p_information108                  => p_information108
    ,p_information109                  => p_information109
    ,p_information110                  => p_information110
    ,p_information111                  => p_information111
    ,p_information112                  => p_information112
    ,p_information113                  => p_information113
    ,p_information114                  => p_information114
    ,p_information115                  => p_information115
    ,p_information116                  => p_information116
    ,p_information117                  => p_information117
    ,p_information118                  => p_information118
    ,p_information119                  => p_information119
    ,p_information120                  => p_information120
    ,p_information121                  => p_information121
    ,p_information122                  => p_information122
    ,p_information123                  => p_information123
    ,p_information124                  => p_information124
    ,p_information125                  => p_information125
    ,p_information126                  => p_information126
    ,p_information127                  => p_information127
    ,p_information128                  => p_information128
    ,p_information129                  => p_information129
    ,p_information130                  => p_information130
    ,p_information131                  => p_information131
    ,p_information132                  => p_information132
    ,p_information133                  => p_information133
    ,p_information134                  => p_information134
    ,p_information135                  => p_information135
    ,p_information136                  => p_information136
    ,p_information137                  => p_information137
    ,p_information138                  => p_information138
    ,p_information139                  => p_information139
    ,p_information140                  => p_information140
    ,p_information141                  => p_information141
    ,p_information142                  => p_information142

    /* Extra Reserved Columns
    ,p_information143                  => p_information143
    ,p_information144                  => p_information144
    ,p_information145                  => p_information145
    ,p_information146                  => p_information146
    ,p_information147                  => p_information147
    ,p_information148                  => p_information148
    ,p_information149                  => p_information149
    ,p_information150                  => p_information150
    */
    ,p_information151                  => p_information151
    ,p_information152                  => p_information152
    ,p_information153                  => p_information153

    /* Extra Reserved Columns
    ,p_information154                  => p_information154
    ,p_information155                  => p_information155
    ,p_information156                  => p_information156
    ,p_information157                  => p_information157
    ,p_information158                  => p_information158
    ,p_information159                  => p_information159
    */
    ,p_information160                  => p_information160
    ,p_information161                  => p_information161
    ,p_information162                  => p_information162

    /* Extra Reserved Columns
    ,p_information163                  => p_information163
    ,p_information164                  => p_information164
    ,p_information165                  => p_information165
    */
    ,p_information166                  => p_information166
    ,p_information167                  => p_information167
    ,p_information168                  => p_information168
    ,p_information169                  => p_information169
    ,p_information170                  => p_information170

    /* Extra Reserved Columns
    ,p_information171                  => p_information171
    ,p_information172                  => p_information172
    */
    ,p_information173                  => p_information173
    ,p_information174                  => p_information174
    ,p_information175                  => p_information175
    ,p_information176                  => p_information176
    ,p_information177                  => p_information177
    ,p_information178                  => p_information178
    ,p_information179                  => p_information179
    ,p_information180                  => p_information180
    ,p_information181                  => p_information181
    ,p_information182                  => p_information182

    /* Extra Reserved Columns
    ,p_information183                  => p_information183
    ,p_information184                  => p_information184
    */
    ,p_information185                  => p_information185
    ,p_information186                  => p_information186
    ,p_information187                  => p_information187
    ,p_information188                  => p_information188

    /* Extra Reserved Columns
    ,p_information189                  => p_information189
    */
    ,p_information190                  => p_information190
    ,p_information191                  => p_information191
    ,p_information192                  => p_information192
    ,p_information193                  => p_information193
    ,p_information194                  => p_information194
    ,p_information195                  => p_information195
    ,p_information196                  => p_information196
    ,p_information197                  => p_information197
    ,p_information198                  => p_information198
    ,p_information199                  => p_information199

    /* Extra Reserved Columns
    ,p_information200                  => p_information200
    ,p_information201                  => p_information201
    ,p_information202                  => p_information202
    ,p_information203                  => p_information203
    ,p_information204                  => p_information204
    ,p_information205                  => p_information205
    ,p_information206                  => p_information206
    ,p_information207                  => p_information207
    ,p_information208                  => p_information208
    ,p_information209                  => p_information209
    ,p_information210                  => p_information210
    ,p_information211                  => p_information211
    ,p_information212                  => p_information212
    ,p_information213                  => p_information213
    ,p_information214                  => p_information214
    ,p_information215                  => p_information215
    */
    ,p_information216                  => p_information216
    ,p_information217                  => p_information217
    ,p_information218                  => p_information218
    ,p_information219                  => p_information219
    ,p_information220                  => p_information220
    ,p_information221                  => p_information221
    ,p_information222                  => p_information222
    ,p_information223                  => p_information223
    ,p_information224                  => p_information224
    ,p_information225                  => p_information225
    ,p_information226                  => p_information226
    ,p_information227                  => p_information227
    ,p_information228                  => p_information228
    ,p_information229                  => p_information229
    ,p_information230                  => p_information230
    ,p_information231                  => p_information231
    ,p_information232                  => p_information232
    ,p_information233                  => p_information233
    ,p_information234                  => p_information234
    ,p_information235                  => p_information235
    ,p_information236                  => p_information236
    ,p_information237                  => p_information237
    ,p_information238                  => p_information238
    ,p_information239                  => p_information239
    ,p_information240                  => p_information240
    ,p_information241                  => p_information241
    ,p_information242                  => p_information242
    ,p_information243                  => p_information243
    ,p_information244                  => p_information244
    ,p_information245                  => p_information245
    ,p_information246                  => p_information246
    ,p_information247                  => p_information247
    ,p_information248                  => p_information248
    ,p_information249                  => p_information249
    ,p_information250                  => p_information250
    ,p_information251                  => p_information251
    ,p_information252                  => p_information252
    ,p_information253                  => p_information253
    ,p_information254                  => p_information254
    ,p_information255                  => p_information255
    ,p_information256                  => p_information256
    ,p_information257                  => p_information257
    ,p_information258                  => p_information258
    ,p_information259                  => p_information259
    ,p_information260                  => p_information260
    ,p_information261                  => p_information261
    ,p_information262                  => p_information262
    ,p_information263                  => p_information263
    ,p_information264                  => p_information264
    ,p_information265                  => p_information265
    ,p_information266                  => p_information266
    ,p_information267                  => p_information267
    ,p_information268                  => p_information268
    ,p_information269                  => p_information269
    ,p_information270                  => p_information270
    ,p_information271                  => p_information271
    ,p_information272                  => p_information272
    ,p_information273                  => p_information273
    ,p_information274                  => p_information274
    ,p_information275                  => p_information275
    ,p_information276                  => p_information276
    ,p_information277                  => p_information277
    ,p_information278                  => p_information278
    ,p_information279                  => p_information279
    ,p_information280                  => p_information280
    ,p_information281                  => p_information281
    ,p_information282                  => p_information282
    ,p_information283                  => p_information283
    ,p_information284                  => p_information284
    ,p_information285                  => p_information285
    ,p_information286                  => p_information286
    ,p_information287                  => p_information287
    ,p_information288                  => p_information288
    ,p_information289                  => p_information289
    ,p_information290                  => p_information290
    ,p_information291                  => p_information291
    ,p_information292                  => p_information292
    ,p_information293                  => p_information293
    ,p_information294                  => p_information294
    ,p_information295                  => p_information295
    ,p_information296                  => p_information296
    ,p_information297                  => p_information297
    ,p_information298                  => p_information298
    ,p_information299                  => p_information299
    ,p_information300                  => p_information300
    ,p_information301                  => p_information301
    ,p_information302                  => p_information302
    ,p_information303                  => p_information303
    ,p_information304                  => p_information304

    /* Extra Reserved Columns
    ,p_information305                  => p_information305
    */
    ,p_information306                  => p_information306
    ,p_information307                  => p_information307
    ,p_information308                  => p_information308
    ,p_information309                  => p_information309
    ,p_information310                  => p_information310
    ,p_information311                  => p_information311
    ,p_information312                  => p_information312
    ,p_information313                  => p_information313
    ,p_information314                  => p_information314
    ,p_information315                  => p_information315
    ,p_information316                  => p_information316
    ,p_information317                  => p_information317
    ,p_information318                  => p_information318
    ,p_information319                  => p_information319
    ,p_information320                  => p_information320

    /* Extra Reserved Columns
    ,p_information321                  => p_information321
    ,p_information322                  => p_information322
    */
    ,p_information323                  => p_information323
    ,p_datetrack_mode                  => NVL(p_datetrack_mode,l_datetrack_mode)
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                  => trunc(p_effective_date)
    );
  --
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
    ROLLBACK TO create_copy_entity_results;
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
    ROLLBACK TO create_copy_entity_results;
    raise;
    --
end create_copy_entity_results;
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_results >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_copy_entity_results
  (p_validate                     in  boolean   default false
  ,p_effective_date               in     date
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
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_copy_entity_results';
  l_object_version_number ben_copy_entity_results.object_version_number%TYPE ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_copy_entity_results;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  ben_cpe_upd.upd
    (
     p_copy_entity_result_id           => P_copy_entity_result_id
    ,p_copy_entity_txn_id              => p_copy_entity_txn_id
    ,p_src_copy_entity_result_id       => p_src_copy_entity_result_id
    ,p_result_type_cd                  => p_result_type_cd
    ,p_number_of_copies                => p_number_of_copies
    ,p_mirror_entity_result_id         => p_mirror_entity_result_id
    ,p_mirror_src_entity_result_id     => p_mirror_src_entity_result_id
    ,p_parent_entity_result_id         => p_parent_entity_result_id
    ,p_pd_mr_src_entity_result_id      => p_pd_mr_src_entity_result_id
    ,p_pd_parent_entity_result_id      => p_pd_parent_entity_result_id
    ,p_gs_mr_src_entity_result_id      => p_gs_mr_src_entity_result_id
    ,p_gs_parent_entity_result_id      => p_gs_parent_entity_result_id
    ,p_table_name                      => p_table_name
    ,p_table_alias                     => p_table_alias
    ,p_table_route_id                  => p_table_route_id
    ,p_status                          => p_status
    ,p_dml_operation                   => p_dml_operation
    ,p_information_category            => p_information_category
    ,p_information1                    => p_information1
    ,p_information2                    => p_information2
    ,p_information3                    => p_information3
    ,p_information4                    => p_information4
    ,p_information5                    => p_information5
    ,p_information6                    => p_information6
    ,p_information7                    => p_information7
    ,p_information8                    => p_information8
    ,p_information9                    => p_information9
    ,p_information10                   => p_information10
    ,p_information11                   => p_information11
    ,p_information12                   => p_information12
    ,p_information13                   => p_information13
    ,p_information14                   => p_information14
    ,p_information15                   => p_information15
    ,p_information16                   => p_information16
    ,p_information17                   => p_information17
    ,p_information18                   => p_information18
    ,p_information19                   => p_information19
    ,p_information20                   => p_information20
    ,p_information21                   => p_information21
    ,p_information22                   => p_information22
    ,p_information23                   => p_information23
    ,p_information24                   => p_information24
    ,p_information25                   => p_information25
    ,p_information26                   => p_information26
    ,p_information27                   => p_information27
    ,p_information28                   => p_information28
    ,p_information29                   => p_information29
    ,p_information30                   => p_information30
    ,p_information31                   => p_information31
    ,p_information32                   => p_information32
    ,p_information33                   => p_information33
    ,p_information34                   => p_information34
    ,p_information35                   => p_information35
    ,p_information36                   => p_information36
    ,p_information37                   => p_information37
    ,p_information38                   => p_information38
    ,p_information39                   => p_information39
    ,p_information40                   => p_information40
    ,p_information41                   => p_information41
    ,p_information42                   => p_information42
    ,p_information43                   => p_information43
    ,p_information44                   => p_information44
    ,p_information45                   => p_information45
    ,p_information46                   => p_information46
    ,p_information47                   => p_information47
    ,p_information48                   => p_information48
    ,p_information49                   => p_information49
    ,p_information50                   => p_information50
    ,p_information51                   => p_information51
    ,p_information52                   => p_information52
    ,p_information53                   => p_information53
    ,p_information54                   => p_information54
    ,p_information55                   => p_information55
    ,p_information56                   => p_information56
    ,p_information57                   => p_information57
    ,p_information58                   => p_information58
    ,p_information59                   => p_information59
    ,p_information60                   => p_information60
    ,p_information61                   => p_information61
    ,p_information62                   => p_information62
    ,p_information63                   => p_information63
    ,p_information64                   => p_information64
    ,p_information65                   => p_information65
    ,p_information66                   => p_information66
    ,p_information67                   => p_information67
    ,p_information68                   => p_information68
    ,p_information69                   => p_information69
    ,p_information70                   => p_information70
    ,p_information71                   => p_information71
    ,p_information72                   => p_information72
    ,p_information73                   => p_information73
    ,p_information74                   => p_information74
    ,p_information75                   => p_information75
    ,p_information76                   => p_information76
    ,p_information77                   => p_information77
    ,p_information78                   => p_information78
    ,p_information79                   => p_information79
    ,p_information80                   => p_information80
    ,p_information81                   => p_information81
    ,p_information82                   => p_information82
    ,p_information83                   => p_information83
    ,p_information84                   => p_information84
    ,p_information85                   => p_information85
    ,p_information86                   => p_information86
    ,p_information87                   => p_information87
    ,p_information88                   => p_information88
    ,p_information89                   => p_information89
    ,p_information90                   => p_information90
    ,p_information91                   => p_information91
    ,p_information92                   => p_information92
    ,p_information93                   => p_information93
    ,p_information94                   => p_information94
    ,p_information95                   => p_information95
    ,p_information96                   => p_information96
    ,p_information97                   => p_information97
    ,p_information98                   => p_information98
    ,p_information99                   => p_information99
    ,p_information100                  => p_information100
    ,p_information101                  => p_information101
    ,p_information102                  => p_information102
    ,p_information103                  => p_information103
    ,p_information104                  => p_information104
    ,p_information105                  => p_information105
    ,p_information106                  => p_information106
    ,p_information107                  => p_information107
    ,p_information108                  => p_information108
    ,p_information109                  => p_information109
    ,p_information110                  => p_information110
    ,p_information111                  => p_information111
    ,p_information112                  => p_information112
    ,p_information113                  => p_information113
    ,p_information114                  => p_information114
    ,p_information115                  => p_information115
    ,p_information116                  => p_information116
    ,p_information117                  => p_information117
    ,p_information118                  => p_information118
    ,p_information119                  => p_information119
    ,p_information120                  => p_information120
    ,p_information121                  => p_information121
    ,p_information122                  => p_information122
    ,p_information123                  => p_information123
    ,p_information124                  => p_information124
    ,p_information125                  => p_information125
    ,p_information126                  => p_information126
    ,p_information127                  => p_information127
    ,p_information128                  => p_information128
    ,p_information129                  => p_information129
    ,p_information130                  => p_information130
    ,p_information131                  => p_information131
    ,p_information132                  => p_information132
    ,p_information133                  => p_information133
    ,p_information134                  => p_information134
    ,p_information135                  => p_information135
    ,p_information136                  => p_information136
    ,p_information137                  => p_information137
    ,p_information138                  => p_information138
    ,p_information139                  => p_information139
    ,p_information140                  => p_information140
    ,p_information141                  => p_information141
    ,p_information142                  => p_information142

    /* Extra Reserved Columns
    ,p_information143                  => p_information143
    ,p_information144                  => p_information144
    ,p_information145                  => p_information145
    ,p_information146                  => p_information146
    ,p_information147                  => p_information147
    ,p_information148                  => p_information148
    ,p_information149                  => p_information149
    ,p_information150                  => p_information150
    */
    ,p_information151                  => p_information151
    ,p_information152                  => p_information152
    ,p_information153                  => p_information153

    /* Extra Reserved Columns
    ,p_information154                  => p_information154
    ,p_information155                  => p_information155
    ,p_information156                  => p_information156
    ,p_information157                  => p_information157
    ,p_information158                  => p_information158
    ,p_information159                  => p_information159
    */
    ,p_information160                  => p_information160
    ,p_information161                  => p_information161
    ,p_information162                  => p_information162

    /* Extra Reserved Columns
    ,p_information163                  => p_information163
    ,p_information164                  => p_information164
    ,p_information165                  => p_information165
    */
    ,p_information166                  => p_information166
    ,p_information167                  => p_information167
    ,p_information168                  => p_information168
    ,p_information169                  => p_information169
    ,p_information170                  => p_information170

    /* Extra Reserved Columns
    ,p_information171                  => p_information171
    ,p_information172                  => p_information172
    */
    ,p_information173                  => p_information173
    ,p_information174                  => p_information174
    ,p_information175                  => p_information175
    ,p_information176                  => p_information176
    ,p_information177                  => p_information177
    ,p_information178                  => p_information178
    ,p_information179                  => p_information179
    ,p_information180                  => p_information180
    ,p_information181                  => p_information181
    ,p_information182                  => p_information182

    /* Extra Reserved Columns
    ,p_information183                  => p_information183
    ,p_information184                  => p_information184
    */
    ,p_information185                  => p_information185
    ,p_information186                  => p_information186
    ,p_information187                  => p_information187
    ,p_information188                  => p_information188

    /* Extra Reserved Columns
    ,p_information189                  => p_information189
    */
    ,p_information190                  => p_information190
    ,p_information191                  => p_information191
    ,p_information192                  => p_information192
    ,p_information193                  => p_information193
    ,p_information194                  => p_information194
    ,p_information195                  => p_information195
    ,p_information196                  => p_information196
    ,p_information197                  => p_information197
    ,p_information198                  => p_information198
    ,p_information199                  => p_information199

  /* Extra Reserved Columns
    ,p_information200                  => p_information200
    ,p_information201                  => p_information201
    ,p_information202                  => p_information202
    ,p_information203                  => p_information203
    ,p_information204                  => p_information204
    ,p_information205                  => p_information205
    ,p_information206                  => p_information206
    ,p_information207                  => p_information207
    ,p_information208                  => p_information208
    ,p_information209                  => p_information209
    ,p_information210                  => p_information210
    ,p_information211                  => p_information211
    ,p_information212                  => p_information212
    ,p_information213                  => p_information213
    ,p_information214                  => p_information214
    ,p_information215                  => p_information215
    */
    ,p_information216                  => p_information216
    ,p_information217                  => p_information217
    ,p_information218                  => p_information218
    ,p_information219                  => p_information219
    ,p_information220                  => p_information220
    ,p_information221                  => p_information221
    ,p_information222                  => p_information222
    ,p_information223                  => p_information223
    ,p_information224                  => p_information224
    ,p_information225                  => p_information225
    ,p_information226                  => p_information226
    ,p_information227                  => p_information227
    ,p_information228                  => p_information228
    ,p_information229                  => p_information229
    ,p_information230                  => p_information230
    ,p_information231                  => p_information231
    ,p_information232                  => p_information232
    ,p_information233                  => p_information233
    ,p_information234                  => p_information234
    ,p_information235                  => p_information235
    ,p_information236                  => p_information236
    ,p_information237                  => p_information237
    ,p_information238                  => p_information238
    ,p_information239                  => p_information239
    ,p_information240                  => p_information240
    ,p_information241                  => p_information241
    ,p_information242                  => p_information242
    ,p_information243                  => p_information243
    ,p_information244                  => p_information244
    ,p_information245                  => p_information245
    ,p_information246                  => p_information246
    ,p_information247                  => p_information247
    ,p_information248                  => p_information248
    ,p_information249                  => p_information249
    ,p_information250                  => p_information250
    ,p_information251                  => p_information251
    ,p_information252                  => p_information252
    ,p_information253                  => p_information253
    ,p_information254                  => p_information254
    ,p_information255                  => p_information255
    ,p_information256                  => p_information256
    ,p_information257                  => p_information257
    ,p_information258                  => p_information258
    ,p_information259                  => p_information259
    ,p_information260                  => p_information260
    ,p_information261                  => p_information261
    ,p_information262                  => p_information262
    ,p_information263                  => p_information263
    ,p_information264                  => p_information264
    ,p_information265                  => p_information265
    ,p_information266                  => p_information266
    ,p_information267                  => p_information267
    ,p_information268                  => p_information268
    ,p_information269                  => p_information269
    ,p_information270                  => p_information270
    ,p_information271                  => p_information271
    ,p_information272                  => p_information272
    ,p_information273                  => p_information273
    ,p_information274                  => p_information274
    ,p_information275                  => p_information275
    ,p_information276                  => p_information276
    ,p_information277                  => p_information277
    ,p_information278                  => p_information278
    ,p_information279                  => p_information279
    ,p_information280                  => p_information280
    ,p_information281                  => p_information281
    ,p_information282                  => p_information282
    ,p_information283                  => p_information283
    ,p_information284                  => p_information284
    ,p_information285                  => p_information285
    ,p_information286                  => p_information286
    ,p_information287                  => p_information287
    ,p_information288                  => p_information288
    ,p_information289                  => p_information289
    ,p_information290                  => p_information290
    ,p_information291                  => p_information291
    ,p_information292                  => p_information292
    ,p_information293                  => p_information293
    ,p_information294                  => p_information294
    ,p_information295                  => p_information295
    ,p_information296                  => p_information296
    ,p_information297                  => p_information297
    ,p_information298                  => p_information298
    ,p_information299                  => p_information299
    ,p_information300                  => p_information300
    ,p_information301                  => p_information301
    ,p_information302                  => p_information302
    ,p_information303                  => p_information303
    ,p_information304                  => p_information304

    /* Extra Reserved Columns
    ,p_information305                  => p_information305
    */
    ,p_information306                  => p_information306
    ,p_information307                  => p_information307
    ,p_information308                  => p_information308
    ,p_information309                  => p_information309
    ,p_information310                  => p_information310
    ,p_information311                  => p_information311
    ,p_information312                  => p_information312
    ,p_information313                  => p_information313
    ,p_information314                  => p_information314
    ,p_information315                  => p_information315
    ,p_information316                  => p_information316
    ,p_information317                  => p_information317
    ,p_information318                  => p_information318
    ,p_information319                  => p_information319
    ,p_information320                  => p_information320

    /* Extra Reserved Columns
    ,p_information321                  => p_information321
    ,p_information322                  => p_information322
    */
    ,p_information323                  => p_information323
    ,p_datetrack_mode                  => p_datetrack_mode
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                  => trunc(p_effective_date)
    );
  --
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
    ROLLBACK TO update_copy_entity_results;
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
    ROLLBACK TO update_copy_entity_results;
    raise;
    --
end update_copy_entity_results;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_results >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_results
  (p_validate                       in  boolean  default false
  ,p_copy_entity_result_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_copy_entity_results';
  l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_copy_entity_results;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  ben_cpe_del.del
    (
     p_copy_entity_result_id         => p_copy_entity_result_id
    ,p_object_version_number         => l_object_version_number
  --   ,p_effective_date                => p_effective_date
    );
  --
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
    ROLLBACK TO delete_copy_entity_results;
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
    ROLLBACK TO delete_copy_entity_results;
    raise;
    --
end delete_copy_entity_results;
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
  ben_cpe_shd.lck
    (
      p_copy_entity_result_id                 => p_copy_entity_result_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_copy_entity_results_api;

/
