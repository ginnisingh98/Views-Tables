--------------------------------------------------------
--  DDL for Package BEN_COPY_ENTITY_RESULTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COPY_ENTITY_RESULTS_API" AUTHID CURRENT_USER as
/* $Header: becpeapi.pkh 120.0 2005/05/28 01:12:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_results >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_copy_entity_txn_id           Yes  number
--   p_result_type_cd               No   varchar2
--   p_number_of_copies             No   varchar2
--   p_status                       No   varchar2
--   p_src_copy_entity_result_id    No   number
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_effective_date               yes     date
--   p_copy_entity_txn_id             yes     number
--   p_result_type_cd                 yes     varchar2
--   p_src_copy_entity_result_id      no     number
--   p_number_of_copies               no     number
--   p_mirror_entity_result_id        no     number
--   p_mirror_src_entity_result_id    no     number
--   p_parent_entity_result_id        no     number
--   p_pd_mirror_src_entity_result_   no     number
--   p_pd_parent_entity_result_id     no     number
--   p_gs_mirror_src_entity_result_   no     number
--   p_gs_parent_entity_result_id     no     number
--   p_table_name                     no     varchar2
--   p_table_alias                    no     varchar2
--   p_table_route_id                 no     number
--   p_status                         no     varchar2
--   p_dml_operation                  no     varchar2
--   p_information_category           no     varchar2
--   p_information1                   no     number
--   p_information2                   no     date
--   p_information3                   no     date
--   p_information4                   no     number
--   p_information5                   no     varchar2
--   ..
--   p_information9                   no     varchar2
--   p_information10                  no     date
--   p_information11                  no     varchar2
--   ..
--   p_information159                 no     varchar2
--   p_information160                 no     number
--   ..
--   p_information165                 no     number
--   p_information166                 no     date
--   p_information167                 no     date
--   p_information168                 no     date
--   p_information169                 no     number
--   p_information170                 no     varchar2
--   ..
--   p_information173                 no     varchar2
--   p_information174                 no     number
--   p_information175                 no     varchar2
--   p_information176                 no     number
--   p_information177                 no     varchar2
--   p_information178                 no     number
--   p_information179                 no     varchar2
--   p_information180                 no     number
--   ..
--   p_information219                 no     varchar2
--   p_information220                 no     varchar2
--   p_information221                 no     number
--   ..
--   p_information305                 no     number
--   p_information306                 no     date
--   ..
--   p_information321                 no     date
--   p_information322                 no     date
--   p_datetrack_mode                 no     varchar2
--   p_copy_entity_result_id             yes nocopy number
--   p_object_version_number             yes nocopy number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_copy_entity_result_id        Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
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
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_results >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_copy_entity_result_id        Yes  number    PK of record
--   p_copy_entity_txn_id           Yes  number
--   p_number_of_copies             No   varchar2
--   p_status                       No   varchar2
--   p_src_copy_entity_result_id    No   number
--   p_result_type_cd                 yes     varchar2
--   p_mirror_entity_result_id        no     number
--   p_mirror_src_entity_result_id    no     number
--   p_parent_entity_result_id        no     number
--   p_pd_mirror_src_entity_result_   no     number
--   p_pd_parent_entity_result_id     no     number
--   p_gs_mirror_src_entity_result_   no     number
--   p_gs_parent_entity_result_id     no     number
--   p_table_name                     no     varchar2
--   p_table_alias                    no     varchar2
--   p_table_route_id                 no     number
--   p_status                         no     varchar2
--   p_dml_operation                  no     varchar2
--   p_information_category           no     varchar2
--   p_information1                   no     number
--   p_information2                   no     date
--   p_information3                   no     date
--   p_information4                   no     number
--   p_information5                   no     varchar2
--   ..
--   p_information9                   no     varchar2
--   p_information10                  no     date
--   p_information11                  no     varchar2
--   ..
--   p_information159                 no     varchar2
--   p_information160                 no     number
--   ..
--   p_information165                 no     number
--   p_information166                 no     date
--   p_information167                 no     date
--   p_information168                 no     date
--   p_information169                 no     number
--   p_information170                 no     varchar2
--   ..
--   p_information173                 no     varchar2
--   p_information174                 no     number
--   p_information175                 no     varchar2
--   p_information176                 no     number
--   p_information177                 no     varchar2
--   p_information178                 no     number
--   p_information179                 no     varchar2
--   p_information180                 no     number
--   ..
--   p_information219                 no     varchar2
--   p_information220                 no     varchar2
--   p_information221                 no     number
--   ..
--   p_information305                 no     number
--   p_information306                 no     date
--   ..
--   p_information321                 no     date
--   p_information322                 no     date
--   p_datetrack_mode                 no     varchar2
--   p_object_version_number             yes nocopy number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_results >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_copy_entity_result_id        Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_copy_entity_results
  (
   p_validate                       in boolean        default false
  ,p_copy_entity_result_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date            in date
  );
--
end ben_copy_entity_results_api;

 

/
