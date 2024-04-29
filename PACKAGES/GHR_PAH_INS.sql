--------------------------------------------------------
--  DDL for Package GHR_PAH_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PAH_INS" AUTHID CURRENT_USER as
/* $Header: ghpahrhi.pkh 120.0 2005/05/29 03:23:15 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
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
Procedure ins
  (
  p_rec        in out nocopy ghr_pah_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (
  p_pa_history_id                out nocopy number,
  p_pa_request_id                in number           default null,
  p_process_date                 in date,
  p_nature_of_action_id          in number           default null,
  p_effective_date               in date,
  p_altered_pa_request_id        in number           default null,
  p_person_id                    in number           default null,
  p_assignment_id                in number           default null,
  p_dml_operation                in varchar2         default null,
  p_table_name                   in varchar2,
  p_pre_values_flag              in varchar2         default null,
  p_information1                 in varchar2         default null,
  p_information2                 in varchar2         default null,
  p_information3                 in varchar2         default null,
  p_information4                 in varchar2         default null,
  p_information5                 in varchar2         default null,
  p_information6                 in varchar2         default null,
  p_information7                 in varchar2         default null,
  p_information8                 in varchar2         default null,
  p_information9                 in varchar2         default null,
  p_information10                in varchar2         default null,
  p_information11                in varchar2         default null,
  p_information12                in varchar2         default null,
  p_information13                in varchar2         default null,
  p_information14                in varchar2         default null,
  p_information15                in varchar2         default null,
  p_information16                in varchar2         default null,
  p_information17                in varchar2         default null,
  p_information18                in varchar2         default null,
  p_information19                in varchar2         default null,
  p_information20                in varchar2         default null,
  p_information21                in varchar2         default null,
  p_information22                in varchar2         default null,
  p_information23                in varchar2         default null,
  p_information24                in varchar2         default null,
  p_information25                in varchar2         default null,
  p_information26                in varchar2         default null,
  p_information27                in varchar2         default null,
  p_information28                in varchar2         default null,
  p_information29                in varchar2         default null,
  p_information30                in varchar2         default null,
  p_information31                in varchar2         default null,
  p_information32                in varchar2         default null,
  p_information33                in varchar2         default null,
  p_information34                in varchar2         default null,
  p_information35                in varchar2         default null,
  p_information36                in varchar2         default null,
  p_information37                in varchar2         default null,
  p_information38                in varchar2         default null,
  p_information39                in varchar2         default null,
  p_information47                in varchar2         default null,
  p_information48                in varchar2         default null,
  p_information49                in varchar2         default null,
  p_information40                in varchar2         default null,
  p_information41                in varchar2         default null,
  p_information42                in varchar2         default null,
  p_information43                in varchar2         default null,
  p_information44                in varchar2         default null,
  p_information45                in varchar2         default null,
  p_information46                in varchar2         default null,
  p_information50                in varchar2         default null,
  p_information51                in varchar2         default null,
  p_information52                in varchar2         default null,
  p_information53                in varchar2         default null,
  p_information54                in varchar2         default null,
  p_information55                in varchar2         default null,
  p_information56                in varchar2         default null,
  p_information57                in varchar2         default null,
  p_information58                in varchar2         default null,
  p_information59                in varchar2         default null,
  p_information60                in varchar2         default null,
  p_information61                in varchar2         default null,
  p_information62                in varchar2         default null,
  p_information63                in varchar2         default null,
  p_information64                in varchar2         default null,
  p_information65                in varchar2         default null,
  p_information66                in varchar2         default null,
  p_information67                in varchar2         default null,
  p_information68                in varchar2         default null,
  p_information69                in varchar2         default null,
  p_information70                in varchar2         default null,
  p_information71                in varchar2         default null,
  p_information72                in varchar2         default null,
  p_information73                in varchar2         default null,
  p_information74                in varchar2         default null,
  p_information75                in varchar2         default null,
  p_information76                in varchar2         default null,
  p_information77                in varchar2         default null,
  p_information78                in varchar2         default null,
  p_information79                in varchar2         default null,
  p_information80                in varchar2         default null,
  p_information81                in varchar2         default null,
  p_information82                in varchar2         default null,
  p_information83                in varchar2         default null,
  p_information84                in varchar2         default null,
  p_information85                in varchar2         default null,
  p_information86                in varchar2         default null,
  p_information87                in varchar2         default null,
  p_information88                in varchar2         default null,
  p_information89                in varchar2         default null,
  p_information90                in varchar2         default null,
  p_information91                in varchar2         default null,
  p_information92                in varchar2         default null,
  p_information93                in varchar2         default null,
  p_information94                in varchar2         default null,
  p_information95                in varchar2         default null,
  p_information96                in varchar2         default null,
  p_information97                in varchar2         default null,
  p_information98                in varchar2         default null,
  p_information99                in varchar2         default null,
  p_information100               in varchar2         default null,
  p_information101               in varchar2         default null,
  p_information102               in varchar2         default null,
  p_information103               in varchar2         default null,
  p_information104               in varchar2         default null,
  p_information105               in varchar2         default null,
  p_information106               in varchar2         default null,
  p_information107               in varchar2         default null,
  p_information108               in varchar2         default null,
  p_information109               in varchar2         default null,
  p_information110               in varchar2         default null,
  p_information111               in varchar2         default null,
  p_information112               in varchar2         default null,
  p_information113               in varchar2         default null,
  p_information114               in varchar2         default null,
  p_information115               in varchar2         default null,
  p_information116               in varchar2         default null,
  p_information117               in varchar2         default null,
  p_information118               in varchar2         default null,
  p_information119               in varchar2         default null,
  p_information120               in varchar2         default null,
  p_information121               in varchar2         default null,
  p_information122               in varchar2         default null,
  p_information123               in varchar2         default null,
  p_information124               in varchar2         default null,
  p_information125               in varchar2         default null,
  p_information126               in varchar2         default null,
  p_information127               in varchar2         default null,
  p_information128               in varchar2         default null,
  p_information129               in varchar2         default null,
  p_information130               in varchar2         default null,
  p_information131               in varchar2         default null,
  p_information132               in varchar2         default null,
  p_information133               in varchar2         default null,
  p_information134               in varchar2         default null,
  p_information135               in varchar2         default null,
  p_information136               in varchar2         default null,
  p_information137               in varchar2         default null,
  p_information138               in varchar2         default null,
  p_information139               in varchar2         default null,
  p_information140               in varchar2         default null,
  p_information141               in varchar2         default null,
  p_information142               in varchar2         default null,
  p_information143               in varchar2         default null,
  p_information144               in varchar2         default null,
  p_information145               in varchar2         default null,
  p_information146               in varchar2         default null,
  p_information147               in varchar2         default null,
  p_information148               in varchar2         default null,
  p_information149               in varchar2         default null,
  p_information150               in varchar2         default null,
  p_information151               in varchar2         default null,
  p_information152               in varchar2         default null,
  p_information153               in varchar2         default null,
  p_information154               in varchar2         default null,
  p_information155               in varchar2         default null,
  p_information156               in varchar2         default null,
  p_information157               in varchar2         default null,
  p_information158               in varchar2         default null,
  p_information159               in varchar2         default null,
  p_information160               in varchar2         default null,
  p_information161               in varchar2         default null,
  p_information162               in varchar2         default null,
  p_information163               in varchar2         default null,
  p_information164               in varchar2         default null,
  p_information165               in varchar2         default null,
  p_information166               in varchar2         default null,
  p_information167               in varchar2         default null,
  p_information168               in varchar2         default null,
  p_information169               in varchar2         default null,
  p_information170               in varchar2         default null,
  p_information171               in varchar2         default null,
  p_information172               in varchar2         default null,
  p_information173               in varchar2         default null,
  p_information174               in varchar2         default null,
  p_information175               in varchar2         default null,
  p_information176               in varchar2         default null,
  p_information177               in varchar2         default null,
  p_information178               in varchar2         default null,
  p_information179               in varchar2         default null,
  p_information180               in varchar2         default null,
  p_information181               in varchar2         default null,
  p_information182               in varchar2         default null,
  p_information183               in varchar2         default null,
  p_information184               in varchar2         default null,
  p_information185               in varchar2         default null,
  p_information186               in varchar2         default null,
  p_information187               in varchar2         default null,
  p_information188               in varchar2         default null,
  p_information189               in varchar2         default null,
  p_information190               in varchar2         default null,
  p_information191               in varchar2         default null,
  p_information192               in varchar2         default null,
  p_information193               in varchar2         default null,
  p_information194               in varchar2         default null,
  p_information195               in varchar2         default null,
  p_information196               in varchar2         default null,
  p_information197               in varchar2         default null,
  p_information198               in varchar2         default null,
  p_information199               in varchar2         default null,
  p_information200               in varchar2         default null
  );
--
end ghr_pah_ins;

 

/
