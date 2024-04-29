--------------------------------------------------------
--  DDL for Package MSD_BOM_COLLECTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_BOM_COLLECTIONS" AUTHID CURRENT_USER AS
/* $Header: msdbmcls.pls 115.1 2002/11/28 00:45:04 pinamati noship $ */

TYPE numberList               IS TABLE OF Number;
TYPE dateList                 IS TABLE OF Date;
TYPE varchar2List             IS TABLE OF Varchar2(255);

Type parent_type is RECORD (
     item_id                    number,
     planning_factor            number,
     quantity_per               number);

Type parents is TABLE of parent_type index by binary_integer;

/* Public Procedures */
procedure collect_bom_data (
  errbuf in out nocopy varchar2,
  retcode in out nocopy varchar2,
  p_instance_id in number);


END MSD_BOM_COLLECTIONS;

 

/
