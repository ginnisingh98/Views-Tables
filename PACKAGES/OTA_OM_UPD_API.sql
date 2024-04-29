--------------------------------------------------------
--  DDL for Package OTA_OM_UPD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OM_UPD_API" AUTHID CURRENT_USER as
/* $Header: ottomupd.pkh 115.4 2002/11/29 13:21:04 jbharath noship $ */

-- ----------------------------------------------------------------------------
-- |-------------------------------< cancel_order>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to cancel order line.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_Line_id
-- p_org_id
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
Procedure cancel_order(
p_Line_id	 	IN	NUMBER,
p_org_id		IN	NUMBER
);


-- ----------------------------------------------------------------------------
-- |---------------------------------< create_rma>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to create RMA.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_Line_id
-- p_org_id
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
Procedure create_rma(
p_Line_id	 	IN	NUMBER,
p_org_id		IN	NUMBER);

-- ----------------------------------------------------------------------------
-- |---------------------------------< create_order>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to create New Order and order line.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_Line_id
-- p_inventory_item_id
-- p_customer_id
-- p_contact_id
--
-- out Argument
-- p_return_status
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
Procedure create_order(
p_customer_id	    IN	NUMBER,
p_contact_id          IN 	NUMBER,
p_inventory_item_id   IN 	NUMBER,
p_header_id           OUT NOCOPY  NUMBER,
p_line_id             OUT NOCOPY 	NUMBER,
p_return_status       OUT NOCOPY 	VARCHAR2);



-- ----------------------------------------------------------------------------
-- |--------------------------< retrieve_oe_messages>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a retrieve Error message when calling OM Process
--   Order API.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
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

PROCEDURE retrieve_oe_messages(p_msg_data out nocopy varchar2);


-- ----------------------------------------------------------------------------
-- |---------------------------------< create_enroll_from_om>------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to create New enrollment and this procedure
--   will be called by OM Sales Order form.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_Line_id
-- p_org_id
-- p_sold_to_org_id
-- p_ship_to_org_id
-- p_sold_to_contact_id
-- p_ship_to_contact_id
-- p_event_id
--
-- out Argument
-- p_return_status
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
Procedure create_enroll_from_om(
p_Line_id	          IN	NUMBER,
p_org_id	          IN 	NUMBER,
p_sold_to_org_id      IN 	NUMBER,
p_ship_to_org_id      IN      NUMBER,
p_sold_to_contact_id  IN 	NUMBER,
p_ship_to_contact_id  IN 	NUMBER,
p_event_id            IN      NUMBER,
p_order_date          IN      DATE,
x_enrollment_id       OUT NOCOPY 	NUMBER,
x_enrollment_status   OUT NOCOPY 	VARCHAR2,
x_return_status       OUT NOCOPY     VARCHAR2);

end ota_om_upd_api;

 

/
