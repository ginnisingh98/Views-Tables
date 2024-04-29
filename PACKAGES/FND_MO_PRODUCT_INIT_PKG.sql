--------------------------------------------------------
--  DDL for Package FND_MO_PRODUCT_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_MO_PRODUCT_INIT_PKG" AUTHID CURRENT_USER as
/* $Header: AFMOPINS.pls 115.4 2003/09/26 15:11:01 kmaheswa noship $ */


--
-- register_application (PUBLIC)
--   Called by product teams to register their application as
--   access enabled
-- Input
--   p_appl_short_name: application short name
--   p_owner: Seed data or Custom data
procedure register_application(p_appl_short_name  	in varchar2,
                               p_owner                  in varchar2);
--
-- remove_application (PUBLIC)
--   Called by product teams to delete their application registration
--   as access enabled
-- Input
--   p_appl_short_name : application short name
procedure remove_application(p_appl_short_name       in varchar2);

--
-- register_application (PUBLIC) - Overloaded
--   Called by product teams to register their application as
--   access enabled
-- Input
--   p_appl_short_name: application short name
--   p_owner: Seed data or Custom data
procedure register_application(p_appl_short_name  	in varchar2,
                               p_owner                  in varchar2,
                               p_status                 in varchar2);

--
-- register_application (PUBLIC) - Overloaded
--   Called by product teams to register their application as
--   access enabled
-- Input
--   p_appl_short_name: application short name
--   p_owner: Seed data or Custom data
--   p_last_update_date: last updated date for the row
procedure register_application(p_appl_short_name  	in varchar2,
                               p_owner                  in varchar2,
                               p_status                 in varchar2,
			       p_last_update_date       in varchar2,
                               p_custom_mode            in varchar2);

end fnd_mo_product_init_pkg;

 

/
