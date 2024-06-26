--------------------------------------------------------
--  DDL for Package PER_ASG_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASG_DEL" AUTHID CURRENT_USER as
/* $Header: peasgrhi.pkh 120.4.12010000.2 2009/11/20 06:56:26 sidsaxen ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_delete_dml control logic which handles
--   the actual datetrack dml.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml
        (p_rec                   in out nocopy per_asg_shd.g_rec_type,
         p_effective_date        in     date,
         p_datetrack_mode        in     varchar2,
         p_validation_start_date in     date,
         p_validation_end_date   in     date);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the datetrack delete
--   business process for the specified entity. The role of this
--   process is to delete the dateracked row from the HR schema.
--   This process is the main backbone of the del business process. The
--   processing of this procedure is as follows:
--   1) Ensure that the datetrack delete mode is valid.
--   2) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   3) The controlling validation process delete_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_delete business process is then executed which enables any
--      logic to be processed before the delete dml process is executed.
--   5) The delete_dml process will physical perform the delete dml for the
--      specified row.
--   6) The post_delete business process is then executed which enables any
--      logic to be processed after the delete dml process.
--   7) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the del process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.
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
Procedure del
  ( p_rec                         in  out nocopy per_asg_shd.g_rec_type,
    p_effective_date              in  date,
    p_effective_start_date        OUT NOCOPY     per_all_assignments_f.effective_start_date%TYPE,
    p_effective_end_date          OUT NOCOPY     per_all_assignments_f.effective_end_date%TYPE,
    --  p_validation_start_date   out nocopy     date,
    --  p_validation_end_date     out nocopy     date,
    p_datetrack_mode              in  varchar2,
    p_validate                    in  boolean  default false,
    p_org_now_no_manager_warning  out nocopy boolean,
    p_loc_change_tax_issues       OUT nocopy boolean,
    p_delete_asg_budgets          OUT nocopy boolean,
    p_element_salary_warning      OUT nocopy boolean,
    p_element_entries_warning     OUT nocopy boolean,
    p_spp_warning                 OUT nocopy boolean,
    P_cost_warning                OUT nocopy Boolean,
    p_life_events_exists   	  OUT nocopy Boolean,
    p_cobra_coverage_elements     OUT nocopy Boolean,
    p_assgt_term_elements         OUT nocopy Boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the delete business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to validate and delete the specified row from the
--   HR schema. The processing of this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      explicitly coding the attribute arguments into the g_rec_type
--      datatype.
--   2) After the conversion has taken place, the corresponding record del
--      interface business process is executed.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed (or rollbacked depending on the
--   p_validate status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   The attrbute in arguments should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure del
  (p_validate                     IN     boolean default false
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date               IN     DATE
  ,p_datetrack_mode               IN     VARCHAR2
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  ,p_loc_change_tax_issues           OUT NOCOPY boolean
  ,p_delete_asg_budgets              OUT NOCOPY boolean
  ,p_org_now_no_manager_warning      OUT NOCOPY boolean
  ,p_element_salary_warning          OUT NOCOPY boolean
  ,p_element_entries_warning         OUT NOCOPY boolean
  ,p_spp_warning                     OUT NOCOPY boolean
  ,P_cost_warning                    OUT NOCOPY boolean
  ,p_life_events_exists   	     OUT NOCOPY boolean
  ,p_cobra_coverage_elements         OUT NOCOPY boolean
  ,p_assgt_term_elements             OUT NOCOPY boolean );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the delete business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to validate and delete the specified row from the
--   HR schema. The processing of this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      explicitly coding the attribute arguments into the g_rec_type
--      datatype.
--   2) After the conversion has taken place, the corresponding record del
--      interface business process is executed.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed (or rollbacked depending on the
--   p_validate status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   The attrbute in arguments should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_assignment_id            in          number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date       out nocopy date,
  p_business_group_id        out nocopy number,
  p_object_version_number    in out nocopy number,
  p_effective_date           in     date,
  p_validation_start_date    out nocopy    date,
  p_validation_end_date      out nocopy    date,
  p_datetrack_mode           in     varchar2,
  p_validate                 in          boolean default false,
  p_org_now_no_manager_warning out nocopy boolean
  );
--
end per_asg_del;

/
