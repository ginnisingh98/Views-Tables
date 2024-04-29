--------------------------------------------------------
--  DDL for Package HR_LEAVING_REASON_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEAVING_REASON_MIG" AUTHID CURRENT_USER as
/* $Header: pelearea.pkh 115.2 2002/12/06 11:14:42 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_LEAVING_REASON >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This is provided to update the leaving reason. It takes two input values
-- one is the existing leaving reason, and the other is the seeded leaving
-- reason. Once that is done, the existing leaving reason is updated in the
-- hr_lookups table, and the end_date will be set to sysdate, and the
-- enabled flag will be set to 'N'.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_existing_leaving_reason      Yes  Varchar2 cust.code for leaving_reason
--   p_seeded_leaving_reason        Yes  Varchar2 seeded code
--
-- Post Success:
-- N/A
--
-- Post Failure:
--   The package does not update a leaving_reason and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure leave_reas_mig
(ERRBUF                         out nocopy             varchar2
,RETCODE                        out nocopy             number
,p_existing_leaving_reason	in 		varchar2
,p_seeded_leaving_reason	in 		varchar2
,p_date				in		varchar2
);
end hr_leaving_reason_mig;

 

/
