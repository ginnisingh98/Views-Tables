--------------------------------------------------------
--  DDL for Package PAY_PRF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PRF_UPD" AUTHID CURRENT_USER as
/* $Header: pyprfrhi.pkh 120.0 2005/05/29 07:49 appldev noship $ */
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
  (p_rec                          in out nocopy pay_prf_shd.g_rec_type
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
  (p_range_table_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_range_table_number           in     number    default hr_api.g_number
  ,p_period_frequency             in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         in     date      default hr_api.g_date
  ,p_effective_end_date           in     date      default hr_api.g_date
  ,p_row_value_uom                in     varchar2  default hr_api.g_varchar2
  ,p_earnings_type                in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_last_updated_login           in     number    default hr_api.g_number
  ,p_created_date                 in     date      default hr_api.g_date
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_ran_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_ran_information1             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information2             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information3             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information4             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information5             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information6             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information7             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information8             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information9             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information10            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information11            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information12            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information13            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information14            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information15            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information16            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information17            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information18            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information19            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information20            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information21            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information22            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information23            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information24            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information25            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information26            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information27            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information28            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information29            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information30            in     varchar2  default hr_api.g_varchar2
  );
--
end pay_prf_upd;

 

/
