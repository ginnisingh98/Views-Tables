--------------------------------------------------------
--  DDL for Package BOMPKMUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPKMUD" AUTHID CURRENT_USER as
/*  $Header: BOMKMUDS.pls 120.1 2005/06/21 01:41:02 appldev ship $ */
-- +======================================================================+
-- | Copyright (c) 1992 Oracle Corporation Redwood Shores, California, USA|
-- |                       All rights reserved.                           |
-- +======================================================================+
-- NAME
--   bompkmud.sql
-- DESCRIPTION
--   Package of stored procedures which facilitate mass update of
--   components.  The list of revised items is given by the table
--   BOM_LISTS.  For each revised item, a change order is created
--   based on criteria stored in the tables:
--   ENG_ENG_CHANGES_INTERFACE, ENG_REVISED_ITEMS_INTERFACE and
--   BOM_INVENTORY_COMPS_INTERFACE.
-- NOTES
--   Initially intended to be called by the C program, BMCMUD.
-- MODIFIED (MM/DD/YY)
--   01/13/93
-- +======================================================================+
--
--  Global constants and data types
--
        yes constant number(1) := 1;
        no  constant number(1) := 2;

        Type ProgramInfoStruct is record   -- Profile option values
                (userid  number := -1,     -- user id
                 reqstid number := 0,      -- concurrent request id
                 appid   number := null,   -- application id
                 progid  number := null,   -- program id
                 loginid number := null,   -- login id
                 model_item_access number := 1,
                 planning_item_access number := 1,
                 standard_item_access number := 1);

--------------------------------- Procedure -------------------------------
--
--  NAME
--      Mass_update
--  DESCRIPTION
--      Creates change orders for all items listed in BOM_LISTS, based on
--      criteria stored in ENG_CHANGES_INTERFACE,
--      ENG_REVISED_ITEMS_INTERFACE and BOM_COMPS_INTERFACE.
--  REQUIRES
--      List id - unique identifier of list in BOM_LISTS.  This may either
--      be a session id or a sequence number from BOM_LISTS_S.
--      Model Item Access - Yes (1) or No (2).  If yes, delete all model bills
--      from list.
--      Planning Item Access - Yes (1) or No (2).  If yes, delete all planning
--      bills from list.
--      Standard Item Access - Yes (1) or No (2).  If yes, delete all
--      standard bills from list.
--      Change order - Change order number stored in ENG_CHANGES_INTERFACE.
--      Organization Id - Organization stored in ENG_CHANGES_INTERFACE.
--      Who values - Standard who column information.
--      Delete MCO - Delete interface rows after ECO is created.  Yes
--      (1) or No (2).
--  MODIFIES
--
--  RETURNS
--      Error message if unsuccessful, otherwise NULL.
--  NOTES
--      Originally intended for call by PRO*C program, BMCMUD.  Who column
--      information will be placed into ENG_ENG_CHANGES_INTERFACE by
--      the calling program.
--  EXAMPLE
--

        Procedure mass_update(list_id in number,
                      profile in ProgramInfoStruct,
                      change_order in varchar2,
                      org_id in number,
                      delete_mco in number,
                      error_message in out nocopy /* file.sql.39 change */ varchar2);
end BOMPKMUD;

 

/
