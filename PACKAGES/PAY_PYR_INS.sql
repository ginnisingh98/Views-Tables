--------------------------------------------------------
--  DDL for Package PAY_PYR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYR_INS" AUTHID CURRENT_USER AS
/* $Header: pypyrrhi.pkh 120.0 2005/05/29 08:11:24 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This PROCEDURE is called to register the next ID value from the database
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
PROCEDURE set_base_key_value
  (p_rate_id  IN  NUMBER);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This PROCEDURE is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version NUMBER
--   attributes). This process is the main backbone of the ins
--   process. The processing of this PROCEDURE is as follows:
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
--   The main parameters to the this process have to be IN the record
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
PROCEDURE ins
  (p_effective_date               IN DATE
  ,p_rec                          IN OUT NOCOPY pay_pyr_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This PROCEDURE is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version NUMBER attributes).The processing of this
--   PROCEDURE is as follows:
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
PROCEDURE ins
  (p_effective_date                 IN            DATE
  ,p_business_group_id              IN            NUMBER
  ,p_name                           IN            VARCHAR2
  ,p_rate_type                      IN            VARCHAR2
  ,p_rate_uom                       IN            VARCHAR2
  ,p_parent_spine_id                IN            NUMBER   DEFAULT null
  ,p_comments                       IN            VARCHAR2 DEFAULT null
  ,p_request_id                     IN            NUMBER   DEFAULT null
  ,p_program_application_id         IN            NUMBER   DEFAULT null
  ,p_program_id                     IN            NUMBER   DEFAULT null
  ,p_program_update_date            IN            DATE     DEFAULT null
  ,p_attribute_category             IN            VARCHAR2 DEFAULT null
  ,p_attribute1                     IN            VARCHAR2 DEFAULT null
  ,p_attribute2                     IN            VARCHAR2 DEFAULT null
  ,p_attribute3                     IN            VARCHAR2 DEFAULT null
  ,p_attribute4                     IN            VARCHAR2 DEFAULT null
  ,p_attribute5                     IN            VARCHAR2 DEFAULT null
  ,p_attribute6                     IN            VARCHAR2 DEFAULT null
  ,p_attribute7                     IN            VARCHAR2 DEFAULT null
  ,p_attribute8                     IN            VARCHAR2 DEFAULT null
  ,p_attribute9                     IN            VARCHAR2 DEFAULT null
  ,p_attribute10                    IN            VARCHAR2 DEFAULT null
  ,p_attribute11                    IN            VARCHAR2 DEFAULT null
  ,p_attribute12                    IN            VARCHAR2 DEFAULT null
  ,p_attribute13                    IN            VARCHAR2 DEFAULT null
  ,p_attribute14                    IN            VARCHAR2 DEFAULT null
  ,p_attribute15                    IN            VARCHAR2 DEFAULT null
  ,p_attribute16                    IN            VARCHAR2 DEFAULT null
  ,p_attribute17                    IN            VARCHAR2 DEFAULT null
  ,p_attribute18                    IN            VARCHAR2 DEFAULT null
  ,p_attribute19                    IN            VARCHAR2 DEFAULT null
  ,p_attribute20                    IN            VARCHAR2 DEFAULT null
  ,p_rate_basis                     IN            VARCHAR2 DEFAULT null
  ,p_asg_rate_type                  IN            VARCHAR2 DEFAULT NULL
  ,p_rate_id                           OUT NOCOPY NUMBER
  ,p_object_version_NUMBER             OUT NOCOPY NUMBER
  );
--
END pay_pyr_ins;

 

/
