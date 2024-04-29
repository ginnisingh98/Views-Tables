--------------------------------------------------------
--  DDL for Package PQP_PVD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PVD_UPD" AUTHID CURRENT_USER as
/* $Header: pqpvdrhi.pkh 120.0 2005/05/29 02:09:36 appldev noship $ */
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
  ,p_rec                          in out nocopy pqp_pvd_shd.g_rec_type
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
  ,p_vehicle_details_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_vehicle_type                 in     varchar2  default hr_api.g_varchar2
  ,p_registration_number          in     varchar2  default hr_api.g_varchar2
  ,p_make                         in     varchar2  default hr_api.g_varchar2
  ,p_model                        in     varchar2  default hr_api.g_varchar2
  ,p_date_first_registered        in     date      default hr_api.g_date
  ,p_engine_capacity_in_cc        in     number    default hr_api.g_number
  ,p_fuel_type                    in     varchar2  default hr_api.g_varchar2
  ,p_fuel_card                    in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_list_price                   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_accessory_value_at_startdate in     number    default hr_api.g_number
  ,p_accessory_value_added_later  in     number    default hr_api.g_number
--  ,p_capital_contributions        in     number    default hr_api.g_number
--  ,p_private_use_contributions    in     number    default hr_api.g_number
  ,p_market_value_classic_car     in     number    default hr_api.g_number
  ,p_co2_emissions                in     number    default hr_api.g_number
  ,p_vehicle_provider             in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_identification_numbe in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_ownership            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information1             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information2             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information3             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information4             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information5             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information6             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information7             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information8             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information9             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information10            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information11            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information12            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information13            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information14            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information15            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information16            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information17            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information18            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information19            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information20            in     varchar2  default hr_api.g_varchar2
  );
--
end pqp_pvd_upd;

 

/
