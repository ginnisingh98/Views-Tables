--------------------------------------------------------
--  DDL for Package FND_WF_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WF_EVENT" AUTHID CURRENT_USER AS
/* $Header: afwfeves.pls 120.2 2005/10/28 05:57:50 dbowles ship $ */


TYPE      Param_Rec     IS RECORD (Param_Name VARCHAR2(30)
          ,Param_Value VARCHAR2(2000) );
TYPE    Param_Table     IS TABLE OF Param_Rec INDEX BY BINARY_INTEGER;

--
-- Get_Form_Function (PUBLIC)
--   Get the form Function for a specific Workflow Item Key and Item Type.
-- IN:
--   itemtype - item type
--   itemkey - item key
--   aname - attribute name
-- RETURNS
--   Form Function Name
Function  Get_Form_Function(wf_item_type in varchar2,
      wf_item_key in varchar2)
      return varchar2;

-- Raise_Table(PRIVATE)
--   Raises a Workflow. This is to be called ONLY from Forms and is used ONLY
--   because of the lack of support of object types in Forms.
--   The Param Table is a PL/SQL table which can hold up to 100 parameters.
-- IN:
--   p_event_name - event name
--   p_event_key - event key
--   p_event_date - This is not being used here but is left for consistentcy with
--                  other wf procedures. It MUST always be NULL
--   p_param_table - This IN/OUT PL/SQL table contains the parameters to pass to the wf.raise
--   p_number_params - This is the number of parameters in the above PL/SQL table
--   p_send_date - Send Date
-- NOTE
--   The PL/SQL Table has the following restrictions
--     -There must be consecutive rows in PL/SQL table starting with index 1
--     -An identical number of paramters must be returned from raise3 as are submitted to it.
Procedure raise_table   (p_event_name       in varchar2,
                         p_event_key        in varchar2,
                         p_event_data       in clob default NULL,
                         p_param_table      in out NOCOPY Param_Table,
                         p_number_params    in NUMBER,
                         p_send_date        in date default NULL );

-- Get_Error_Name(PUBLIC)
--   Gets the Workflow Error Name
-- RETURNS
--   The Workflow Error Name
-- NOTE
--   This routine is to be used only from Forms.
--   It exists only because forms cannot fetch a package variable from a server-side package.

Function  Get_Error_Name RETURN VARCHAR2;

-- Erase(PRIVATE)
--   Erases all traces of a workflow
-- NOTE
--   This routine is to be used only from Forms.
--   It is only here to isolate forms from WF changes.

Procedure erase(p_item_type in varchar2,
                p_item_key  in varchar2);


end fnd_wf_event;

 

/
