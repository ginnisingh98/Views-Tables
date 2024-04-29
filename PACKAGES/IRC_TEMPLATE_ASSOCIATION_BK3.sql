--------------------------------------------------------
--  DDL for Package IRC_TEMPLATE_ASSOCIATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_TEMPLATE_ASSOCIATION_BK3" AUTHID CURRENT_USER as
/* $Header: iritaapi.pkh 120.4 2008/02/21 14:28:15 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_template_association_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_association_b
(p_template_association_id          in      number
,p_object_version_number            in      number
);

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_template_association_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_association_a
(p_template_association_id          in      number
,p_object_version_number            in      number
);
--
end irc_template_association_bk3;

/
