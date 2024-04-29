--------------------------------------------------------
--  DDL for Package FND_HELP_BUILDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_HELP_BUILDER" AUTHID CURRENT_USER as
/* $Header: AFMLHEPS.pls 115.10 2002/06/17 16:34:04 jvalenti ship $ */


procedure Launch(
  custom_level             in number default 100,
  root_parent_application  in varchar2 default '',
  root_parent_key          in varchar2 default '',
  root_node_application    in varchar2 default '',
  root_node_key            in varchar2 default '');

end Fnd_Help_Builder;

 

/
