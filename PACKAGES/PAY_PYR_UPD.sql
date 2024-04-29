--------------------------------------------------------
--  DDL for Package PAY_PYR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYR_UPD" AUTHID CURRENT_USER AS
/* $Header: pypyrrhi.pkh 120.0 2005/05/29 08:11:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< upd >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This PROCEDURE is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version NUMBER attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   PROCEDURE is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be DEFAULTed, we need to build up the updated row by
--      converting any system DEFAULTed parameters to their corresponding
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
--   The main parameters to the business process have to be IN the record
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
  (p_effective_date               IN DATE
  ,p_rec                          IN OUT NOCOPY pay_pyr_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This PROCEDURE is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version NUMBER attributes). The processing of this
--   PROCEDURE is as follows:
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
  (p_effective_date               IN     DATE
  ,p_rate_id                      IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_name                         IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_rate_uom                     IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_parent_spine_id              IN     NUMBER    DEFAULT hr_api.g_NUMBER
  ,p_comments                     IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute_category           IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute1                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute2                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute3                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute4                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute5                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute6                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute7                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute8                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute9                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute10                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute11                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute12                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute13                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute14                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute15                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute16                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute17                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute18                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute19                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute20                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_rate_basis                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_asg_rate_type                IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  );
--
END pay_pyr_upd;

 

/
