--------------------------------------------------------
--  DDL for Package BOM_STRUCT_SYNC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_STRUCT_SYNC_PUB" AUTHID CURRENT_USER AS
/* $Header: BOMSYNCS.pls 120.0 2008/01/02 15:13:23 pgandhik noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMSYNCS.pls
--
--  DESCRIPTION
--
--      Spec for package BOM_STRUCT_SYNC_PUB
--
--  NOTES
--
--  HISTORY
--
--  CREATED on 02-Jan-2008 by PGANDHIK
***************************************************************************/

PROCEDURE GET_STRUCTURE_PAYLOAD
(     p_org_id            IN NUMBER
  ,   p_item_id           IN NUMBER
  ,   x_Bom               OUT NOCOPY XMLTYPE
  ,   x_error_code        OUT NOCOPY NUMBER
  ,   x_error_message     OUT NOCOPY VARCHAR2
);


procedure GET_ITEMS_TO_SYNCH
(     p_org_id            IN NUMBER
  ,   p_item_id           IN NUMBER
  ,   x_Bom               OUT NOCOPY XMLTYPE
  ,   x_error_code        OUT NOCOPY NUMBER
  ,   x_error_message     OUT NOCOPY VARCHAR2

);

  PROCEDURE EXPLODE_STRUCTURE
  (     p_org_id            IN  NUMBER
    ,   p_item_id           IN  NUMBER
    ,   x_items_count       OUT NOCOPY NUMBER
    ,   x_error_code        OUT NOCOPY NUMBER
    ,   x_error_message     OUT NOCOPY VARCHAR2
  );


END BOM_STRUCT_SYNC_PUB;

/
