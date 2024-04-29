--------------------------------------------------------
--  DDL for Package WF_RESOURCE_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_RESOURCE_LOAD" AUTHID CURRENT_USER as
/* $Header: wfrsldrs.pls 120.3 2005/10/04 23:16:43 hgandiko noship $ */

-- Variables
logbuf  varchar2(32000) := '';  -- special log messages that got past back



--
-- UPLOAD_RESOURCE
--
procedure UPLOAD_RESOURCE (
  x_type in varchar2,
  x_name in varchar2,
  x_protect_level in number,
  x_custom_level in number,
  x_id in number,
  x_text in varchar2,
  x_level_error out nocopy number
);


end WF_RESOURCE_LOAD;

 

/
