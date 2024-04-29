--------------------------------------------------------
--  DDL for Package WF_RENDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_RENDER" AUTHID CURRENT_USER as
/* $Header: wfrens.pls 120.5 2005/10/12 01:54:37 rtodi noship $ */
-- Bug 2580807 Moved Render from Wf_Event to here and rename it to
-- xml_style_sheet
-- Original Bug 2376197
/*
** Standard PLSQLCLOB API to render the CLOB event data of an event in a
** notification message.
*/

PROCEDURE XML_Style_Sheet (document_id   in     varchar2,
                  display_type  in     varchar2,
                  document      in out nocopy clob,
                  document_type in out nocopy varchar2);


---------------------------------------------------------------------------
end WF_RENDER;

 

/
