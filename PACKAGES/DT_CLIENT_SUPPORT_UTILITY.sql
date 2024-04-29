--------------------------------------------------------
--  DDL for Package DT_CLIENT_SUPPORT_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DT_CLIENT_SUPPORT_UTILITY" AUTHID CURRENT_USER As
/* $Header: dtclsutl.pkh 120.0 2005/05/27 23:10:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_update_mode_list >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine which datetrack update modes are
--   allowed as of a specific date for particular entity and row. This
--   procedure will return a Boolean value for each of the DateTrack
--   update modes. A TRUE value indicates that the corresponding update mode
--   is available.
--
-- Pre-Requisities:
--   The package procedure specified in the p_package_name and
--   p_procedure_name parameter must exist in the database. The package
--   procedure must have the following parameters defined:
--     P_EFFECTIVE_DATE       IN     DATE
--     P_BASE_KEY_VALUE       IN     NUMBER
--     P_CORRECTION              OUT BOOLEAN
--     P_UPDATE                  OUT BOOLEAN
--     P_UPDATE_OVERRIDE         OUT BOOLEAN
--     P_UPDATE_CHANGE_INSERT    OUT BOOLEAN
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Effective date of the update
--                                                operation.
--   p_package_name                 Yes  varchar2 Name of the stored package
--                                                to be called.
--   p_procedure_name               Yes  varchar2 Name of the find_dt_upd_modes
--                                                procedure to call in the
--                                                p_package_name package.
--   p_base_key_value               Yes  number   The row identifier value
--                                                which needs to be passed to
--                                                the p_package_name package,
--                                                p_procedure_name procedure.
--
-- Post Success:
--   The corresponding OUT parameter for each DateTrack delete mode, will
--   indicate if it can be used for the specified row (p_base_key_value) as
--   of the specified date (p_effective_date).
--
--   Name                           Type     Description
--   p_correction                   boolean  Set to TRUE if the CORRECTION
--                                           DateTrack mode is available.
--                                           Otherwise set to FALSE.
--   p_update                       boolean  Set to TRUE if the UPDATE
--                                           DateTrack mode is available.
--                                           Otherwise set to FALSE.
--   p_update_override              boolean  Set to TRUE if the UPDATE_OVERRIDE
--                                           DateTrack mode is available.
--                                           Otherwise set to FALSE.
--   p_update_change_insert         boolean  Set to TRUE if the
--                                           UPDATE_CHANGE_INSERT
--                                           DateTrack mode is available.
--                                           Otherwise set to FALSE.
--
-- Post Failure:
--   An Oracle or application error message will be raised.
--
-- Developer Implementation Notes:
--   This procedure should only be called from the DTCSAPI Forms library.
--   If a list of valid update modes is required in any other case then the
--   correspond row handler find_dt_upd_modes procedure should be called
--   directly.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_update_mode_list
  (p_effective_date                in     date
  ,p_package_name                  in     varchar2
  ,p_procedure_name                in     varchar2
  ,p_base_key_value                in     number
  ,p_correction                       out nocopy boolean
  ,p_update                           out nocopy boolean
  ,p_update_override                  out nocopy boolean
  ,p_update_change_insert             out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_delete_mode_list >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine which datetrack delete modes are
--   allowed as of a specific date for particular entity and row. This
--   procedure will return a Boolean value for each of the DateTrack
--   delete modes. A TRUE value indicates that the corresponding delete mode
--   is available.
--
-- Pre-Requisities:
--   The package procedure specified in the p_package_name and
--   p_procedure_name parameter must exist in the database. The package
--   procedure must have the following parameters defined:
--     P_EFFECTIVE_DATE       IN     DATE
--     P_BASE_KEY_VALUE       IN     NUMBER
--     P_ZAP                     OUT BOOLEAN
--     P_DELETE                  OUT BOOLEAN
--     P_FUTURE_CHANGE           OUT BOOLEAN
--     P_DELETE_NEXT_CHANGE      OUT BOOLEAN
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Effective date of the delete
--                                                operation.
--   p_package_name                 Yes  varchar2 Name of the stored package
--                                                to be called.
--   p_procedure_name               Yes  varchar2 Name of the find_dt_del_modes
--                                                procedure to call in the
--                                                p_package_name package.
--   p_base_key_value               Yes  number   The row identifier value
--                                                which needs to be passed to
--                                                the p_package_name package,
--                                                p_procedure_name procedure.
--
-- Post Success:
--   The corresponding OUT parameter for each DateTrack delete mode, will
--   indicate if it can be used for the specified row (p_base_key_value) as
--   of the specified date (p_effective_date).
--
--   Name                           Type     Description
--   p_zap                          boolean  Set to TRUE if the ZAP
--                                           DateTrack mode is available.
--                                           Otherwise set to FALSE.
--   p_delete                       boolean  Set to TRUE if the DELETE
--                                           DateTrack mode is available.
--                                           Otherwise set to FALSE.
--   p_future_change                boolean  Set to TRUE if the FUTURE_CHANGE
--                                           DateTrack mode is available.
--                                           Otherwise set to FALSE.
--   p_delete_next_change           boolean  Set to TRUE if the
--                                           DELETE_NEXT_CHANGE
--                                           DateTrack mode is available.
--                                           Otherwise set to FALSE.
--
-- Post Failure:
--   An Oracle or application error message will be raised.
--
-- Developer Implementation Notes:
--   This procedure should only be called from the DTCSAPI Forms library.
--   If a list of valid delete modes is required in any other case then the
--   correspond row handler find_dt_del_modes procedure should be called
--   directly.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_delete_mode_list
  (p_effective_date                in     date
  ,p_package_name                  in     varchar2
  ,p_procedure_name                in     varchar2
  ,p_base_key_value                in     number
  ,p_zap                              out nocopy boolean
  ,p_delete                           out nocopy boolean
  ,p_future_change                    out nocopy boolean
  ,p_delete_next_change               out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lock_record >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure takes out database locks as of a specific date,
--   for a particular entity and record.
--
-- Pre-Requisities:
--   The package procedure specified in the p_package_name and
--   p_procedure_name parameter must exist in the database. The package
--   procedure must have the following parameters defined.
--     P_EFFECTIVE_DATE         IN     DATE
--     P_DATETRACK_MODE         IN     VARCHAR2
--     p_<uid_item_name>        IN     NUMBER
--     P_OBJECT_VERSION_NUMBER  IN     NUMBER
--     P_VALIDATION_START_DATE     OUT DATE
--     P_VALIDATION_END_DATE       OUT DATE
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Effective date of the lock
--                                                operation.
--   p_datetrack_mode               Yes  varchar2 DateTrack mode.
--   p_object_version_number        Yes  number   Object Version number of
--                                                the current record.
--   p_package_name                 Yes  varchar2 Name of the stored package
--                                                to be called.
--   p_procedure_name               Yes  varchar2 Name of the lck
--                                                procedure to call in the
--                                                p_package_name package.
--   p_uid_item_name                Yes  varchar2 Name of the unique ID
--                                                column name, without a "p_"
--                                                prefix.
--   p_base_key_value               Yes  number   The row identifier value
--                                                which needs to be passed into
--                                                the package procedure
--                                                "p_<p_uid_item_name>"
--                                                parameter.
--
-- Post Success:
--   The OUT parameter values indicate the date range the record is changing.
--   Any existing rows in the database which overlap this date range will
--   have been locked. Depending on the table and the DateTrack mode parent
--   table or child records will also be locked.
--
--   Name                           Type     Description
--   p_validation_start_date        date     The earliest day the record will
--                                           be changed for the specified
--                                           DateTrack mode.
--   p_validation_end_date          date     The latest day the record will
--                                           be changed for the specified
--                                           DateTrack mode.
--
-- Post Failure:
--   An Oracle or application error message will be raised and the database
--   locks will not be obtained.
--
-- Developer Implementation Notes:
--   This procedure should only be called from the DTCSAPI Forms library.
--   If a record locking is required in any other case then the correspond
--   row handler lck procedure should be called directly.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure lock_record
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_object_version_number         in     number
  ,p_package_name                  in     varchar2
  ,p_procedure_name                in     varchar2
  ,p_uid_item_name                 in     varchar2
  ,p_base_key_value                in     number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_update_modes_and_dates >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine which datetrack update modes are
--   allowed as of a specific date for particular entity and row. This
--   procedure will return a value 1 for each of the DateTrack
--   update modes. Also returns the validation date range for each of the
--   applicable datetrack mode. This procedure will be called from the
--   Framework code to support datatracking.
--
-- Pre-Requisities:
--   The package procedure specified in the p_package_name and
--   p_procedure_name parameter must exist in the database. The package
--   procedure must have the following parameters defined:
--     P_EFFECTIVE_DATE       IN     DATE
--     P_BASE_KEY_VALUE       IN     NUMBER
--     P_CORRECTION              OUT NUMBER
--     P_UPDATE                  OUT NUMBER
--     P_UPDATE_OVERRIDE         OUT NUMBER
--     P_UPDATE_CHANGE_INSERT    OUT NUMBER
--     P_UPDATE_START_DATE       OUT DATE
--     P_UPDATE_END_DATE         OUT DATE
--     P_UPD_CHG_START_DATE      OUT DATE
--     P_UPD_CHG_END_DATE        OUT DATE
--     P_CORRRECT_START_DATE     OUT DATE
--     P_CORRECT_END_DATE        OUT DATE
--     P_OVERRIDE_START_DATE     OUT DATE
--     P_OVERRIDE_END_DATE       OUT DATE
--

-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Effective date of the update
--                                                operation.
--   p_package_name                 Yes  varchar2 Name of the stored package
--                                                to be called.
--   p_procedure_name               Yes  varchar2 Name of the
--                                                find_dt_upd_modes_and_dates
--                                                procedure to call in the
--                                                p_package_name package.
--   p_base_key_value               Yes  number   The row identifier value
--                                                which needs to be passed to
--                                                the p_package_name package,
--                                                p_procedure_name procedure.
--
-- Post Success:
--   The corresponding OUT parameter for each DateTrack delete mode, will
--   indicate if it can be used for the specified row (p_base_key_value) as
--   of the specified date (p_effective_date).
--
--   Name                           Type     Description
--   p_correction                   NUMBER   Set to 1 if the CORRECTION
--                                           DateTrack mode is available.
--                                           Otherwise set to 0.
--   p_update                       NUMBER   Set to 1 if the UPDATE
--                                           DateTrack mode is available.
--                                           Otherwise set to 0.
--   p_update_override              NUMBER   Set to 1 if the UPDATE_OVERRIDE
--                                           DateTrack mode is available.
--                                           Otherwise set to 0.
--   p_update_change_insert         NUMBER   Set to 1 if the
--                                           UPDATE_CHANGE_INSERT
--                                           DateTrack mode is available.
--                                           Otherwise set to 0.
--   p_update_start_date            DATE     Set to validation start date for
--                                           the UPDATE mode. This is set only
--                                           when p_update parameter
--                                           is set to 1.
--   p_update_end_date              DATE     Set to validation end date for
--                                           the UPDATE mode. This is set only
--                                           when p_update parameter
--                                           is set to 1.
--   p_upd_chg_start_date           DATE     Set to validation start date for
--                                           the UPDATE_CHANGE_INSERT mode.
--                                           This is set only when
--                                           p_update_change_insert parameter
--                                           is set to 1.
--   p_upd_chg_end_date             DATE     Set to validation end date for
--                                           the UPDATE_CHANGE_INSERT mode.
--                                           This is set only when
--                                           p_update_change_insert parameter
--                                           is set to 1.
--   p_correction_start_date        DATE     Set to validation start date for
--                                           the CORRECTION mode. This is set
--                                           only when p_correction parameter
--                                           is set to 1.
--   p_correction_end_date          DATE     Set to validation end date for
--                                           the CORRECTION mode. This is set
--                                           only when p_correction parameter
--                                           is set to 1.
--   p_override_start_date          DATE     Set to validation start date for
--                                           the UPDATE_OVERRIDE mode. This is
--                                           set only p_update_override
--                                           parameter is set to 1.
--   p_override_end_date            DATE     Set to validation end date for
--                                           the UPDATE_OVERRIDE mode. This is
--                                           set only p_update_override
--                                           parameter is set to 1.
-- Post Failure:
--   An Oracle or application error message will be raised.
--
-- Developer Implementation Notes:
--   This procedure should only be called from the DT infractructure for
--   OAF based modules. If a list of valid update modes is required in
--   any other case then the correspond row handler find_dt_upd_modes
--   procedure should be called  directly.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_update_modes_and_dates
  (p_effective_date                in     date
  ,p_package_name                  in     varchar2
  ,p_procedure_name                in     varchar2
  ,p_base_key_value                in     number
  ,p_correction                    out nocopy number
  ,p_update                        out nocopy number
  ,p_update_override               out nocopy number
  ,p_update_change_insert          out nocopy number
  ,p_correction_start_date         out nocopy date
  ,p_correction_end_date           out nocopy date
  ,p_update_start_date             out nocopy date
  ,p_update_end_date               out nocopy date
  ,p_override_start_date           out nocopy date
  ,p_override_end_date             out nocopy date
  ,p_upd_chg_start_date            out nocopy date
  ,p_upd_chg_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_delete_modes_and_dates >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine which datetrack delete modes are
--   allowed as of a specific date for particular entity and row. This
--   procedure will return a value 1 for each of the valid DateTrack
--   delete modes. Also returns the validation date range for each of the
--   applicable datetrack mode. This package will be called from the
--   Framework code to support datetracking.
--
-- Pre-Requisities:
--   The package procedure specified in the p_package_name and
--   p_procedure_name parameter must exist in the database. The package
--   procedure must have the following parameters defined:
--     P_EFFECTIVE_DATE       IN     DATE
--     P_BASE_KEY_VALUE       IN     NUMBER
--     P_ZAP                     OUT NUMBER
--     P_DELETE                  OUT NUMBER
--     P_FUTURE_CHANGE           OUT NUMBER
--     P_DELETE_NEXT_CHANGE      OUT NUMBER
--     P_ZAP_START_DATE          OUT DATE
--     P_ZAP_END_DATE            OUT DATE
--     P_DELETE_START_DATE       OUT DATE
--     P_DELETE_END_DATE         OUT DATE
--     P_DEL_FUTURE_START_DATE   OUT DATE
--     P_DEL_FUTURE_END_DATE     OUT DATE
--     P_DEL_NEXT_START_DATE     OUT DATE
--     P_DEL_NEXT_END_DATE       OUT DATE
--

-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Effective date of the update
--                                                operation.
--   p_package_name                 Yes  varchar2 Name of the stored package
--                                                to be called.
--   p_procedure_name               Yes  varchar2 Name of the
--                                                find_dt_del_modes_and_dates
--                                                procedure to call in the
--                                                p_package_name package.
--   p_base_key_value               Yes  number   The row identifier value
--                                                which needs to be passed to
--                                                the p_package_name package,
--                                                p_procedure_name procedure.
--
-- Post Success:
--   The corresponding OUT parameter for each DateTrack delete mode, will
--   indicate if it can be used for the specified row (p_base_key_value) as
--   of the specified date (p_effective_date).
--
--   Name                           Type     Description
--   p_zap                          NUMBER   Set to 1 if the ZAP
--                                           DateTrack mode is available.
--                                           Otherwise set to 0.
--   p_delete                       NUMBER   Set to 1 if the DELETE
--                                           DateTrack mode is available.
--                                           Otherwise set to 0.
--   p_future_change                NUMBER   Set to 1 if the FUTURE_CHANGE
--                                           DateTrack mode is available.
--                                           Otherwise set to 0.
--   p_delete_next_change           NUMBER   Set to 1 if the
--                                           DELETE_NEXT_CHANGE
--                                           DateTrack mode is available.
--                                           Otherwise set to 0.
--   p_zap_start_date               DATE     Set to validation start date for
--                                           the ZAP mode. This is set only
--                                           when p_zap parameter is set to 1.
--   p_zap_end_date                 DATE     Set to validation end date for
--                                           the ZAP mode. This is set only
--                                           when p_zap parameter is set to 1.
--   p_delete_start_date            DATE     Set to validation start date for
--                                           the DELETE mode.
--                                           This is set only when
--                                           p_delete parameter is set to 1.
--   p_delete_end_date              DATE     Set to validation end date for
--                                           the DELETE mode.This is set only
--                                           where p_delete parameter is set
--                                           to 1.
--   p_del_future_start_date        DATE     Set to validation start date for
--                                           the FUTURE_CHANGE mode. This is set
--                                           only when p_future_change parameter
--                                           is set to 1.
--   p_del_future_end_date          DATE     Set to validation end date for
--                                           the FUTURE_CHANGE mode. This is set
--                                           only when p_future_change parameter
--                                           is set to 1.
--   p_del_next_start_date          DATE     Set to validation start date for
--                                           the DELETE_NEXT_CHANGE mode. This
--                                           is set only p_delete_next_change
--                                           parameter is set to 1.
--   p_del_next_end_date            DATE     Set to validation end date for
--                                           the DELETE_NEXT_CHANGE mode. This
--                                           is set only p_delete_next_change
--                                           parameter is set to 1.
--
-- Post Failure:
--   An Oracle or application error message will be raised.
--
-- Developer Implementation Notes:
--   This procedure should only be called from the DT infractructure for
--   OAF based modules. If a list of valid delete modes is required in
--   any other case then the corresponding row handler find_dt_del_modes
--   procedure should be called  directly.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_delete_modes_and_dates
  (p_effective_date                in     date
  ,p_package_name                  in     varchar2
  ,p_procedure_name                in     varchar2
  ,p_base_key_value                in     number
  ,p_zap                           out nocopy number
  ,p_delete                        out nocopy number
  ,p_future_change                 out nocopy number
  ,p_delete_next_change            out nocopy number
  ,p_zap_start_date                out nocopy date
  ,p_zap_end_date                  out nocopy date
  ,p_delete_start_date             out nocopy date
  ,p_delete_end_date               out nocopy date
  ,p_del_future_start_date         out nocopy date
  ,p_del_future_end_date           out nocopy date
  ,p_del_next_start_date           out nocopy date
  ,p_del_next_end_date             out nocopy date
  );

end dt_client_support_utility;

 

/
