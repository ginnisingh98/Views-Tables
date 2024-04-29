--------------------------------------------------------
--  DDL for Package PSP_PERIOD_FREQUENCY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PERIOD_FREQUENCY_API" AUTHID CURRENT_USER as
/* $Header: PSPFBAIS.pls 120.0 2005/06/02 15:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Create_Period_Frequency> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This Api help create Period Frequency, this procedure  ensures that appropriate
--  Business validation occurs on the data being inserted in the base tables.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure Create_Period_frequency
 ( p_validate                       in         BOOLEAN default false
  ,p_start_date                     in         date
  ,p_unit_of_measure                in         varchar2
  ,p_period_duration                in         number
  ,p_report_type                    in         varchar2 default null
  ,p_period_frequency               in         varchar2
  ,p_language_code                  in         varchar2 default hr_api.userenv_lang
  ,p_period_frequency_id            out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_api_warning                    out nocopy varchar2
  );


-- ----------------------------------------------------------------------------
-- |--------------------------< <Update_Period_Frequency> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This Api help Update  Period Frequency, this procedure  ensures that appropriate
--  Business validation occurs on the data being Updated in the base tables.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure Update_Period_Frequency
  (p_validate                       in     BOOLEAN  default false
  ,p_start_date                     in     date
  ,p_unit_of_measure                in     varchar2
  ,p_period_duration                in     number
  ,p_report_type                    in     varchar2 default null
  ,p_language_code                 in      varchar2 default hr_api.userenv_lang
  ,p_period_frequency               in     varchar2
  ,p_period_frequency_id            in     number
  ,p_object_version_number          in out nocopy number
  ,p_api_warning                    out nocopy varchar2
  );


-- ----------------------------------------------------------------------------
-- |--------------------------< <Delete_Period_Frequency> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This Api help Update  Period Frequency, this procedure  ensures that appropriate
--  Business validation occurs on the data being Updated in the base tables.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
  procedure Delete_Period_Frequency
  (p_validate                       in     BOOLEAN default false
  ,p_period_frequency_id            in     number
  ,p_object_version_number          in out nocopy number
  ,p_api_warning                       out nocopy varchar2
  );

End PSP_Period_frequency_API ;

 

/
