--------------------------------------------------------
--  DDL for Package EGO_TRACK_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_TRACK_EVENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOTEVTS.pls 120.1 2007/05/18 09:45:35 dedatta noship $ */

  /**
    * This function is used to track the business events raised
    * in EGO and BOM.
    * @param p_subscription_guid
    * @param p_event Workflow Event
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Bom Business Event Tester.
    */

FUNCTION EGO_LOG_EVENT (p_subscription_guid IN RAW,
                                 p_event IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2;
/*
  PROCEDURE getNextBusinessEventToProcess(
    p_sequence_id IN NUMBER,
    x_invoke_date OUT NOCOPY DATE,
    x_bus_evt_name  OUT NOCOPY VARCHAR2,
    x_event_data  OUT NOCOPY WF_EVENT_T,
    x_error_message OUT NOCOPY VARCHAR2
  );
  */

END EGO_TRACK_EVENTS_PKG;

/
