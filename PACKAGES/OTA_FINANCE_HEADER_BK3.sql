--------------------------------------------------------
--  DDL for Package OTA_FINANCE_HEADER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FINANCE_HEADER_BK3" AUTHID CURRENT_USER as
/* $Header: ottfhapi.pkh 120.3 2006/08/30 09:49:56 niarora noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_FINANCE_HEADER_BK3.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_FINANCE_HEADER_B >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure DELETE_FINANCE_HEADER_B
  (p_finance_header_id                   in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_FINANCE_HEADER_A >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure DELETE_FINANCE_HEADER_A
  (  p_finance_header_id                   in     number
  ,p_object_version_number         in     number
  );

end OTA_FINANCE_HEADER_BK3;

 

/
