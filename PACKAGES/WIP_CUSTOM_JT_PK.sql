--------------------------------------------------------
--  DDL for Package WIP_CUSTOM_JT_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_CUSTOM_JT_PK" AUTHID CURRENT_USER as
/* $Header: WIPWCJTS.pls 120.1 2007/12/31 15:55:20 kkonada noship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|									      |
| FILE NAME   : WIPWCJTS.pls						      |
|              								      |
| DESCRIPTION : This pcakage is a customization hook to facilitate            |
|               addition of additional customer xml data to be included
|               in Job traveler
|									      |
|
|               							      |
|									      |
| HISTORY :     Kiran Konada
|									      |
*============================================================================*/



Procedure get_jtraveler_cxml(
          wip_entity_id   in              number,
	  in_attr1        in              varchar2 default null,
	  in_attr2        in              varchar2 default null,
	  in_attr3        in              varchar2 default null,
	  cxml            out nocopy      blob,
	  has_cxml	  out NOCOPY	varchar2,
	  x_return_status out nocopy    varchar2,
          xErrorMessage   out NOCOPY	 VARCHAR2,
          xMessageName    out NOCOPY      VARCHAR2,
          xTableName      out NOCOPY      VARCHAR2,
	  out_attr1       out NOCOPY      varchar2,
	  out_attr2       out NOCOPY      varchar2,
	  out_attr3       out NOCOPY      varchar2);


end WIP_CUSTOM_JT_PK;

/
