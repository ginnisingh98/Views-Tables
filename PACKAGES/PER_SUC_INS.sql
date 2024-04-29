--------------------------------------------------------
--  DDL for Package PER_SUC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUC_INS" AUTHID CURRENT_USER AS
/* $Header: pesucrhi.pkh 120.1.12010000.3 2010/02/13 19:33:43 schowdhu ship $ */

   --
-- ----------------------------------------------------------------------------
-- |------------------------------< set_base_key_value >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure copies the succesion plan id (primary key) into
--   g_succession_plan_id - a global value
-- Prerequisites:
--   This is an internal private procedure which must be called from the swi
--   to set the primary key
--
-- In Parameters:
--   Succession_plan_id - primary key
--

   --
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE set_base_key_value (p_succession_plan_id NUMBER);

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
   PROCEDURE ins (p_rec IN OUT NOCOPY per_suc_shd.g_rec_type, p_effective_date IN DATE);

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
   PROCEDURE ins (
      p_succession_plan_id        OUT NOCOPY      NUMBER,
      p_person_id                 IN              NUMBER,
      p_position_id               IN              NUMBER DEFAULT NULL,
      p_business_group_id         IN              NUMBER,
      p_start_date                IN              DATE,
      p_time_scale                IN              VARCHAR2,
      p_end_date                  IN              DATE DEFAULT NULL,
      p_available_for_promotion   IN              VARCHAR2 DEFAULT NULL,
      p_manager_comments          IN              VARCHAR2 DEFAULT NULL,
      p_object_version_number     OUT NOCOPY      NUMBER,
      p_attribute_category        IN              VARCHAR2 DEFAULT NULL,
      p_attribute1                IN              VARCHAR2 DEFAULT NULL,
      p_attribute2                IN              VARCHAR2 DEFAULT NULL,
      p_attribute3                IN              VARCHAR2 DEFAULT NULL,
      p_attribute4                IN              VARCHAR2 DEFAULT NULL,
      p_attribute5                IN              VARCHAR2 DEFAULT NULL,
      p_attribute6                IN              VARCHAR2 DEFAULT NULL,
      p_attribute7                IN              VARCHAR2 DEFAULT NULL,
      p_attribute8                IN              VARCHAR2 DEFAULT NULL,
      p_attribute9                IN              VARCHAR2 DEFAULT NULL,
      p_attribute10               IN              VARCHAR2 DEFAULT NULL,
      p_attribute11               IN              VARCHAR2 DEFAULT NULL,
      p_attribute12               IN              VARCHAR2 DEFAULT NULL,
      p_attribute13               IN              VARCHAR2 DEFAULT NULL,
      p_attribute14               IN              VARCHAR2 DEFAULT NULL,
      p_attribute15               IN              VARCHAR2 DEFAULT NULL,
      p_attribute16               IN              VARCHAR2 DEFAULT NULL,
      p_attribute17               IN              VARCHAR2 DEFAULT NULL,
      p_attribute18               IN              VARCHAR2 DEFAULT NULL,
      p_attribute19               IN              VARCHAR2 DEFAULT NULL,
      p_attribute20               IN              VARCHAR2 DEFAULT NULL,
      p_effective_date            IN              DATE,
      p_job_id                    IN              NUMBER DEFAULT NULL,
      p_successee_person_id       IN              NUMBER DEFAULT NULL,
      p_person_rank               IN              NUMBER DEFAULT NULL,
      p_performance               IN              VARCHAR2 DEFAULT NULL,
      p_plan_status               IN              VARCHAR2 DEFAULT NULL,
      p_readiness_percentage      IN              NUMBER DEFAULT NULL
   );
--
END per_suc_ins;

/
