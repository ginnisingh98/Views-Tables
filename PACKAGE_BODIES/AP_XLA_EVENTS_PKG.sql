--------------------------------------------------------
--  DDL for Package Body AP_XLA_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_XLA_EVENTS_PKG" AS
/* $Header: apxlaevb.pls 120.6 2005/07/25 06:31:45 sfeng noship $ */



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
RETURN INTEGER
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.CREATE_EVENT';

  RETURN
    XLA_EVENTS_PUB_PKG.CREATE_EVENT
    (
      p_event_source_info => p_event_source_info,
      p_event_type_code => p_event_type_code,
      p_event_date => p_event_date,
      p_event_status_code => p_event_status_code,
      p_event_number => p_event_number,
      p_transaction_date => p_transaction_date,
      p_reference_info => p_reference_info,
      p_valuation_method => p_valuation_method,
      p_security_context => p_security_context
    );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END create_event;

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
)
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.UPDATE_EVENT_STATUS';

  XLA_EVENTS_PUB_PKG.UPDATE_EVENT_STATUS
  (
    p_event_source_info => p_event_source_info,
    p_event_class_code => p_event_class_code,
    p_event_type_code => p_event_type_code,
    p_event_date => p_event_date,
    p_event_status_code => p_event_status_code,
    p_valuation_method => p_valuation_method,
    p_security_context => p_security_context
  );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END update_event_status;



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
)
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.UPDATE_EVENT[1]';

  XLA_EVENTS_PUB_PKG.UPDATE_EVENT
  (
    p_event_source_info => p_event_source_info,
    p_event_id => p_event_id,
    p_event_type_code => p_event_type_code,
    p_event_date => p_event_date,
    p_event_status_code => p_event_status_code,
    p_valuation_method => p_valuation_method,
    p_security_context => p_security_context
  );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END update_event;



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
)
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.UPDATE_EVENT[2]';

  XLA_EVENTS_PUB_PKG.UPDATE_EVENT
  (
    p_event_source_info => p_event_source_info,
    p_event_id => p_event_id,
    p_event_type_code => p_event_type_code,
    p_event_date => p_event_date,
    p_event_status_code => p_event_status_code,
    p_event_number => p_event_number,
    p_valuation_method => p_valuation_method,
    p_security_context => p_security_context
  );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END update_event;



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
)
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.UPDATE_EVENT[3]';

  XLA_EVENTS_PUB_PKG.UPDATE_EVENT
  (
    p_event_source_info => p_event_source_info,
    p_event_id => p_event_id,
    p_event_type_code => p_event_type_code,
    p_event_date => p_event_date,
    p_event_status_code => p_event_status_code,
    p_reference_info => p_reference_info,
    p_valuation_method => p_valuation_method,
    p_security_context => p_security_context
  );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END update_event;



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
)
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.UPDATE_EVENT[4]';

  XLA_EVENTS_PUB_PKG.UPDATE_EVENT
  (
    p_event_source_info => p_event_source_info,
    p_event_id => p_event_id,
    p_event_type_code => p_event_type_code,
    p_event_date => p_event_date,
    p_event_status_code => p_event_status_code,
    p_event_number => p_event_number,
    p_reference_info => p_reference_info,
    p_valuation_method => p_valuation_method,
    p_security_context => p_security_context
  );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END update_event;



PROCEDURE delete_event
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_id IN INTEGER,
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
)
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.DELETE_EVENT';

  XLA_EVENTS_PUB_PKG.DELETE_EVENT
  (
    p_event_source_info => p_event_source_info,
    p_event_id => p_event_id,
    p_valuation_method => p_valuation_method,
    p_security_context => p_security_context
  );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END delete_event;



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
RETURN INTEGER
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.DELETE_EVENTS';

  RETURN
    XLA_EVENTS_PUB_PKG.DELETE_EVENTS
    (
      p_event_source_info => p_event_source_info,
      p_event_class_code => p_event_class_code,
      p_event_type_code => p_event_type_code,
      p_event_date => p_event_date,
      p_valuation_method => p_valuation_method,
      p_security_context => p_security_context
    );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END delete_events;



FUNCTION get_event_info
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_id IN INTEGER,
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
)
RETURN XLA_EVENTS_PUB_PKG.T_EVENT_INFO
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.GET_EVENT_INFO';

  RETURN
    XLA_EVENTS_PUB_PKG.GET_EVENT_INFO
    (
      p_event_source_info => p_event_source_info,
      p_event_id => p_event_id,
      p_valuation_method => p_valuation_method,
      p_security_context => p_security_context
    );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END get_event_info;



FUNCTION get_event_status
(
  p_event_source_info IN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO,
  p_event_id IN INTEGER,
  p_valuation_method IN VARCHAR2,
  p_security_context IN XLA_EVENTS_PUB_PKG.T_SECURITY,
  p_calling_sequence IN VARCHAR2
)
RETURN VARCHAR2
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.GET_EVENT_STATUS';

  RETURN
    XLA_EVENTS_PUB_PKG.GET_EVENT_STATUS
    (
      p_event_source_info => p_event_source_info,
      p_event_id => p_event_id,
      p_valuation_method => p_valuation_method,
      p_security_context => p_security_context
    );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END get_event_status;



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
RETURN BOOLEAN
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.EVENT_EXISTS';

  RETURN
    XLA_EVENTS_PUB_PKG.EVENT_EXISTS
    (
      p_event_source_info => p_event_source_info,
      p_event_class_code => p_event_class_code,
      p_event_type_code => p_event_type_code,
      p_event_date => p_event_date,
      p_event_status_code => p_event_status_code,
      p_event_number => p_event_number,
      p_valuation_method => p_valuation_method,
      p_security_context => p_security_context
    );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END event_exists;



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
RETURN XLA_EVENTS_PUB_PKG.T_ARRAY_EVENT_INFO
IS

  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_XLA_EVENTS_PKG.GET_ARRAY_EVENT_INFO';

  RETURN
    XLA_EVENTS_PUB_PKG.GET_ARRAY_EVENT_INFO
    (
      p_event_source_info => p_event_source_info,
      p_event_class_code => p_event_class_code,
      p_event_type_code => p_event_type_code,
      p_event_date => p_event_date,
      p_event_status_code => p_event_status_code,
      p_valuation_method => p_valuation_method,
      p_security_context => p_security_context
    );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      AP_DEBUG_PKG.PRINT
      (
        p_debug => 'Y',
        p_app_short_name => 'SQLAP',
        p_message_name => 'AP_DEBUG',
        p_token1 => 'CALLING_SEQUENCE',
        p_value1 => l_curr_calling_sequence,
        p_token2 => 'ERROR',
        p_value2 => SQLERRM
      );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END get_array_event_info;



END AP_XLA_EVENTS_PKG;

/
