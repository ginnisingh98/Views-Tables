--------------------------------------------------------
--  DDL for Package AP_XLA_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_XLA_EVENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: apxlaevs.pls 120.5 2005/07/25 06:31:25 sfeng noship $ */



FUNCTION create_event
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_type_code IN VARCHAR2,
  p_event_date IN DATE,
  p_event_status_code IN VARCHAR2,
  p_event_number IN INTEGER, -- DEFAULT NULL
  p_transaction_date IN DATE,
  p_reference_info IN XLA_EVENTS_PUB_PKG.T_EVENT_REFERENCE_INFO, -- DEFAULT NULL
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
)
RETURN INTEGER;

PROCEDURE update_event_status
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_class_code IN VARCHAR2, -- DEFAULT NULL
  p_event_type_code IN VARCHAR2, -- DEFAULT NULL
  p_event_date IN DATE, -- DEFAULT NULL
  p_event_status_code IN VARCHAR2,
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
);



PROCEDURE update_event
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_id IN INTEGER,
  p_event_type_code IN VARCHAR2, -- DEFAULT NULL
  p_event_date IN DATE, -- DEFAULT NULL
  p_event_status_code IN VARCHAR2, -- DEFAULT NULL
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
);



PROCEDURE update_event
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_id IN INTEGER,
  p_event_type_code IN VARCHAR2, -- DEFAULT NULL
  p_event_date IN DATE, -- DEFAULT NULL
  p_event_status_code IN VARCHAR2, -- DEFAULT NULL
  p_event_number IN INTEGER,
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
);



PROCEDURE update_event
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_id IN INTEGER,
  p_event_type_code IN VARCHAR2, -- DEFAULT NULL
  p_event_date IN DATE, -- DEFAULT NULL
  p_event_status_code IN VARCHAR2, -- DEFAULT NULL
  p_reference_info IN XLA_EVENTS_PUB_PKG.T_EVENT_REFERENCE_INFO,
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
);



PROCEDURE update_event
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_id IN INTEGER,
  p_event_type_code IN VARCHAR2, -- DEFAULT NULL
  p_event_date IN DATE, -- DEFAULT NULL
  p_event_status_code IN VARCHAR2, -- DEFAULT NULL
  p_event_number IN INTEGER,
  p_reference_info IN XLA_EVENTS_PUB_PKG.T_EVENT_REFERENCE_INFO,
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
);



PROCEDURE delete_event
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_id IN INTEGER,
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
);



FUNCTION delete_events
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_class_code IN VARCHAR2, -- DEFAULT NULL
  p_event_type_code IN VARCHAR2, -- DEFAULT NULL
  p_event_date IN DATE, -- DEFAULT NULL
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
)
RETURN INTEGER;



FUNCTION get_event_info
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_id IN INTEGER,
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
)
RETURN XLA_EVENTS_PUB_PKG.T_EVENT_INFO;



FUNCTION get_event_status
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_id IN INTEGER,
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
)
RETURN VARCHAR2;



FUNCTION event_exists
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_class_code IN VARCHAR2, -- DEFAULT NULL
  p_event_type_code IN VARCHAR2, -- DEFAULT NULL
  p_event_date IN DATE, -- DEFAULT NULL
  p_event_status_code IN VARCHAR2, -- DEFAULT NULL
  p_event_number IN INTEGER, -- DEFAULT NULL
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
)
RETURN BOOLEAN;



FUNCTION get_array_event_info
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_class_code IN VARCHAR2, -- DEFAULT NULL
  p_event_type_code IN VARCHAR2, -- DEFAULT NULL
  p_event_date IN DATE, -- DEFAULT NULL
  p_event_status_code IN VARCHAR2, -- DEFAULT NULL
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
)
RETURN XLA_EVENTS_PUB_PKG.T_ARRAY_EVENT_INFO;



END AP_XLA_EVENTS_PKG;

 

/
