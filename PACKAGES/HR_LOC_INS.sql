--------------------------------------------------------
--  DDL for Package HR_LOC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOC_INS" AUTHID CURRENT_USER AS
/* $Header: hrlocrhi.pkh 120.1 2005/07/18 06:20:20 bshukla noship $ */
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
  (p_location_id  in  number);
--
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
PROCEDURE ins
  (
   p_rec               IN OUT NOCOPY hr_loc_shd.g_rec_type
  ,p_effective_date    IN DATE
  ,p_operating_unit_id IN NUMBER
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
PROCEDURE ins
  (
   p_effective_date               IN DATE,
   p_location_id                  OUT NOCOPY NUMBER,
   p_object_version_number        OUT NOCOPY NUMBER,
   p_location_code                IN VARCHAR2,
   p_timezone_code                IN VARCHAR2         DEFAULT NULL,
   p_address_line_1               IN VARCHAR2         DEFAULT NULL,
   p_address_line_2               IN VARCHAR2         DEFAULT NULL,
   p_address_line_3               IN VARCHAR2         DEFAULT NULL,
   p_bill_to_site_flag            IN VARCHAR2         DEFAULT 'Y',
   p_country                      IN VARCHAR2         DEFAULT NULL,
   p_description                  IN VARCHAR2         DEFAULT NULL,
   p_designated_receiver_id       IN NUMBER           DEFAULT NULL,
   p_in_organization_flag         IN VARCHAR2         DEFAULT 'Y',
   p_inactive_date                IN DATE             DEFAULT NULL,
   p_operating_unit_id            IN NUMBER           DEFAULT NULL,
   p_inventory_organization_id    IN NUMBER           DEFAULT NULL,
   p_office_site_flag             IN VARCHAR2         DEFAULT 'Y',
   p_postal_code                  IN VARCHAR2         DEFAULT NULL,
   p_receiving_site_flag          IN VARCHAR2         DEFAULT 'Y',
   p_region_1                     IN VARCHAR2         DEFAULT NULL,
   p_region_2                     IN VARCHAR2         DEFAULT NULL,
   p_region_3                     IN VARCHAR2         DEFAULT NULL,
   p_ship_to_location_id          IN NUMBER           DEFAULT NULL,
   p_ship_to_site_flag            IN VARCHAR2         DEFAULT 'Y',
   p_style                        IN VARCHAR2         DEFAULT NULL,
   p_tax_name                     IN VARCHAR2         DEFAULT NULL,
   p_telephone_number_1           IN VARCHAR2         DEFAULT NULL,
   p_telephone_number_2           IN VARCHAR2         DEFAULT NULL,
   p_telephone_number_3           IN VARCHAR2         DEFAULT NULL,
   p_town_or_city                 IN VARCHAR2         DEFAULT NULL,
   p_loc_information13            IN VARCHAR2         DEFAULT NULL,
   p_loc_information14            IN VARCHAR2         DEFAULT NULL,
   p_loc_information15            IN VARCHAR2         DEFAULT NULL,
   p_loc_information16            IN VARCHAR2         DEFAULT NULL,
   p_loc_information17            IN VARCHAR2         DEFAULT NULL,
   p_loc_information18            IN VARCHAR2         DEFAULT NULL,
   p_loc_information19            IN VARCHAR2         DEFAULT NULL,
   p_loc_information20            IN VARCHAR2         DEFAULT NULL,
   p_attribute_category           IN VARCHAR2         DEFAULT NULL,
   p_attribute1                   IN VARCHAR2         DEFAULT NULL,
   p_attribute2                   IN VARCHAR2         DEFAULT NULL,
   p_attribute3                   IN VARCHAR2         DEFAULT NULL,
   p_attribute4                   IN VARCHAR2         DEFAULT NULL,
   p_attribute5                   IN VARCHAR2         DEFAULT NULL,
   p_attribute6                   IN VARCHAR2         DEFAULT NULL,
   p_attribute7                   IN VARCHAR2         DEFAULT NULL,
   p_attribute8                   IN VARCHAR2         DEFAULT NULL,
   p_attribute9                   IN VARCHAR2         DEFAULT NULL,
   p_attribute10                  IN VARCHAR2         DEFAULT NULL,
   p_attribute11                  IN VARCHAR2         DEFAULT NULL,
   p_attribute12                  IN VARCHAR2         DEFAULT NULL,
   p_attribute13                  IN VARCHAR2         DEFAULT NULL,
   p_attribute14                  IN VARCHAR2         DEFAULT NULL,
   p_attribute15                  IN VARCHAR2         DEFAULT NULL,
   p_attribute16                  IN VARCHAR2         DEFAULT NULL,
   p_attribute17                  IN VARCHAR2         DEFAULT NULL,
   p_attribute18                  IN VARCHAR2         DEFAULT NULL,
   p_attribute19                  IN VARCHAR2         DEFAULT NULL,
   p_attribute20                  IN VARCHAR2         DEFAULT NULL,
   p_global_attribute_category    IN VARCHAR2         DEFAULT NULL,
   p_global_attribute1            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute2            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute3            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute4            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute5            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute6            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute7            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute8            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute9            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute10           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute11           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute12           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute13           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute14           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute15           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute16           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute17           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute18           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute19           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute20           IN VARCHAR2         DEFAULT NULL,
   p_legal_address_flag            IN VARCHAR2          DEFAULT 'N',
   p_tp_header_id                 IN NUMBER           DEFAULT NULL,
   p_ece_tp_location_code         IN VARCHAR2         DEFAULT NULL,
   p_business_group_id            IN NUMBER           DEFAULT NULL
  );
--
END hr_loc_ins;

 

/
