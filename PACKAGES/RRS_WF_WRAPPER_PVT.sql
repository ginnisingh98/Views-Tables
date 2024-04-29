--------------------------------------------------------
--  DDL for Package RRS_WF_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_WF_WRAPPER_PVT" AUTHID CURRENT_USER AS
/* $Header: RRSBUSES.pls 120.0.12010000.3 2010/01/22 23:54:28 pochang noship $ */
  PROCEDURE Raise_RRS_Event(p_event_type VARCHAR2,
                          p_siteId     VARCHAR2,
                          p_site_identification_number  VARCHAR2,
                          p_sg_type VARCHAR2,
                          p_sg_name VARCHAR2,
						  p_event_subtype VARCHAR2,
                          x_msg_data  OUT NOCOPY VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2);

END RRS_WF_WRAPPER_PVT;

/
