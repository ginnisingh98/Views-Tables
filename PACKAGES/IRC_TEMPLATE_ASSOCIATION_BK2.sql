--------------------------------------------------------
--  DDL for Package IRC_TEMPLATE_ASSOCIATION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_TEMPLATE_ASSOCIATION_BK2" AUTHID CURRENT_USER as
/* $Header: iritaapi.pkh 120.4 2008/02/21 14:28:15 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_template_association_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_template_association_b
  (p_template_association_id          in      number
  ,p_template_id                      in      number
  ,p_effective_date                   in      date
  ,p_default_association              in      varchar2
  ,p_job_id                           in      number
  ,p_position_id                      in      number
  ,p_organization_id                  in      number
  ,p_start_date                       in      date
  ,p_end_date                         in      date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_template_association_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_template_association_a
  (p_template_association_id          in      number
  ,p_template_id                      in      number
  ,p_effective_date                   in      date
  ,p_default_association              in      varchar2
  ,p_job_id                           in      number
  ,p_position_id                      in      number
  ,p_organization_id                  in      number
  ,p_start_date                       in      date
  ,p_end_date                         in      date
  );
--
end irc_template_association_bk2;

/
