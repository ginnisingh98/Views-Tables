--------------------------------------------------------
--  DDL for Package PSP_PERIOD_FREQUENCY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PERIOD_FREQUENCY_BK3" AUTHID CURRENT_USER as
/* $Header: PSPFBAIS.pls 120.0 2005/06/02 15:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Period_Frequency_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Delete_Period_frequency_b
 ( p_period_frequency_id           in     number
  ,p_object_version_number         in     number
 );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Update_Period_Frequency_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Delete_Period_frequency_a
 (
  p_period_frequency_id           in     number
  ,p_object_version_number         in     number
  ,p_api_warning                   in     varchar2
 );

 End  PSP_Period_frequency_BK3;

 

/
