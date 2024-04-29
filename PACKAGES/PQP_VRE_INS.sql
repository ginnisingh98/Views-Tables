--------------------------------------------------------
--  DDL for Package PQP_VRE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VRE_INS" AUTHID CURRENT_USER as
/* $Header: pqvrerhi.pkh 120.0.12010000.1 2008/07/28 11:26:09 appldev ship $ */
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
  (p_vehicle_repository_id  in  number);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_insert_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within the dt_insert_dml
--   procedure).
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE insert_dml
  (p_rec                   in out nocopy pqp_vre_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
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
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) We must lock parent rows (if any exist).
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
PROCEDURE ins
  (p_effective_date in     date
  ,p_rec            in out nocopy pqp_vre_shd.g_rec_type
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
--   (e.g. object version number attributes). The processing of this
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
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
PROCEDURE ins
  (p_effective_date                 IN     DATE
  ,p_registration_number            IN     VARCHAR2 DEFAULT null
  ,p_vehicle_type                   IN     VARCHAR2
  ,p_vehicle_id_number              IN     VARCHAR2 DEFAULT null
  ,p_business_group_id              IN     NUMBER
  ,p_make                           IN     VARCHAR2
  ,p_engine_capacity_in_cc          IN     NUMBER   DEFAULT null
  ,p_fuel_type                      IN     VARCHAR2 DEFAULT null
  ,p_currency_code                  IN     VARCHAR2
  ,p_vehicle_status                 IN     VARCHAR2
  ,p_vehicle_inactivity_reason      IN     VARCHAR2 DEFAULT null
  ,p_model                          IN     VARCHAR2 DEFAULT null
  ,p_initial_registration           IN     DATE     DEFAULT null
  ,p_last_registration_renew_date   IN     DATE     DEFAULT null
  ,p_list_price                     IN     NUMBER   DEFAULT null
  ,p_accessory_value_at_startdate   IN     NUMBER   DEFAULT null
  ,p_accessory_value_added_later    IN     NUMBER   DEFAULT null
  ,p_market_value_classic_car       IN     NUMBER   DEFAULT null
  ,p_fiscal_ratings                 IN     NUMBER   DEFAULT null
  ,p_fiscal_ratings_uom             IN     VARCHAR2 DEFAULT null
  ,p_vehicle_provider               IN     VARCHAR2 DEFAULT null
  ,p_vehicle_ownership              IN     VARCHAR2 DEFAULT null
  ,p_shared_vehicle                 IN     VARCHAR2 DEFAULT null
  ,p_asset_number                   IN     VARCHAR2 DEFAULT null
  ,p_lease_contract_number          IN     VARCHAR2 DEFAULT null
  ,p_lease_contract_expiry_date     IN     DATE     DEFAULT null
  ,p_taxation_method                IN     VARCHAR2 DEFAULT null
  ,p_fleet_info                     IN     VARCHAR2 DEFAULT null
  ,p_fleet_transfer_date            IN     DATE     DEFAULT null
  ,p_color                          IN     VARCHAR2 DEFAULT null
  ,p_seating_capacity               IN     NUMBER   DEFAULT null
  ,p_weight                         IN     NUMBER   DEFAULT null
  ,p_weight_uom                     IN     VARCHAR2 DEFAULT null
  ,p_model_year                     IN     NUMBER   DEFAULT null
  ,p_insurance_number               IN     VARCHAR2 DEFAULT null
  ,p_insurance_expiry_date          IN     DATE     DEFAULT null
  ,p_comments                       IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute_category         IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute1                 IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute2                 IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute3                 IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute4                 IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute5                 IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute6                 IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute7                 IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute8                 IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute9                 IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute10                IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute11                IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute12                IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute13                IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute14                IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute15                IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute16                IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute17                IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute18                IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute19                IN     VARCHAR2 DEFAULT null
  ,p_vre_attribute20                IN     VARCHAR2 DEFAULT null
  ,p_vre_information_category       IN     VARCHAR2 DEFAULT null
  ,p_vre_information1               IN     VARCHAR2 DEFAULT null
  ,p_vre_information2               IN     VARCHAR2 DEFAULT null
  ,p_vre_information3               IN     VARCHAR2 DEFAULT null
  ,p_vre_information4               IN     VARCHAR2 DEFAULT null
  ,p_vre_information5               IN     VARCHAR2 DEFAULT null
  ,p_vre_information6               IN     VARCHAR2 DEFAULT null
  ,p_vre_information7               IN     VARCHAR2 DEFAULT null
  ,p_vre_information8               IN     VARCHAR2 DEFAULT null
  ,p_vre_information9               IN     VARCHAR2 DEFAULT null
  ,p_vre_information10              IN     VARCHAR2 DEFAULT null
  ,p_vre_information11              IN     VARCHAR2 DEFAULT null
  ,p_vre_information12              IN     VARCHAR2 DEFAULT null
  ,p_vre_information13              IN     VARCHAR2 DEFAULT null
  ,p_vre_information14              IN     VARCHAR2 DEFAULT null
  ,p_vre_information15              IN     VARCHAR2 DEFAULT null
  ,p_vre_information16              IN     VARCHAR2 DEFAULT null
  ,p_vre_information17              IN     VARCHAR2 DEFAULT null
  ,p_vre_information18              IN     VARCHAR2 DEFAULT null
  ,p_vre_information19              IN     VARCHAR2 DEFAULT null
  ,p_vre_information20              IN     VARCHAR2 DEFAULT null
  ,p_vehicle_repository_id          OUT NOCOPY NUMBER
  ,p_object_version_number          OUT NOCOPY NUMBER
  ,p_effective_start_date           OUT NOCOPY DATE
  ,p_effective_end_date             OUT NOCOPY DATE
  );
--
end pqp_vre_ins;

/
