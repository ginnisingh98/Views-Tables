--------------------------------------------------------
--  DDL for Package OTA_TPS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPS_UPD" AUTHID CURRENT_USER AS
/* $Header: ottpsrhi.pkh 120.0 2005/05/29 07:50:07 appldev noship $ */
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
PROCEDURE upd
  (p_effective_date               IN date
  ,p_rec                          IN OUT NOCOPY ota_tps_shd.g_rec_type
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
PROCEDURE upd
  (p_effective_date               IN     date
  ,p_training_plan_id             IN     number
  ,p_object_version_number        IN OUT NOCOPY number
  ,p_time_period_id               IN     number    DEFAULT hr_api.g_number
  ,p_plan_status_type_id          IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_budget_currency              IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_name                         IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_description                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute_category           IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute1                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute2                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute3                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute4                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute5                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute6                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute7                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute8                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute9                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute10                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute11                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute12                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute13                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute14                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute15                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute16                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute17                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute18                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute19                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute20                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute21                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute22                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute23                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute24                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute25                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute26                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute27                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute28                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute29                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute30                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_plan_source                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_start_date                   IN     date      DEFAULT hr_api.g_date
  ,p_end_date                     IN     date      DEFAULT hr_api.g_date
  ,p_creator_person_id             IN    number    DEFAULT hr_api.g_number
  ,p_additional_member_flag       IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_learning_path_id             IN    number    DEFAULT hr_api.g_number
    ,p_contact_id             IN    number    DEFAULT hr_api.g_number
  );
--
END ota_tps_upd;

 

/
