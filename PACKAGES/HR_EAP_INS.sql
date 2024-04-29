--------------------------------------------------------
--  DDL for Package HR_EAP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EAP_INS" AUTHID CURRENT_USER as
/* $Header: hreaprhi.pkh 120.0 2005/05/30 23:58 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< register >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to register the external application in SSO
--   schema
--
-- Prerequisites:
--
-- In Parameters:
--   p_app_code       IN   external app code
--   p_apptype        IN   application type
--   p_appurl         IN   URL for external application
--   p_logout_url     IN   URL for external application to logout
--   p_userfld        IN   name of user field
--   p_pwdfld         IN   name of password field
--   p_authused       IN   type of authentication used
--   p_fnameN         IN   additional names  (N=1..9)
--   p_fvalN          IN   additional values (N=1..9)
--
-- Post Success:
-- External application is registered in SSO schema.
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
procedure register
 (      p_app_code       IN VARCHAR2,
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
        p_fval9          IN VARCHAR2 DEFAULT NULL,
        p_ki_app_id      out nocopy number
        );

--

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
  (p_ext_application_id  in  number);
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
Procedure ins
  (p_rec                      in out nocopy hr_eap_shd.g_rec_type
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
Procedure ins
  (p_external_application_name      in     varchar2
  ,p_external_application_id        in     varchar2
  ,p_ext_application_id                out nocopy number
  );
--
end hr_eap_ins;

 

/
