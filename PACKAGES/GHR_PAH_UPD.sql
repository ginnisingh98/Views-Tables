--------------------------------------------------------
--  DDL for Package GHR_PAH_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PAH_UPD" AUTHID CURRENT_USER as
/* $Header: ghpahrhi.pkh 120.0 2005/05/29 03:23:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
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
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
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
  (
  p_rec        in out nocopy ghr_pah_shd.g_rec_type
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
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
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
  (
  p_pa_history_id                in number,
  p_pa_request_id                in number           default hr_api.g_number,
  p_process_date                 in date             default hr_api.g_date,
  p_nature_of_action_id          in number           default hr_api.g_number,
  p_effective_date               in date             default hr_api.g_date,
  p_altered_pa_request_id        in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_assignment_id                in number           default hr_api.g_number,
  p_dml_operation                in varchar2         default hr_api.g_varchar2,
  p_table_name                   in varchar2         default hr_api.g_varchar2,
  p_pre_values_flag              in varchar2         default hr_api.g_varchar2,
  p_information1                 in varchar2         default hr_api.g_varchar2,
  p_information2                 in varchar2         default hr_api.g_varchar2,
  p_information3                 in varchar2         default hr_api.g_varchar2,
  p_information4                 in varchar2         default hr_api.g_varchar2,
  p_information5                 in varchar2         default hr_api.g_varchar2,
  p_information6                 in varchar2         default hr_api.g_varchar2,
  p_information7                 in varchar2         default hr_api.g_varchar2,
  p_information8                 in varchar2         default hr_api.g_varchar2,
  p_information9                 in varchar2         default hr_api.g_varchar2,
  p_information10                in varchar2         default hr_api.g_varchar2,
  p_information11                in varchar2         default hr_api.g_varchar2,
  p_information12                in varchar2         default hr_api.g_varchar2,
  p_information13                in varchar2         default hr_api.g_varchar2,
  p_information14                in varchar2         default hr_api.g_varchar2,
  p_information15                in varchar2         default hr_api.g_varchar2,
  p_information16                in varchar2         default hr_api.g_varchar2,
  p_information17                in varchar2         default hr_api.g_varchar2,
  p_information18                in varchar2         default hr_api.g_varchar2,
  p_information19                in varchar2         default hr_api.g_varchar2,
  p_information20                in varchar2         default hr_api.g_varchar2,
  p_information21                in varchar2         default hr_api.g_varchar2,
  p_information22                in varchar2         default hr_api.g_varchar2,
  p_information23                in varchar2         default hr_api.g_varchar2,
  p_information24                in varchar2         default hr_api.g_varchar2,
  p_information25                in varchar2         default hr_api.g_varchar2,
  p_information26                in varchar2         default hr_api.g_varchar2,
  p_information27                in varchar2         default hr_api.g_varchar2,
  p_information28                in varchar2         default hr_api.g_varchar2,
  p_information29                in varchar2         default hr_api.g_varchar2,
  p_information30                in varchar2         default hr_api.g_varchar2,
  p_information31                in varchar2         default hr_api.g_varchar2,
  p_information32                in varchar2         default hr_api.g_varchar2,
  p_information33                in varchar2         default hr_api.g_varchar2,
  p_information34                in varchar2         default hr_api.g_varchar2,
  p_information35                in varchar2         default hr_api.g_varchar2,
  p_information36                in varchar2         default hr_api.g_varchar2,
  p_information37                in varchar2         default hr_api.g_varchar2,
  p_information38                in varchar2         default hr_api.g_varchar2,
  p_information39                in varchar2         default hr_api.g_varchar2,
  p_information47                in varchar2         default hr_api.g_varchar2,
  p_information48                in varchar2         default hr_api.g_varchar2,
  p_information49                in varchar2         default hr_api.g_varchar2,
  p_information40                in varchar2         default hr_api.g_varchar2,
  p_information41                in varchar2         default hr_api.g_varchar2,
  p_information42                in varchar2         default hr_api.g_varchar2,
  p_information43                in varchar2         default hr_api.g_varchar2,
  p_information44                in varchar2         default hr_api.g_varchar2,
  p_information45                in varchar2         default hr_api.g_varchar2,
  p_information46                in varchar2         default hr_api.g_varchar2,
  p_information50                in varchar2         default hr_api.g_varchar2,
  p_information51                in varchar2         default hr_api.g_varchar2,
  p_information52                in varchar2         default hr_api.g_varchar2,
  p_information53                in varchar2         default hr_api.g_varchar2,
  p_information54                in varchar2         default hr_api.g_varchar2,
  p_information55                in varchar2         default hr_api.g_varchar2,
  p_information56                in varchar2         default hr_api.g_varchar2,
  p_information57                in varchar2         default hr_api.g_varchar2,
  p_information58                in varchar2         default hr_api.g_varchar2,
  p_information59                in varchar2         default hr_api.g_varchar2,
  p_information60                in varchar2         default hr_api.g_varchar2,
  p_information61                in varchar2         default hr_api.g_varchar2,
  p_information62                in varchar2         default hr_api.g_varchar2,
  p_information63                in varchar2         default hr_api.g_varchar2,
  p_information64                in varchar2         default hr_api.g_varchar2,
  p_information65                in varchar2         default hr_api.g_varchar2,
  p_information66                in varchar2         default hr_api.g_varchar2,
  p_information67                in varchar2         default hr_api.g_varchar2,
  p_information68                in varchar2         default hr_api.g_varchar2,
  p_information69                in varchar2         default hr_api.g_varchar2,
  p_information70                in varchar2         default hr_api.g_varchar2,
  p_information71                in varchar2         default hr_api.g_varchar2,
  p_information72                in varchar2         default hr_api.g_varchar2,
  p_information73                in varchar2         default hr_api.g_varchar2,
  p_information74                in varchar2         default hr_api.g_varchar2,
  p_information75                in varchar2         default hr_api.g_varchar2,
  p_information76                in varchar2         default hr_api.g_varchar2,
  p_information77                in varchar2         default hr_api.g_varchar2,
  p_information78                in varchar2         default hr_api.g_varchar2,
  p_information79                in varchar2         default hr_api.g_varchar2,
  p_information80                in varchar2         default hr_api.g_varchar2,
  p_information81                in varchar2         default hr_api.g_varchar2,
  p_information82                in varchar2         default hr_api.g_varchar2,
  p_information83                in varchar2         default hr_api.g_varchar2,
  p_information84                in varchar2         default hr_api.g_varchar2,
  p_information85                in varchar2         default hr_api.g_varchar2,
  p_information86                in varchar2         default hr_api.g_varchar2,
  p_information87                in varchar2         default hr_api.g_varchar2,
  p_information88                in varchar2         default hr_api.g_varchar2,
  p_information89                in varchar2         default hr_api.g_varchar2,
  p_information90                in varchar2         default hr_api.g_varchar2,
  p_information91                in varchar2         default hr_api.g_varchar2,
  p_information92                in varchar2         default hr_api.g_varchar2,
  p_information93                in varchar2         default hr_api.g_varchar2,
  p_information94                in varchar2         default hr_api.g_varchar2,
  p_information95                in varchar2         default hr_api.g_varchar2,
  p_information96                in varchar2         default hr_api.g_varchar2,
  p_information97                in varchar2         default hr_api.g_varchar2,
  p_information98                in varchar2         default hr_api.g_varchar2,
  p_information99                in varchar2         default hr_api.g_varchar2,
  p_information100               in varchar2         default hr_api.g_varchar2,
  p_information101               in varchar2         default hr_api.g_varchar2,
  p_information102               in varchar2         default hr_api.g_varchar2,
  p_information103               in varchar2         default hr_api.g_varchar2,
  p_information104               in varchar2         default hr_api.g_varchar2,
  p_information105               in varchar2         default hr_api.g_varchar2,
  p_information106               in varchar2         default hr_api.g_varchar2,
  p_information107               in varchar2         default hr_api.g_varchar2,
  p_information108               in varchar2         default hr_api.g_varchar2,
  p_information109               in varchar2         default hr_api.g_varchar2,
  p_information110               in varchar2         default hr_api.g_varchar2,
  p_information111               in varchar2         default hr_api.g_varchar2,
  p_information112               in varchar2         default hr_api.g_varchar2,
  p_information113               in varchar2         default hr_api.g_varchar2,
  p_information114               in varchar2         default hr_api.g_varchar2,
  p_information115               in varchar2         default hr_api.g_varchar2,
  p_information116               in varchar2         default hr_api.g_varchar2,
  p_information117               in varchar2         default hr_api.g_varchar2,
  p_information118               in varchar2         default hr_api.g_varchar2,
  p_information119               in varchar2         default hr_api.g_varchar2,
  p_information120               in varchar2         default hr_api.g_varchar2,
  p_information121               in varchar2         default hr_api.g_varchar2,
  p_information122               in varchar2         default hr_api.g_varchar2,
  p_information123               in varchar2         default hr_api.g_varchar2,
  p_information124               in varchar2         default hr_api.g_varchar2,
  p_information125               in varchar2         default hr_api.g_varchar2,
  p_information126               in varchar2         default hr_api.g_varchar2,
  p_information127               in varchar2         default hr_api.g_varchar2,
  p_information128               in varchar2         default hr_api.g_varchar2,
  p_information129               in varchar2         default hr_api.g_varchar2,
  p_information130               in varchar2         default hr_api.g_varchar2,
  p_information131               in varchar2         default hr_api.g_varchar2,
  p_information132               in varchar2         default hr_api.g_varchar2,
  p_information133               in varchar2         default hr_api.g_varchar2,
  p_information134               in varchar2         default hr_api.g_varchar2,
  p_information135               in varchar2         default hr_api.g_varchar2,
  p_information136               in varchar2         default hr_api.g_varchar2,
  p_information137               in varchar2         default hr_api.g_varchar2,
  p_information138               in varchar2         default hr_api.g_varchar2,
  p_information139               in varchar2         default hr_api.g_varchar2,
  p_information140               in varchar2         default hr_api.g_varchar2,
  p_information141               in varchar2         default hr_api.g_varchar2,
  p_information142               in varchar2         default hr_api.g_varchar2,
  p_information143               in varchar2         default hr_api.g_varchar2,
  p_information144               in varchar2         default hr_api.g_varchar2,
  p_information145               in varchar2         default hr_api.g_varchar2,
  p_information146               in varchar2         default hr_api.g_varchar2,
  p_information147               in varchar2         default hr_api.g_varchar2,
  p_information148               in varchar2         default hr_api.g_varchar2,
  p_information149               in varchar2         default hr_api.g_varchar2,
  p_information150               in varchar2         default hr_api.g_varchar2,
  p_information151               in varchar2         default hr_api.g_varchar2,
  p_information152               in varchar2         default hr_api.g_varchar2,
  p_information153               in varchar2         default hr_api.g_varchar2,
  p_information154               in varchar2         default hr_api.g_varchar2,
  p_information155               in varchar2         default hr_api.g_varchar2,
  p_information156               in varchar2         default hr_api.g_varchar2,
  p_information157               in varchar2         default hr_api.g_varchar2,
  p_information158               in varchar2         default hr_api.g_varchar2,
  p_information159               in varchar2         default hr_api.g_varchar2,
  p_information160               in varchar2         default hr_api.g_varchar2,
  p_information161               in varchar2         default hr_api.g_varchar2,
  p_information162               in varchar2         default hr_api.g_varchar2,
  p_information163               in varchar2         default hr_api.g_varchar2,
  p_information164               in varchar2         default hr_api.g_varchar2,
  p_information165               in varchar2         default hr_api.g_varchar2,
  p_information166               in varchar2         default hr_api.g_varchar2,
  p_information167               in varchar2         default hr_api.g_varchar2,
  p_information168               in varchar2         default hr_api.g_varchar2,
  p_information169               in varchar2         default hr_api.g_varchar2,
  p_information170               in varchar2         default hr_api.g_varchar2,
  p_information171               in varchar2         default hr_api.g_varchar2,
  p_information172               in varchar2         default hr_api.g_varchar2,
  p_information173               in varchar2         default hr_api.g_varchar2,
  p_information174               in varchar2         default hr_api.g_varchar2,
  p_information175               in varchar2         default hr_api.g_varchar2,
  p_information176               in varchar2         default hr_api.g_varchar2,
  p_information177               in varchar2         default hr_api.g_varchar2,
  p_information178               in varchar2         default hr_api.g_varchar2,
  p_information179               in varchar2         default hr_api.g_varchar2,
  p_information180               in varchar2         default hr_api.g_varchar2,
  p_information181               in varchar2         default hr_api.g_varchar2,
  p_information182               in varchar2         default hr_api.g_varchar2,
  p_information183               in varchar2         default hr_api.g_varchar2,
  p_information184               in varchar2         default hr_api.g_varchar2,
  p_information185               in varchar2         default hr_api.g_varchar2,
  p_information186               in varchar2         default hr_api.g_varchar2,
  p_information187               in varchar2         default hr_api.g_varchar2,
  p_information188               in varchar2         default hr_api.g_varchar2,
  p_information189               in varchar2         default hr_api.g_varchar2,
  p_information190               in varchar2         default hr_api.g_varchar2,
  p_information191               in varchar2         default hr_api.g_varchar2,
  p_information192               in varchar2         default hr_api.g_varchar2,
  p_information193               in varchar2         default hr_api.g_varchar2,
  p_information194               in varchar2         default hr_api.g_varchar2,
  p_information195               in varchar2         default hr_api.g_varchar2,
  p_information196               in varchar2         default hr_api.g_varchar2,
  p_information197               in varchar2         default hr_api.g_varchar2,
  p_information198               in varchar2         default hr_api.g_varchar2,
  p_information199               in varchar2         default hr_api.g_varchar2,
  p_information200               in varchar2         default hr_api.g_varchar2
  );
--
end ghr_pah_upd;

 

/
