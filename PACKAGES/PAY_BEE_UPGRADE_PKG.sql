--------------------------------------------------------
--  DDL for Package PAY_BEE_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BEE_UPGRADE_PKG" AUTHID CURRENT_USER as
/* $Header: pybeeupg.pkh 115.1 2004/02/17 09:15 susivasu noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< upgrade_iv_values >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure upgrades all input values for all batch lines
--   belong to a given assignment.
--
-- In Parameters:
--   NAME                           REQD TYPE     DESCRIPTION
--   ----                           ---- ----     -----------
--   P_ASG_ACTION_ID                Yes  number   Assignment Action Id.
--
-- {End Of Comments}
--
procedure upgrade_iv_values
  (P_ASG_ID                 in     number
  );
--
--
function upgrade_status
  (p_business_group_id             in     number
  ,p_short_name                    in     varchar2
  ) return varchar2;
--
--
end PAY_BEE_UPGRADE_PKG;

 

/
