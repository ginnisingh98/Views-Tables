--------------------------------------------------------
--  DDL for Package HR_LOC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOC_UPD" AUTHID CURRENT_USER AS
/* $Header: hrlocrhi.pkh 120.1 2005/07/18 06:20:20 bshukla noship $ */
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
PROCEDURE upd
  (
   p_rec                IN     OUT NOCOPY hr_loc_shd.g_rec_type,
   p_effective_date     IN     DATE,
   p_operating_unit_id  IN     NUMBER
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
PROCEDURE upd
  (
  p_effective_date               IN DATE,
  p_location_id                  IN NUMBER,
  p_object_version_number        IN OUT NOCOPY NUMBER,
  p_location_code                IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_timezone_code                IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_address_line_1               IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_address_line_2               IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_address_line_3               IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_bill_to_site_flag            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_country                      IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_description                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_designated_receiver_id       IN NUMBER           DEFAULT hr_api.g_number,
  p_in_organization_flag         IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_inactive_date                IN DATE             DEFAULT hr_api.g_date,
  p_operating_unit_id            IN NUMBER           DEFAULT NULL,
  p_inventory_organization_id    IN NUMBER           DEFAULT hr_api.g_number,
  p_office_site_flag             IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_postal_code                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_receiving_site_flag          IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_region_1                     IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_region_2                     IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_region_3                     IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_ship_to_location_id          IN NUMBER           DEFAULT hr_api.g_number,
  p_ship_to_site_flag            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_style                        IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_tax_name                     IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_telephone_number_1           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_telephone_number_2           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_telephone_number_3           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_town_or_city                 IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information13            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information14            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information15            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information16            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information17            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information18            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information19            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information20            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute_category           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute1                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute2                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute3                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute4                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute5                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute6                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute7                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute8                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute9                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute10                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute11                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute12                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute13                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute14                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute15                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute16                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute17                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute18                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute19                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute20                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute_category    IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute1            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute2            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute3            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute4            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute5            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute6            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute7            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute8            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute9            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute10           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute11           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute12           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute13           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute14           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute15           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute16           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute17           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute18           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute19           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute20           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
   p_legal_address_flag           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_tp_header_id                 IN NUMBER           DEFAULT hr_api.g_number,
  p_ece_tp_location_code         IN VARCHAR2         DEFAULT hr_api.g_varchar2
 );
--
END hr_loc_upd;

 

/
