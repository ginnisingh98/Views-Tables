--------------------------------------------------------
--  DDL for Package FND_CONCURRENT_BUSINESS_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONCURRENT_BUSINESS_EVENT" AUTHID CURRENT_USER as
/* $Header: AFCPBIAS.pls 120.0 2007/12/17 20:28:24 tkamiya noship $ */

-------------------------------------------------------------------------
-- constants
-------------------------------------------------------------------------
request_submitted                      constant number :=1;
request_on_hold                        constant number :=2;
request_resumed                        constant number :=3;
request_running                        constant number :=4;
program_completed                      constant number :=5;
request_postprocessing_started         constant number :=6;
request_postprocessing_ended           constant number :=7;
request_completed                      constant number :=8;

enable                                 constant char :='Y';
disable                                constant char :='N';

-------------------------------------------------------------------------
--   raise a business event
-------------------------------------------------------------------------
function raise_cp_bi_event(
  p_request_id         in number,
  p_event_number       in number,
  p_time_stamp 	       in date default null,
  p_status_code        in varchar2  default null)
  return number;

--------------------------------------------------------------------
--  change_event                                                  --
--  update particular event for a particular program              --
--  for p_new_status see constants                                --
--------------------------------------------------------------------
function change_event(
  p_application_id in number,
  p_concurrent_program_id in number,
  p_event_number in number,
  p_new_status in varchar2)
  return number;

--------------------------------------------------------------
--  enable event                                            --
--  call change event to enable event                       --
--------------------------------------------------------------
function enable_event(
  p_application_id in number,
  p_concurrent_program_id in number,
  p_event_number in number)
  return number;

--------------------------------------------------------------
--  disable event                                            --
--  call change event to enable event                       --
--------------------------------------------------------------
function disable_event(
  p_application_id in number,
  p_concurrent_program_id in number,
  p_event_number in number)
  return number;

end fnd_concurrent_business_event;

/
