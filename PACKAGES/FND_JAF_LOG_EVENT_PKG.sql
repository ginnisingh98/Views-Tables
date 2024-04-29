--------------------------------------------------------
--  DDL for Package FND_JAF_LOG_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_JAF_LOG_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: FNDLJAFS.pls 120.0.12010000.7 2013/05/03 13:50:45 dbowles noship $ */

	Function getCurrentTimeInMillis return NUMBER;

	Procedure updateEventTimeStamp(
            p_request_id IN varchar2,
            p_event_name IN varchar2,
            p_event_type IN varchar2);

    Procedure logEventToDB(
            p_request_id IN varchar2,
            p_event_name IN varchar2,
            p_event_type IN varchar2,
            p_prev_event_payload IN varchar2,
            p_grand_prev_event_payload IN varchar2);

END FND_JAF_LOG_EVENT_PKG;

/
