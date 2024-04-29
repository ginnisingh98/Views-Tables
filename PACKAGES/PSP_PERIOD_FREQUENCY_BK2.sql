--------------------------------------------------------
--  DDL for Package PSP_PERIOD_FREQUENCY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PERIOD_FREQUENCY_BK2" AUTHID CURRENT_USER as
/* $Header: PSPFBAIS.pls 120.0 2005/06/02 15:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Update_Period_Frequency_b >-------------------------|
-- ----------------------------------------------------------------------------
--


procedure Update_Period_frequency_b
 ( p_start_date                    in     date
  ,p_unit_of_measure               in     varchar2
  ,p_period_duration               in     number
  ,p_report_type                   in     varchar2
  ,p_period_frequency              in     varchar2
  ,p_period_frequency_id           in     number
  ,p_object_version_number         in     number
 );


--
-- ----------------------------------------------------------------------------
-- |-------------------------< Update_Period_Frequency_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Update_Period_frequency_a
 ( p_start_date                    in     date
  ,p_unit_of_measure               in     varchar2
  ,p_period_duration               in     number
  ,p_report_type                   in     varchar2
  ,p_period_frequency              in     varchar2
  ,p_period_frequency_id           in     number
  ,p_object_version_number         in     number
  ,p_api_warning                   in     varchar2
);

End  PSP_Period_frequency_BK2;

 

/
