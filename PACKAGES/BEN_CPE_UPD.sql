--------------------------------------------------------
--  DDL for Package BEN_CPE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPE_UPD" AUTHID CURRENT_USER as
/* $Header: becperhi.pkh 120.0 2005/05/28 01:12:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< upd >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   3) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   5) The update_dml process will physical perform the update dml into the
--      specified entity.
--   6) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ben_cpe_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
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
  );
--
end ben_cpe_upd;

 

/
