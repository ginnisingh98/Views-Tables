--------------------------------------------------------
--  DDL for Package CSM_HA_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_HA_SERVICE_PUB" AUTHID CURRENT_USER AS
/* $Header: csmhsrvs.pls 120.0.12010000.1 2010/04/08 06:38:55 saradhak noship $*/

Function GET_HA_STATUS return VARCHAR2;
Function IS_WF_ITEM_TYPE_ENABLED( p_item_type IN VARCHAR2) return VARCHAR2;
Function IS_WF_EVENT_ENABLED( p_event_name  IN VARCHAR2) return VARCHAR2;
Function IS_WF_BES_ENABLED( p_sub_guid IN RAW) return VARCHAR2;

END CSM_HA_SERVICE_PUB;


/
