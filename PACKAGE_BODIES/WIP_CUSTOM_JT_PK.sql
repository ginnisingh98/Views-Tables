--------------------------------------------------------
--  DDL for Package Body WIP_CUSTOM_JT_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_CUSTOM_JT_PK" as
/* $Header: WIPWCJTB.pls 120.1 2007/12/31 15:56:17 kkonada noship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|									      |
| FILE NAME   : WIPWCJTB.pls						      |
|                                                                             |
| DESCRIPTION : This pcakage is a customization hook to facilitate            |
|               addition of additional customer xml data to be included
|               in Job traveler.
|
|                                                                             |
|                                                                             |
| HISTORY :     Kiran Konada
|                                                                             |
*============================================================================*/

/*---------------------------------------------------------------------------+
   This procedure can be use to send Custom XML to put into job Traveler. User
   will also need to customize RTF template to see the data on the PDF Job Traveler

   By default 'has_cxml' returns 'N' which implies no custom xml is present

   If Custom xml is returned user will need to set parameter 'has_cxml' to 'Y'

   Following attributes are for future use
   in_attr1
   in_attr2
   in_attr3
   out_attr1
   out_attr2
   out_attr3
+----------------------------------------------------------------------------*/

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
	  out_attr3       out NOCOPY      varchar2)
IS

BEGIN
       x_return_status := 'S';
      has_cxml := 'N';

END get_jtraveler_cxml;

end  WIP_CUSTOM_JT_PK;

/
