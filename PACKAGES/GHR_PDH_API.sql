--------------------------------------------------------
--  DDL for Package GHR_PDH_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDH_API" AUTHID CURRENT_USER as
/* $Header: ghpdhapi.pkh 120.0.12010000.3 2009/05/26 11:59:59 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< upd_date_notif_sent>--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This api updates the ghr_pd_routing_history table with the date_notification_sent
--
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type             Description
--   p_validate                          boolean          If true, the database remains
--                                                        unchanged. If false the
--                                                        assignment will be updated in
--   p_pa_request_id                 Y    number
--   p_date_notification_sent             date

-- Post Success:
--  The pd_routing_history record is update
--
-- Post Failure:
--   The api will not update the pd_routing_history record and raises an error
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

  procedure upd_date_notif_sent
  (p_validate                        in      boolean   default false,
   p_position_description_id         in      number,
   p_date_notification_sent          in      date      default trunc(sysdate)
   );
 end ghr_pdh_api;

/
