--------------------------------------------------------
--  DDL for Package PER_PEM_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEM_INS" AUTHID CURRENT_USER as
/* $Header: pepemrhi.pkh 120.0.12010000.3 2008/08/06 09:22:15 ubhat ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
--
-- Prerequisites:
--
-- In Parameters:
--   Primary Key
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_previous_employer_id  in  number);
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
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_pem_shd.g_rec_type
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
Procedure ins
  (p_effective_date                 in     date
  ,p_business_group_id              in     number   default null
  ,p_person_id                      in     number   default null
  ,p_party_id                       in     number   default null
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_period_years                   in     number   default null
  ,p_period_days                    in     number   default null
  ,p_employer_name                  in     varchar2 default null
  ,p_employer_country               in     varchar2 default null
  ,p_employer_address               in     varchar2 default null
  ,p_employer_type                  in     varchar2 default null
  ,p_employer_subtype               in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_pem_attribute_category         in     varchar2 default null
  ,p_pem_attribute1                 in     varchar2 default null
  ,p_pem_attribute2                 in     varchar2 default null
  ,p_pem_attribute3                 in     varchar2 default null
  ,p_pem_attribute4                 in     varchar2 default null
  ,p_pem_attribute5                 in     varchar2 default null
  ,p_pem_attribute6                 in     varchar2 default null
  ,p_pem_attribute7                 in     varchar2 default null
  ,p_pem_attribute8                 in     varchar2 default null
  ,p_pem_attribute9                 in     varchar2 default null
  ,p_pem_attribute10                in     varchar2 default null
  ,p_pem_attribute11                in     varchar2 default null
  ,p_pem_attribute12                in     varchar2 default null
  ,p_pem_attribute13                in     varchar2 default null
  ,p_pem_attribute14                in     varchar2 default null
  ,p_pem_attribute15                in     varchar2 default null
  ,p_pem_attribute16                in     varchar2 default null
  ,p_pem_attribute17                in     varchar2 default null
  ,p_pem_attribute18                in     varchar2 default null
  ,p_pem_attribute19                in     varchar2 default null
  ,p_pem_attribute20                in     varchar2 default null
  ,p_pem_attribute21                in     varchar2 default null
  ,p_pem_attribute22                in     varchar2 default null
  ,p_pem_attribute23                in     varchar2 default null
  ,p_pem_attribute24                in     varchar2 default null
  ,p_pem_attribute25                in     varchar2 default null
  ,p_pem_attribute26                in     varchar2 default null
  ,p_pem_attribute27                in     varchar2 default null
  ,p_pem_attribute28                in     varchar2 default null
  ,p_pem_attribute29                in     varchar2 default null
  ,p_pem_attribute30                in     varchar2 default null
  ,p_pem_information_category       in     varchar2 default null
  ,p_pem_information1               in     varchar2 default null
  ,p_pem_information2               in     varchar2 default null
  ,p_pem_information3               in     varchar2 default null
  ,p_pem_information4               in     varchar2 default null
  ,p_pem_information5               in     varchar2 default null
  ,p_pem_information6               in     varchar2 default null
  ,p_pem_information7               in     varchar2 default null
  ,p_pem_information8               in     varchar2 default null
  ,p_pem_information9               in     varchar2 default null
  ,p_pem_information10              in     varchar2 default null
  ,p_pem_information11              in     varchar2 default null
  ,p_pem_information12              in     varchar2 default null
  ,p_pem_information13              in     varchar2 default null
  ,p_pem_information14              in     varchar2 default null
  ,p_pem_information15              in     varchar2 default null
  ,p_pem_information16              in     varchar2 default null
  ,p_pem_information17              in     varchar2 default null
  ,p_pem_information18              in     varchar2 default null
  ,p_pem_information19              in     varchar2 default null
  ,p_pem_information20              in     varchar2 default null
  ,p_pem_information21              in     varchar2 default null
  ,p_pem_information22              in     varchar2 default null
  ,p_pem_information23              in     varchar2 default null
  ,p_pem_information24              in     varchar2 default null
  ,p_pem_information25              in     varchar2 default null
  ,p_pem_information26              in     varchar2 default null
  ,p_pem_information27              in     varchar2 default null
  ,p_pem_information28              in     varchar2 default null
  ,p_pem_information29              in     varchar2 default null
  ,p_pem_information30              in     varchar2 default null
  ,p_all_assignments                in     varchar2 default null
  ,p_period_months                  in     number   default null
  ,p_previous_employer_id              out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end per_pem_ins;

/
