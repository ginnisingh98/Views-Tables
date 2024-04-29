--------------------------------------------------------
--  DDL for Package OTA_CANCEL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CANCEL_API" AUTHID CURRENT_USER as
/* $Header: ottomint.pkh 120.20.12010000.10 2009/08/31 13:49:06 smahanka ship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_cancel_line>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to update delegate booking and event table.
--
--   This procedure will only be used for OTA and OM integration. The prurpose
--   of this procedure is only be called by OM Process Order API when the order
--   line got canceled or deleted. This procedure being created because Order
--   Management doesnot support workflow for Cancel or delete Order Line.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id,
--   p_org_id
--   p_uom
--   p_daemon_type
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
Procedure delete_cancel_line
 (
  p_line_id    IN Number,
  p_org_id     IN Number,
  p_UOM        IN Varchar2,
  P_daemon_type   IN varchar2,
  x_return_status OUT NOCOPY varchar2);


-- ----------------------------------------------------------------------------
-- |-----------------------------< cancel_enrollment>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a concurrent process which run in the background.
--
--   This procedure will only be used for OTA and OM integration. Basically this
--   procedure will select all delegate booking data that has daemon_flag='Y' and
--   Daemon_type  is not nul. If the enrollment got canceled and there is a
--   waitlisted student then the automatic waitlist processing will be called.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_user_id,
--   p_login_id
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

Procedure cancel_enrollment
(p_user_id in number,
p_login_id in number);

--
-- ----------------------------------------------------------------------------
-- |----------------------< initial_cancel_enrollment>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a concurrent process which run in the background.
--
--
-- Pre Conditions:
--   None.
--
-- Out Arguments:
--   errbuf
--   retcode
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

Procedure initial_cancel_enrollment
(ERRBUF OUT NOCOPY  VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2);

--
-- ----------------------------------------------------------------------------
-- |------------------------------------< upd_max_attendee  >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to update event maximum atenddee .
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id,
--   p_org_id,
--   p_max_attendee
--   p_uom
--   p_operation
--
-- Out Arguments:
-- x_return_status
-- x_msg_data
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

Procedure upd_max_attendee
(p_line_id in number,
p_org_id in number,
p_max_attendee in number,
p_uom   in varchar2,
p_operation in varchar2,
x_return_status out nocopy varchar2,
x_msg_data   out nocopy varchar2
);

end  ota_cancel_api ;


/
