--------------------------------------------------------
--  DDL for Package PQH_COPY_ENTITY_RESULTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COPY_ENTITY_RESULTS_API" AUTHID CURRENT_USER as
/* $Header: pqcerapi.pkh 120.0 2005/05/29 01:41:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_result >------------------------|
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
--   p_information_category         No   varchar2
--   p_information1                 No   varchar2
--   p_information2                 No   varchar2
--   p_information3                 No   varchar2
--   p_information4                 No   varchar2
--   p_information5                 No   varchar2
--   p_information6                 No   varchar2
--   p_information7                 No   varchar2
--   p_information8                 No   varchar2
--   p_information9                 No   varchar2
--   p_information10                No   varchar2
--   p_information11                No   varchar2
--   p_information12                No   varchar2
--   p_information13                No   varchar2
--   p_information14                No   varchar2
--   p_information15                No   varchar2
--   p_information16                No   varchar2
--   p_information17                No   varchar2
--   p_information18                No   varchar2
--   p_information19                No   varchar2
--   p_information20                No   varchar2
--   p_information21                No   varchar2
--   p_information22                No   varchar2
--   p_information23                No   varchar2
--   p_information24                No   varchar2
--   p_information25                No   varchar2
--   p_information26                No   varchar2
--   p_information27                No   varchar2
--   p_information28                No   varchar2
--   p_information29                No   varchar2
--   p_information30                No   varchar2
--   p_information31                No   varchar2
--   p_information32                No   varchar2
--   p_information33                No   varchar2
--   p_information34                No   varchar2
--   p_information35                No   varchar2
--   p_information36                No   varchar2
--   p_information37                No   varchar2
--   p_information38                No   varchar2
--   p_information39                No   varchar2
--   p_information40                No   varchar2
--   p_information41                No   varchar2
--   p_information42                No   varchar2
--   p_information43                No   varchar2
--   p_information44                No   varchar2
--   p_information45                No   varchar2
--   p_information46                No   varchar2
--   p_information47                No   varchar2
--   p_information48                No   varchar2
--   p_information49                No   varchar2
--   p_information50                No   varchar2
--   p_information51                No   varchar2
--   p_information52                No   varchar2
--   p_information53                No   varchar2
--   p_information54                No   varchar2
--   p_information55                No   varchar2
--   p_information56                No   varchar2
--   p_information57                No   varchar2
--   p_information58                No   varchar2
--   p_information59                No   varchar2
--   p_information60                No   varchar2
--   p_information61                No   varchar2
--   p_information62                No   varchar2
--   p_information63                No   varchar2
--   p_information64                No   varchar2
--   p_information65                No   varchar2
--   p_information66                No   varchar2
--   p_information67                No   varchar2
--   p_information68                No   varchar2
--   p_information69                No   varchar2
--   p_information70                No   varchar2
--   p_information71                No   varchar2
--   p_information72                No   varchar2
--   p_information73                No   varchar2
--   p_information74                No   varchar2
--   p_information75                No   varchar2
--   p_information76                No   varchar2
--   p_information77                No   varchar2
--   p_information78                No   varchar2
--   p_information79                No   varchar2
--   p_information80                No   varchar2
--   p_information81                No   varchar2
--   p_information82                No   varchar2
--   p_information83                No   varchar2
--   p_information84                No   varchar2
--   p_information85                No   varchar2
--   p_information86                No   varchar2
--   p_information87                No   varchar2
--   p_information88                No   varchar2
--   p_information89                No   varchar2
--   p_information90                No   varchar2
--   ...
--   p_information190               No   varchar2
--   p_mirror_entity_result_id      No   number
--   p_mirror_src_entity_result_id  No   number
--   p_parent_entity_result_id      No   number
--   p_table_route_id               No   number
--   p_long_attribute1              No   long
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
procedure create_copy_entity_result
(
   p_validate                       in boolean    default false
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
  ,p_object_version_number        out nocopy  number
  ,p_effective_date                in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_result >------------------------|
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
--   p_result_type_cd               No   varchar2
--   p_number_of_copes              No   varchar2
--   p_status                       No   varchar2
--   p_src_copy_entity_result_id    No   number
--   p_information_category         No   varchar2
--   p_information1                 No   varchar2
--   p_information2                 No   varchar2
--   p_information3                 No   varchar2
--   p_information4                 No   varchar2
--   p_information5                 No   varchar2
--   p_information6                 No   varchar2
--   p_information7                 No   varchar2
--   p_information8                 No   varchar2
--   p_information9                 No   varchar2
--   p_information10                No   varchar2
--   p_information11                No   varchar2
--   p_information12                No   varchar2
--   p_information13                No   varchar2
--   p_information14                No   varchar2
--   p_information15                No   varchar2
--   p_information16                No   varchar2
--   p_information17                No   varchar2
--   p_information18                No   varchar2
--   p_information19                No   varchar2
--   p_information20                No   varchar2
--   p_information21                No   varchar2
--   p_information22                No   varchar2
--   p_information23                No   varchar2
--   p_information24                No   varchar2
--   p_information25                No   varchar2
--   p_information26                No   varchar2
--   p_information27                No   varchar2
--   p_information28                No   varchar2
--   p_information29                No   varchar2
--   p_information30                No   varchar2
--   p_information31                No   varchar2
--   p_information32                No   varchar2
--   p_information33                No   varchar2
--   p_information34                No   varchar2
--   p_information35                No   varchar2
--   p_information36                No   varchar2
--   p_information37                No   varchar2
--   p_information38                No   varchar2
--   p_information39                No   varchar2
--   p_information40                No   varchar2
--   p_information41                No   varchar2
--   p_information42                No   varchar2
--   p_information43                No   varchar2
--   p_information44                No   varchar2
--   p_information45                No   varchar2
--   p_information46                No   varchar2
--   p_information47                No   varchar2
--   p_information48                No   varchar2
--   p_information49                No   varchar2
--   p_information50                No   varchar2
--   p_information51                No   varchar2
--   p_information52                No   varchar2
--   p_information53                No   varchar2
--   p_information54                No   varchar2
--   p_information55                No   varchar2
--   p_information56                No   varchar2
--   p_information57                No   varchar2
--   p_information58                No   varchar2
--   p_information59                No   varchar2
--   p_information60                No   varchar2
--   p_information61                No   varchar2
--   p_information62                No   varchar2
--   p_information63                No   varchar2
--   p_information64                No   varchar2
--   p_information65                No   varchar2
--   p_information66                No   varchar2
--   p_information67                No   varchar2
--   p_information68                No   varchar2
--   p_information69                No   varchar2
--   p_information70                No   varchar2
--   p_information71                No   varchar2
--   p_information72                No   varchar2
--   p_information73                No   varchar2
--   p_information74                No   varchar2
--   p_information75                No   varchar2
--   p_information76                No   varchar2
--   p_information77                No   varchar2
--   p_information78                No   varchar2
--   p_information79                No   varchar2
--   p_information80                No   varchar2
--   p_information81                No   varchar2
--   p_information82                No   varchar2
--   p_information83                No   varchar2
--   p_information84                No   varchar2
--   p_information85                No   varchar2
--   p_information86                No   varchar2
--   p_information87                No   varchar2
--   p_information88                No   varchar2
--   p_information89                No   varchar2
--   p_information90                No   varchar2
--   ...
--   p_information190               No   varchar2
--   p_mirror_entity_result_id      No   number
--   p_mirror_src_entity_result_id  No   number
--   p_parent_entity_result_id      No   number
--   p_table_route_id               No   number
--   p_long_attribute1              Yes  long
--   p_effective_date          Yes  date       Session Date.
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
procedure update_copy_entity_result
  (
   p_validate                       in boolean    default false
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
  ,p_information91                 in varchar2     default hr_api.g_varchar2
  ,p_information92                 in varchar2     default hr_api.g_varchar2
  ,p_information93                 in varchar2     default hr_api.g_varchar2
  ,p_information94                 in varchar2     default hr_api.g_varchar2
  ,p_information95                 in varchar2     default hr_api.g_varchar2
  ,p_information96                 in varchar2     default hr_api.g_varchar2
  ,p_information97                 in varchar2     default hr_api.g_varchar2
  ,p_information98                 in varchar2     default hr_api.g_varchar2
  ,p_information99                 in varchar2     default hr_api.g_varchar2
  ,p_information100                in varchar2     default hr_api.g_varchar2
  ,p_information101                in varchar2     default hr_api.g_varchar2
  ,p_information102                in varchar2     default hr_api.g_varchar2
  ,p_information103                in varchar2     default hr_api.g_varchar2
  ,p_information104                in varchar2     default hr_api.g_varchar2
  ,p_information105                in varchar2     default hr_api.g_varchar2
  ,p_information106                in varchar2     default hr_api.g_varchar2
  ,p_information107                in varchar2     default hr_api.g_varchar2
  ,p_information108                in varchar2     default hr_api.g_varchar2
  ,p_information109                in varchar2     default hr_api.g_varchar2
  ,p_information110                in varchar2     default hr_api.g_varchar2
  ,p_information111                in varchar2     default hr_api.g_varchar2
  ,p_information112                in varchar2     default hr_api.g_varchar2
  ,p_information113                in varchar2     default hr_api.g_varchar2
  ,p_information114                in varchar2     default hr_api.g_varchar2
  ,p_information115                in varchar2     default hr_api.g_varchar2
  ,p_information116                in varchar2     default hr_api.g_varchar2
  ,p_information117                in varchar2     default hr_api.g_varchar2
  ,p_information118                in varchar2     default hr_api.g_varchar2
  ,p_information119                in varchar2     default hr_api.g_varchar2
  ,p_information120                in varchar2     default hr_api.g_varchar2
  ,p_information121                in varchar2     default hr_api.g_varchar2
  ,p_information122                in varchar2     default hr_api.g_varchar2
  ,p_information123                in varchar2     default hr_api.g_varchar2
  ,p_information124                in varchar2     default hr_api.g_varchar2
  ,p_information125                in varchar2     default hr_api.g_varchar2
  ,p_information126                in varchar2     default hr_api.g_varchar2
  ,p_information127                in varchar2     default hr_api.g_varchar2
  ,p_information128                in varchar2     default hr_api.g_varchar2
  ,p_information129                in varchar2     default hr_api.g_varchar2
  ,p_information130                in varchar2     default hr_api.g_varchar2
  ,p_information131                in varchar2     default hr_api.g_varchar2
  ,p_information132                in varchar2     default hr_api.g_varchar2
  ,p_information133                in varchar2     default hr_api.g_varchar2
  ,p_information134                in varchar2     default hr_api.g_varchar2
  ,p_information135                in varchar2     default hr_api.g_varchar2
  ,p_information136                in varchar2     default hr_api.g_varchar2
  ,p_information137                in varchar2     default hr_api.g_varchar2
  ,p_information138                in varchar2     default hr_api.g_varchar2
  ,p_information139                in varchar2     default hr_api.g_varchar2
  ,p_information140                in varchar2     default hr_api.g_varchar2
  ,p_information141                in varchar2     default hr_api.g_varchar2
  ,p_information142                in varchar2     default hr_api.g_varchar2
  ,p_information143                in varchar2     default hr_api.g_varchar2
  ,p_information144                in varchar2     default hr_api.g_varchar2
  ,p_information145                in varchar2     default hr_api.g_varchar2
  ,p_information146                in varchar2     default hr_api.g_varchar2
  ,p_information147                in varchar2     default hr_api.g_varchar2
  ,p_information148                in varchar2     default hr_api.g_varchar2
  ,p_information149                in varchar2     default hr_api.g_varchar2
  ,p_information150                in varchar2     default hr_api.g_varchar2
  ,p_information151                in varchar2     default hr_api.g_varchar2
  ,p_information152                in varchar2     default hr_api.g_varchar2
  ,p_information153                in varchar2     default hr_api.g_varchar2
  ,p_information154                in varchar2     default hr_api.g_varchar2
  ,p_information155                in varchar2     default hr_api.g_varchar2
  ,p_information156                in varchar2     default hr_api.g_varchar2
  ,p_information157                in varchar2     default hr_api.g_varchar2
  ,p_information158                in varchar2     default hr_api.g_varchar2
  ,p_information159                in varchar2     default hr_api.g_varchar2
  ,p_information160                in varchar2     default hr_api.g_varchar2
  ,p_information161                in varchar2     default hr_api.g_varchar2
  ,p_information162                in varchar2     default hr_api.g_varchar2
  ,p_information163                in varchar2     default hr_api.g_varchar2
  ,p_information164                in varchar2     default hr_api.g_varchar2
  ,p_information165                in varchar2     default hr_api.g_varchar2
  ,p_information166                in varchar2     default hr_api.g_varchar2
  ,p_information167                in varchar2     default hr_api.g_varchar2
  ,p_information168                in varchar2     default hr_api.g_varchar2
  ,p_information169                in varchar2     default hr_api.g_varchar2
  ,p_information170                in varchar2     default hr_api.g_varchar2
  ,p_information171                in varchar2     default hr_api.g_varchar2
  ,p_information172                in varchar2     default hr_api.g_varchar2
  ,p_information173                in varchar2     default hr_api.g_varchar2
  ,p_information174                in varchar2     default hr_api.g_varchar2
  ,p_information175                in varchar2     default hr_api.g_varchar2
  ,p_information176                in varchar2     default hr_api.g_varchar2
  ,p_information177                in varchar2     default hr_api.g_varchar2
  ,p_information178                in varchar2     default hr_api.g_varchar2
  ,p_information179                in varchar2     default hr_api.g_varchar2
  ,p_information180                in varchar2     default hr_api.g_varchar2
  ,p_information181                in varchar2     default hr_api.g_varchar2
  ,p_information182                in varchar2     default hr_api.g_varchar2
  ,p_information183                in varchar2     default hr_api.g_varchar2
  ,p_information184                in varchar2     default hr_api.g_varchar2
  ,p_information185                in varchar2     default hr_api.g_varchar2
  ,p_information186                in varchar2     default hr_api.g_varchar2
  ,p_information187                in varchar2     default hr_api.g_varchar2
  ,p_information188                in varchar2     default hr_api.g_varchar2
  ,p_information189                in varchar2     default hr_api.g_varchar2
  ,p_information190                in varchar2     default hr_api.g_varchar2
  ,p_mirror_entity_result_id       in number       default hr_api.g_number
  ,p_mirror_src_entity_result_id   in number       default hr_api.g_number
  ,p_parent_entity_result_id       in number       default hr_api.g_number
  ,p_table_route_id                in number       default hr_api.g_number
  ,p_long_attribute1               in long
  ,p_object_version_number     in out nocopy number
  ,p_effective_date                in date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_result >------------------------|
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
procedure delete_copy_entity_result
  (
   p_validate                       in boolean        default false
  ,p_copy_entity_result_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date            in date
  );
--
end pqh_copy_entity_results_api;

 

/
