--------------------------------------------------------
--  DDL for Package HXC_TIMEKEEPER_ERRORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMEKEEPER_ERRORS" AUTHID CURRENT_USER AS
/* $Header: hxctkerror.pkh 120.1 2005/06/28 23:45:00 dragarwa noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_timekeeper_errors.';
--

TYPE t_error_info IS RECORD
(
ERROR_ID 		NUMBER,
TRANSACTION_DETAIL_ID   NUMBER,
TIME_BUILDING_BLOCK_ID  NUMBER,
TIME_BUILDING_BLOCK_OVN	NUMBER,
TIME_ATTRIBUTE_ID	NUMBER,
TIME_ATTRIBUTE_OVN	NUMBER,
MESSAGE_NAME		VARCHAR2(30),
MESSAGE_FIELD		VARCHAR2(80),
MESSAGE_TOKENS 		VARCHAR2(4000),
APPLICATION_SHORT_NAME	VARCHAR2(50),
SCOPE_LEVEL		VARCHAR2(80),
MESSAGE_LEVEL		VARCHAR2(30),
MESSAGE_TEXT		VARCHAR2(4000),
PERSON_FULL_NAME	VARCHAR2(240),
START_PERIOD		DATE,
END_PERIOD		DATE,
MEASURE			NUMBER
);

TYPE t_error_table IS TABLE OF t_error_info
INDEX BY BINARY_INTEGER;


-- public procedure
--   show_timecard_errors
--
-- description
--   used in the timekeeper form errors window to display
--   the errors associated with a timecard in error
--   Also translates the message_name into an actual message

procedure show_timecard_errors (
	p_error_table		IN OUT NOCOPY 	t_error_table
,	p_timecard_id		IN	NUMBER
,	p_timecard_ovn  	IN	NUMBER
,	p_full_name		IN 	VARCHAR2
);

PROCEDURE maintain_errors
  (p_messages              IN  OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
  ,p_timecard_id	   IN  OUT NOCOPY NUMBER
  ,p_timecard_ovn  	   IN  OUT NOCOPY NUMBER);

PROCEDURE rollback_tc_or_set_err_status
  (p_message_table in out nocopy HXC_MESSAGE_TABLE_TYPE
  ,p_blocks        in out nocopy hxc_block_table_type
  ,p_attributes    in out nocopy hxc_attribute_table_type
  ,p_rollback	   in out nocopy BOOLEAN
  ,p_status_error  out NOCOPY BOOLEAN);


end hxc_timekeeper_errors;

 

/
