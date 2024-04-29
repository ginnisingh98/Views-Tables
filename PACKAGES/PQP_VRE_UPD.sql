--------------------------------------------------------
--  DDL for Package PQP_VRE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VRE_UPD" AUTHID CURRENT_USER as
/* $Header: pqvrerhi.pkh 120.0.12010000.1 2008/07/28 11:26:09 appldev ship $ */
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
PROCEDURE upd
  (p_effective_date IN     DATE
  ,p_datetrack_mode IN     VARCHAR2
  ,p_rec            IN OUT NOCOPY pqp_vre_shd.g_rec_type
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
PROCEDURE upd
  (p_effective_date               IN     DATE
  ,p_datetrack_mode               IN     VARCHAR2
  ,p_vehicle_repository_id        IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_registration_number          IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vehicle_type                 IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vehicle_id_number            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_business_group_id            IN     NUMBER    DEFAULT hr_api.g_number
  ,p_make                         IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_engine_capacity_in_cc        IN     NUMBER    DEFAULT hr_api.g_number
  ,p_fuel_type                    IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_currency_code                IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vehicle_status               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vehicle_inactivity_reason    IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_model                        IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_initial_registration         IN     DATE      DEFAULT hr_api.g_date
  ,p_last_registration_renew_date IN     DATE      DEFAULT hr_api.g_date
  ,p_list_price                   IN     NUMBER    DEFAULT hr_api.g_number
  ,p_accessory_value_at_startdate IN     NUMBER    DEFAULT hr_api.g_number
  ,p_accessory_value_added_later  IN     NUMBER    DEFAULT hr_api.g_number
  ,p_market_value_classic_car     IN     NUMBER    DEFAULT hr_api.g_number
  ,p_fiscal_ratings               IN     NUMBER    DEFAULT hr_api.g_number
  ,p_fiscal_ratings_uom           IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vehicle_provider             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vehicle_ownership            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_shared_vehicle               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_asset_number                 IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_lease_contract_number        IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_lease_contract_expiry_date   IN     DATE      DEFAULT hr_api.g_date
  ,p_taxation_method              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_fleet_info                   IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_fleet_transfer_date          IN     DATE      DEFAULT hr_api.g_date
  ,p_color                        IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_seating_capacity             IN     NUMBER    DEFAULT hr_api.g_number
  ,p_weight                       IN     NUMBER    DEFAULT hr_api.g_number
  ,p_weight_uom                   IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_model_year                   IN     NUMBER    DEFAULT hr_api.g_number
  ,p_insurance_number             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_insurance_expiry_date        IN     DATE      DEFAULT hr_api.g_date
  ,p_comments                     IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute_category       IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute1               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute2               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute3               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute4               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute5               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute6               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute7               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute8               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute9               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute10              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute11              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute12              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute13              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute14              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute15              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute16              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute17              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute18              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute19              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_attribute20              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information_category     IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information1             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information2             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information3             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information4             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information5             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information6             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information7             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information8             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information9             IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information10            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information11            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information12            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information13            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information14            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information15            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information16            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information17            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information18            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information19            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_vre_information20            IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  );
--
end pqp_vre_upd;

/
