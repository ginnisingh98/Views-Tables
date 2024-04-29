--------------------------------------------------------
--  DDL for Package PAY_OPM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_OPM_UPD" AUTHID CURRENT_USER as
/* $Header: pyopmrhi.pkh 120.1 2005/08/30 07:52:36 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to perform the datetrack update mode, fully validating the row
--   for the HR schema passing back to the calling process, any system
--   generated values (e.g. object version number attribute). This process
--   is the main backbone of the upd process. The processing of
--   this procedure is as follows:
--   1) Ensure that the datetrack update mode is valid.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--
-- Post Success:
--   The specified row will be fully validated and datetracked updated for
--   the specified entity without being committed for the datetrack mode.
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
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in            date
  ,p_datetrack_mode in            varchar2
  ,p_rec            in out nocopy pay_opm_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< upd >------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the datetrack update
--   process for the specified entity and is the outermost layer.
--   The role of this process is to update a fully validated row into the
--   HR schema passing back to the calling process, any system generated
--   values (e.g. object version number attributes). The processing of this
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
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
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
  ,p_datetrack_mode               in     varchar2
  ,p_org_payment_method_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_external_account_id          in     number    default hr_api.g_number
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
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
  ,p_pmeth_information_category   in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information1           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information2           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information3           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information4           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information5           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information6           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information7           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information8           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information9           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information10          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information11          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information12          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information13          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information14          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information15          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information16          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information17          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information18          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information19          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information20          in     varchar2  default hr_api.g_varchar2
  ,p_transfer_to_gl_flag          in     varchar2  default hr_api.g_varchar2
  ,p_cost_payment                 in     varchar2  default hr_api.g_varchar2
  ,p_cost_cleared_payment         in     varchar2  default hr_api.g_varchar2
  ,p_cost_cleared_void_payment    in     varchar2  default hr_api.g_varchar2
  ,p_exclude_manual_payment       in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_comment_id                      out nocopy number
  );
--
end pay_opm_upd;

 

/
