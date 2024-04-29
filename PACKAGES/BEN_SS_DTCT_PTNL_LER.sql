--------------------------------------------------------
--  DDL for Package BEN_SS_DTCT_PTNL_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SS_DTCT_PTNL_LER" AUTHID CURRENT_USER as
/* $Header: beptnldt.pkh 115.2 2003/02/12 10:30:55 rpgupta noship $ */
--
-- ----------------------------------------------------------------------------

--
-- ----------------------------------------------------------------------------
-- |------------------------< dtct_ptnl_ler >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--- This is a process which can be used by selfservice web pages( By OAB, HR and
-- Others) for finding out  about the newly created life events. This procedure will return
-- the appropriate message based on the Potential Life event status Code. This does not
-- necessary means that this potential life event will definitely affect their benefits
-- beacause we don't know unless we run benmngle. The purpose of this procedure is to simply
-- warn
--
--

-- Prerequisites:
--
--
-- Post Success: This procedure will return messages which are based on the Potential life event
-- status code.
-- This procedure will return null if there is no message approprita for the situation.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure dtct_ptnl_ler
(p_person_id              in number ,
p_business_group_id       in number,
p_effective_date          in date default trunc(sysdate),
p_message                 out nocopy varchar2 );


--
end  ben_ss_dtct_ptnl_ler;

 

/
