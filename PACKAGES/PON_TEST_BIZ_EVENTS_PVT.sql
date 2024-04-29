--------------------------------------------------------
--  DDL for Package PON_TEST_BIZ_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_TEST_BIZ_EVENTS_PVT" AUTHID CURRENT_USER AS
-- $Header: PONVTBES.pls 120.0 2005/10/03 13:17:51 sapandey noship $

FUNCTION TEST( p_subscription_guid  in      raw,
               p_event              in  out nocopy  wf_event_t
             ) return varchar2;

END PON_TEST_BIZ_EVENTS_PVT;

 

/
