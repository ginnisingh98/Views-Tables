--------------------------------------------------------
--  DDL for Package HR_EAP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EAP_UPD" AUTHID CURRENT_USER as
/* $Header: hreaprhi.pkh 120.0 2005/05/30 23:58 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< update_sso_details >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to update the external application details in SSO
--   schema
--
-- Prerequisites:
--
-- In Parameters:
--   p_ext_application_id    IN   ext_application_id stored in
--                                hr_ki_ext_applications
--   p_app_code              IN   external app code
--   p_apptype               IN   application type
--   p_appurl                IN   URL for external application
--   p_logout_url            IN   URL for external application to logout
--   p_userfld               IN   name of user field
--   p_pwdfld                IN   name of password field
--   p_authused              IN   type of authentication used
--   p_fnameN                IN   additional names  (N=1..9)
--   p_fvalN                 IN   additional values (N=1..9)
--
-- Post Success:
-- External application is updated in SSO schema.
--
-- Post Failure:
--   An application error is raised if in case of failure
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure update_sso_details
 (
        p_ext_application_id   IN number,
        p_app_code       IN VARCHAR2,
        p_apptype        IN VARCHAR2,
        p_appurl         IN VARCHAR2,
        p_logout_url     IN VARCHAR2,
        p_userfld        IN VARCHAR2,
        p_pwdfld         IN VARCHAR2,
        p_authused       IN VARCHAR2,
        p_fname1         IN VARCHAR2 DEFAULT NULL,
        p_fval1          IN VARCHAR2 DEFAULT NULL,
        p_fname2         IN VARCHAR2 DEFAULT NULL,
        p_fval2          IN VARCHAR2 DEFAULT NULL,
        p_fname3         IN VARCHAR2 DEFAULT NULL,
        p_fval3          IN VARCHAR2 DEFAULT NULL,
        p_fname4         IN VARCHAR2 DEFAULT NULL,
        p_fval4          IN VARCHAR2 DEFAULT NULL,
        p_fname5         IN VARCHAR2 DEFAULT NULL,
        p_fval5          IN VARCHAR2 DEFAULT NULL,
        p_fname6         IN VARCHAR2 DEFAULT NULL,
        p_fval6          IN VARCHAR2 DEFAULT NULL,
        p_fname7         IN VARCHAR2 DEFAULT NULL,
        p_fval7          IN VARCHAR2 DEFAULT NULL,
        p_fname8         IN VARCHAR2 DEFAULT NULL,
        p_fval8          IN VARCHAR2 DEFAULT NULL,
        p_fname9         IN VARCHAR2 DEFAULT NULL,
        p_fval9          IN VARCHAR2 DEFAULT NULL);


/* $Header: hreaprhi.pkh 120.0 2005/05/30 23:58 appldev noship $ */
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
  (p_rec                          in out nocopy hr_eap_shd.g_rec_type
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
  (p_ext_application_id           in     number
  ,p_external_application_name    in     varchar2  default hr_api.g_varchar2

  );
--
end hr_eap_upd;

 

/
