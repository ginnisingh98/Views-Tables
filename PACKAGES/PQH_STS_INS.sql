--------------------------------------------------------
--  DDL for Package PQH_STS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_STS_INS" AUTHID CURRENT_USER as
/* $Header: pqstsrhi.pkh 120.0 2005/05/29 02:43 appldev noship $ */
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
  (p_statutory_situation_id  in  number);
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
  (p_effective_date               in date
  ,p_rec                      in out nocopy pqh_sts_shd.g_rec_type
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
  (p_effective_date               in     date
  ,p_business_group_id              in     number
  ,p_situation_name                 in     varchar2
  ,p_type_of_ps                     in     varchar2
  ,p_situation_type                 in     varchar2
  ,p_sub_type                       in     varchar2 default null
  ,p_source                         in     varchar2 default null
  ,p_location                       in     varchar2 default null
  ,p_reason                         in     varchar2 default null
  ,p_is_default                     in     varchar2 default null
  ,p_date_from                      in     date     default null
  ,p_date_to                        in     date     default null
  ,p_request_type                   in     varchar2 default null
  ,p_employee_agreement_needed      in     varchar2 default null
  ,p_manager_agreement_needed       in     varchar2 default null
  ,p_print_arrette                  in     varchar2 default null
  ,p_reserve_position               in     varchar2 default null
  ,p_allow_progressions             in     varchar2 default null
  ,p_extend_probation_period        in     varchar2 default null
  ,p_remuneration_paid              in     varchar2 default null
  ,p_pay_share                      in     number   default null
  ,p_pay_periods                    in     number   default null
  ,p_frequency                      in     varchar2 default null
  ,p_first_period_max_duration      in     number   default null
  ,p_min_duration_per_request       in     number   default null
  ,p_max_duration_per_request       in     number   default null
  ,p_max_duration_whole_career      in     number   default null
  ,p_renewable_allowed              in     varchar2 default null
  ,p_max_no_of_renewals             in     number   default null
  ,p_max_duration_per_renewal       in     number   default null
  ,p_max_tot_continuous_duration    in     number   default null
  ,p_remunerate_assign_status_id    in     number   default null
  ,p_statutory_situation_id            out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end pqh_sts_ins;

 

/
