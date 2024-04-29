--------------------------------------------------------
--  DDL for Package DT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DT_API" AUTHID CURRENT_USER As
/* $Header: dtapiapi.pkh 120.0 2005/05/27 23:09:51 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< Return_Max_End_Date >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Function returns the maximum effective_end_date for the
--              specified table and primary key.
--              NOTE: if the maximum end date doesn't exist (i.e. no rows
--                    exist for the specified table, key values) then we
--                    return the null value.
-- ----------------------------------------------------------------------------
Function Return_Max_End_Date
         (p_base_table_name in varchar2,
          p_base_key_column in varchar2,
          p_base_key_value  in number)
         Return Date;
-- ----------------------------------------------------------------------------
-- |-------------------------< Find_DT_Upd_Modes >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Returns corresponding boolean values for the respective DT
--              update modes.
--
-- ----------------------------------------------------------------------------
Procedure Find_DT_Upd_Modes
          (p_effective_date       in         date,
           p_base_table_name      in         varchar2,
           p_base_key_column      in         varchar2,
           p_base_key_value       in         number,
           p_correction           out NOCOPY boolean,
           p_update               out NOCOPY boolean,
           p_update_override      out NOCOPY boolean,
           p_update_change_insert out NOCOPY boolean);
-- ----------------------------------------------------------------------------
-- |-------------------------< Find_DT_Del_Modes >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Returns corresponding boolean values for the respective DT
--              delete modes.
--
-- ----------------------------------------------------------------------------
Procedure Find_DT_Del_Modes
          (p_effective_date      in  date,
           p_base_table_name     in  varchar2,
           p_base_key_column     in  varchar2,
           p_base_key_value      in  number,
           p_parent_table_name1  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_column1  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_value1   in  number   default hr_api.g_number,
           p_parent_table_name2  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_column2  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_value2   in  number   default hr_api.g_number,
           p_parent_table_name3  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_column3  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_value3   in  number   default hr_api.g_number,
           p_parent_table_name4  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_column4  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_value4   in  number   default hr_api.g_number,
           p_parent_table_name5  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_column5  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_value5   in  number   default hr_api.g_number,
           p_parent_table_name6	 in  varchar2 default hr_api.g_varchar2,
           p_parent_key_column6	 in  varchar2 default hr_api.g_varchar2,
           p_parent_key_value6 	 in  number   default hr_api.g_number,
           p_parent_table_name7  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_column7  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_value7   in  number   default hr_api.g_number,
           p_parent_table_name8  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_column8  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_value8   in  number   default hr_api.g_number,
           p_parent_table_name9  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_column9  in  varchar2 default hr_api.g_varchar2,
           p_parent_key_value9   in  number   default hr_api.g_number,
           p_parent_table_name10 in  varchar2 default hr_api.g_varchar2,
           p_parent_key_column10 in  varchar2 default hr_api.g_varchar2,
           p_parent_key_value10  in  number   default hr_api.g_number,
           p_zap                 out NOCOPY boolean,
           p_delete              out NOCOPY boolean,
           p_future_change       out NOCOPY boolean,
           p_delete_next_change  out NOCOPY boolean);
-- ----------------------------------------------------------------------------
-- |----------------------------< Validate_DT_Mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Validates and returns the validation start and end dates for
--              the DateTrack mode provided.
--
-- ----------------------------------------------------------------------------
Procedure Validate_DT_Mode
         (p_datetrack_mode              in varchar2,
          p_effective_date              in date,
          p_base_table_name             in varchar2,
          p_base_key_column             in varchar2,
          p_base_key_value              in number,
          p_parent_table_name1          in varchar2 default hr_api.g_varchar2,
          p_parent_key_column1          in varchar2 default hr_api.g_varchar2,
          p_parent_key_value1           in number   default hr_api.g_number,
          p_parent_table_name2          in varchar2 default hr_api.g_varchar2,
          p_parent_key_column2          in varchar2 default hr_api.g_varchar2,
          p_parent_key_value2           in number   default hr_api.g_number,
          p_parent_table_name3          in varchar2 default hr_api.g_varchar2,
          p_parent_key_column3          in varchar2 default hr_api.g_varchar2,
          p_parent_key_value3           in number   default hr_api.g_number,
          p_parent_table_name4          in varchar2 default hr_api.g_varchar2,
          p_parent_key_column4          in varchar2 default hr_api.g_varchar2,
          p_parent_key_value4           in number   default hr_api.g_number,
          p_parent_table_name5          in varchar2 default hr_api.g_varchar2,
          p_parent_key_column5          in varchar2 default hr_api.g_varchar2,
          p_parent_key_value5           in number   default hr_api.g_number,
          p_parent_table_name6	        in varchar2 default hr_api.g_varchar2,
          p_parent_key_column6	        in varchar2 default hr_api.g_varchar2,
          p_parent_key_value6 	        in number   default hr_api.g_number,
          p_parent_table_name7          in varchar2 default hr_api.g_varchar2,
          p_parent_key_column7          in varchar2 default hr_api.g_varchar2,
          p_parent_key_value7           in number   default hr_api.g_number,
          p_parent_table_name8          in varchar2 default hr_api.g_varchar2,
          p_parent_key_column8          in varchar2 default hr_api.g_varchar2,
          p_parent_key_value8           in number   default hr_api.g_number,
          p_parent_table_name9          in varchar2 default hr_api.g_varchar2,
          p_parent_key_column9          in varchar2 default hr_api.g_varchar2,
          p_parent_key_value9           in number   default hr_api.g_number,
          p_parent_table_name10         in varchar2 default hr_api.g_varchar2,
          p_parent_key_column10         in varchar2 default hr_api.g_varchar2,
          p_parent_key_value10          in number   default hr_api.g_number,
          p_child_table_name1           in varchar2 default hr_api.g_varchar2,
          p_child_key_column1           in varchar2 default hr_api.g_varchar2,
          p_child_table_name2           in varchar2 default hr_api.g_varchar2,
          p_child_key_column2           in varchar2 default hr_api.g_varchar2,
          p_child_table_name3           in varchar2 default hr_api.g_varchar2,
          p_child_key_column3           in varchar2 default hr_api.g_varchar2,
          p_child_table_name4           in varchar2 default hr_api.g_varchar2,
          p_child_key_column4           in varchar2 default hr_api.g_varchar2,
          p_child_table_name5           in varchar2 default hr_api.g_varchar2,
          p_child_key_column5           in varchar2 default hr_api.g_varchar2,
          p_child_table_name6           in varchar2 default hr_api.g_varchar2,
          p_child_key_column6           in varchar2 default hr_api.g_varchar2,
          p_child_table_name7           in varchar2 default hr_api.g_varchar2,
          p_child_key_column7           in varchar2 default hr_api.g_varchar2,
          p_child_table_name8           in varchar2 default hr_api.g_varchar2,
          p_child_key_column8           in varchar2 default hr_api.g_varchar2,
          p_child_table_name9           in varchar2 default hr_api.g_varchar2,
          p_child_key_column9           in varchar2 default hr_api.g_varchar2,
          p_child_table_name10          in varchar2 default hr_api.g_varchar2,
          p_child_key_column10          in varchar2 default hr_api.g_varchar2,
          p_child_alt_base_key_column1  in varchar2 default null,
          p_child_alt_base_key_column2  in varchar2 default null,
          p_child_alt_base_key_column3  in varchar2 default null,
          p_child_alt_base_key_column4  in varchar2 default null,
          p_child_alt_base_key_column5  in varchar2 default null,
          p_child_alt_base_key_column6  in varchar2 default null,
          p_child_alt_base_key_column7  in varchar2 default null,
          p_child_alt_base_key_column8  in varchar2 default null,
          p_child_alt_base_key_column9  in varchar2 default null,
          p_child_alt_base_key_column10 in varchar2 default null,
          p_enforce_foreign_locking     in boolean  default true,
          p_validation_start_date       out NOCOPY date,
          p_validation_end_date         out NOCOPY date);
-- ----------------------------------------------------------------------------
-- |------------------------< Validate_DT_Upd_Mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Function returns TRUE is update mode is valid.
--
-- ----------------------------------------------------------------------------
Function Validate_DT_Upd_Mode(p_datetrack_mode in varchar2) Return Boolean;
-- ----------------------------------------------------------------------------
-- |------------------------< Validate_DT_Del_Mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Function returns TRUE is delete mode is valid.
--
-- ----------------------------------------------------------------------------
Function Validate_DT_Del_Mode(p_datetrack_mode in varchar2) Return Boolean;
-- ----------------------------------------------------------------------------
-- |------------------------< Validate_DT_Upd_Mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Validates the datetrack update mode.
--
-- ----------------------------------------------------------------------------
Procedure Validate_DT_Upd_Mode(p_datetrack_mode in varchar2);
-- ----------------------------------------------------------------------------
-- |------------------------< Validate_DT_Del_Mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Validates the datetrack delete mode.
--
-- ----------------------------------------------------------------------------
Procedure Validate_DT_Del_Mode(p_datetrack_mode in varchar2);
-- ----------------------------------------------------------------------------
-- |-----------------------< Get_Object_Version_Number >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Function will return the next object version number to be used
--              within datetrack for an insert or update dml operation. The
--              returned object version number will be determined by taking
--              the maximum object version number for the datetracked rows
--              and then incrementing by 1. All datetrack modes will call
--              this function except 'ZAP'.
--
-- ----------------------------------------------------------------------------
Function Get_Object_Version_Number
        (p_base_table_name in varchar2,
         p_base_key_column in varchar2,
         p_base_key_value  in number)
        Return Number;
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Function returns a boolean value. TRUE will be set if
--              row exists for the specified table between the from and to
--              dates else FALSE will be returned.
--
-- ----------------------------------------------------------------------------
Function Rows_Exist
         (p_base_table_name in varchar2,
          p_base_key_column in varchar2,
          p_base_key_value  in number,
          p_from_date       in date,
          p_to_date         in date default hr_api.g_eot)
         Return Boolean;
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: This function is used to determine if datetrack rows exist
--              between the from and to date specified.
--              If the datetrack rows do exist for the duration then a TRUE
--              value will be returned else FALSE will be returned.
--              If the p_base_key_value is null then this function will assume
--              that an optional relationship is in force and will return TRUE
--
-- ----------------------------------------------------------------------------
Function Check_Min_Max_Dates
         (p_base_table_name in varchar2,
          p_base_key_column in varchar2,
          p_base_key_value  in number,
          p_from_date       in date,
          p_to_date         in date)
         Return Boolean;
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description:
--   This procedure is used to determine which datetrack update modes are
--   allowed as of a specific date for particular entity and row. This
--   procedure will return a value 1 for each of the DateTrack
--   update modes. Also returns the validation date range for each of the
--   applicable datetrack mode.
--
-- ----------------------------------------------------------------------------
procedure Find_DT_Upd_Modes_And_Dates
  (p_effective_date                in     date
  ,p_base_table_name               in     varchar2
  ,p_base_key_column               in     varchar2
  ,p_base_key_value                in     number
  ,p_correction                       out nocopy boolean
  ,p_update                           out nocopy boolean
  ,p_update_override                  out nocopy boolean
  ,p_update_change_insert             out nocopy boolean
  ,p_correction_start_date            out nocopy date
  ,p_correction_end_date              out nocopy date
  ,p_update_start_date                out nocopy date
  ,p_update_end_date                  out nocopy date
  ,p_override_start_date              out nocopy date
  ,p_override_end_date                out nocopy date
  ,p_upd_chg_start_date               out nocopy date
  ,p_upd_chg_end_date                 out nocopy date
  );
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description:
--   This procedure is used to determine which datetrack delete modes are
--   allowed as of a specific date for particular entity and row. This
--   procedure will return a value 1 for each of the valid DateTrack
--   delete modes. Also returns the validation date range for each of the
--   applicable datetrack mode.
--
-- ----------------------------------------------------------------------------
procedure Find_DT_Del_Modes_And_Dates
  (p_effective_date                in     date
  ,p_base_table_name               in     varchar2
  ,p_base_key_column               in     varchar2
  ,p_base_key_value                in     number
  ,p_parent_table_name1            in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column1  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value1   	   in     number   default hr_api.g_number
  ,p_parent_table_name2  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column2  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value2   	   in     number   default hr_api.g_number
  ,p_parent_table_name3  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column3  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value3   	   in     number   default hr_api.g_number
  ,p_parent_table_name4  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column4  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value4   	   in     number   default hr_api.g_number
  ,p_parent_table_name5  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column5  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value5   	   in     number   default hr_api.g_number
  ,p_parent_table_name6  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column6  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value6   	   in     number   default hr_api.g_number
  ,p_parent_table_name7  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column7  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value7   	   in     number   default hr_api.g_number
  ,p_parent_table_name8  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column8  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value8   	   in     number   default hr_api.g_number
  ,p_parent_table_name9  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column9  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value9   	   in     number   default hr_api.g_number
  ,p_parent_table_name10 	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column10 	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value10  	   in     number   default hr_api.g_number
  ,p_zap                              out nocopy boolean
  ,p_delete                           out nocopy boolean
  ,p_future_change                    out nocopy boolean
  ,p_delete_next_change               out nocopy boolean
  ,p_zap_start_date                   out nocopy date
  ,p_zap_end_date                     out nocopy date
  ,p_delete_start_date                out nocopy date
  ,p_delete_end_date                  out nocopy date
  ,p_del_future_start_date            out nocopy date
  ,p_del_future_end_date              out nocopy date
  ,p_del_next_start_date              out nocopy date
  ,p_del_next_end_date                out nocopy date
  );


End DT_Api;

 

/
