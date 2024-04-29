--------------------------------------------------------
--  DDL for Package OTA_FINANCE_LINE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FINANCE_LINE_BK3" AUTHID CURRENT_USER as
/* $Header: ottflapi.pkh 120.5 2006/09/11 10:28:57 niarora noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_FINANCE_LINE_BK3.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_FINANCE_LINE_B >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure DELETE_FINANCE_LINE_B
  (p_finance_line_id                   in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_FINANCE_LINE_A >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure DELETE_FINANCE_LINE_A
  (  p_finance_line_id                   in     number
  ,p_object_version_number         in     number
  );

end OTA_FINANCE_LINE_BK3;

 

/
