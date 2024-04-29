--------------------------------------------------------
--  DDL for Package Body FND_CONC_REQ_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_REQ_DETAIL" as
/* $Header: AFCPREQDB.pls 120.0.12010000.1 2009/04/10 17:40:41 tkamiya noship $ */

--
-- Private variables
--

request_rec	fnd_concurrent_requests%ROWTYPE; -- represents entire row in fnd_concurrent_requests

-- ================================================
-- PRIVATE FUNCTIONS/PROCEDURES
-- ================================================

--
-- FUNCTION
--   get_all_req_detail_reqid
--
-- Purpose
--   get request detail based on request_id
--   if request_id is not given, get it from FND_GLOBAL
--   if request_id is unobtainable, exit FALSE
--   sets the global record for all columns of fnd_cocurrent_requests
--
-- Note
--   returns true/false
--
function get_all_req_detail_reqid(p_request_id in number) return boolean is
v_request_id	number;
v_status	boolean;

begin
--
-- if request_id is not given, find it in fnd_global
-- if that fails, return false and exit
--
  if (p_request_id < 1 or p_request_id IS NULL) then
     v_request_id := FND_GLOBAL.conc_request_id;
     if (v_request_id < 1 or v_request_id IS NULL) then
     	return(FALSE);
     end if;
  else
	v_request_id := p_request_id;
  end if;

--
-- populate the entire row content into global variable
-- if sql fails, return false
--
  request_rec := NULL;

  select *
  into request_rec
  from FND_CONCURRENT_REQUESTS
  where REQUEST_ID = v_request_id;

  return(TRUE);

--
-- sql failed
-- returning... sorry!
--
  exception
        when others then
           request_rec := NULL;
           return(FALSE);

end get_all_req_detail_reqid;



-- ================================================
-- PUBLIC FUNCTIONS/PROCEDURES
-- ================================================

--
-- FUNCTION
--   get_ALL_REQUEST_INFO
--
-- Purpose
--   get all information of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ALL_REQUEST_INFO(request_id in number) return fnd_concurrent_requests%ROWTYPE is
v_status        boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec);
  else
     return(NULL);
  end if;

end get_ALL_REQUEST_INFO;


--
-- FUNCTION
--   get_REQUEST_ID
--
-- Purpose
--   get REQUEST_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_REQUEST_ID(request_id in number) return fnd_concurrent_requests.REQUEST_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.REQUEST_ID);
  else
     return(NULL);
  end if;

end get_REQUEST_ID;


--
-- FUNCTION
--   get_LAST_UPDATE_DATE
--
-- Purpose
--   get LAST_UPDATE_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_LAST_UPDATE_DATE(request_id in number) return fnd_concurrent_requests.LAST_UPDATE_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.LAST_UPDATE_DATE);
  else
     return(NULL);
  end if;

end get_LAST_UPDATE_DATE;


--
-- FUNCTION
--   get_LAST_UPDATED_BY
--
-- Purpose
--   get LAST_UPDATED_BY of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_LAST_UPDATED_BY(request_id in number) return fnd_concurrent_requests.LAST_UPDATED_BY%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.LAST_UPDATED_BY);
  else
     return(NULL);
  end if;

end get_LAST_UPDATED_BY;


--
-- FUNCTION
--   get_REQUEST_DATE
--
-- Purpose
--   get REQUEST_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_REQUEST_DATE(request_id in number) return fnd_concurrent_requests.REQUEST_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.REQUEST_DATE);
  else
     return(NULL);
  end if;

end get_REQUEST_DATE;


--
-- FUNCTION
--   get_REQUESTED_BY
--
-- Purpose
--   get REQUESTED_BY of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_REQUESTED_BY(request_id in number) return fnd_concurrent_requests.REQUESTED_BY%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.REQUESTED_BY);
  else
     return(NULL);
  end if;

end get_REQUESTED_BY;


--
-- FUNCTION
--   get_PHASE_CODE
--
-- Purpose
--   get PHASE_CODE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PHASE_CODE(request_id in number) return fnd_concurrent_requests.PHASE_CODE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PHASE_CODE);
  else
     return(NULL);
  end if;

end get_PHASE_CODE;


--
-- FUNCTION
--   get_STATUS_CODE
--
-- Purpose
--   get STATUS_CODE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_STATUS_CODE(request_id in number) return fnd_concurrent_requests.STATUS_CODE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.STATUS_CODE);
  else
     return(NULL);
  end if;

end get_STATUS_CODE;


--
-- FUNCTION
--   get_PRIORITY_REQUEST_ID
--
-- Purpose
--   get PRIORITY_REQUEST_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PRIORITY_REQUEST_ID(request_id in number) return fnd_concurrent_requests.PRIORITY_REQUEST_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PRIORITY_REQUEST_ID);
  else
     return(NULL);
  end if;

end get_PRIORITY_REQUEST_ID;


--
-- FUNCTION
--   get_PRIORITY
--
-- Purpose
--   get PRIORITY of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PRIORITY(request_id in number) return fnd_concurrent_requests.PRIORITY%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PRIORITY);
  else
     return(NULL);
  end if;

end get_PRIORITY;


--
-- FUNCTION
--   get_REQUESTED_START_DATE
--
-- Purpose
--   get REQUESTED_START_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_REQUESTED_START_DATE(request_id in number) return fnd_concurrent_requests.REQUESTED_START_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.REQUESTED_START_DATE);
  else
     return(NULL);
  end if;

end get_REQUESTED_START_DATE;


--
-- FUNCTION
--   get_HOLD_FLAG
--
-- Purpose
--   get HOLD_FLAG of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_HOLD_FLAG(request_id in number) return fnd_concurrent_requests.HOLD_FLAG%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.HOLD_FLAG);
  else
     return(NULL);
  end if;

end get_HOLD_FLAG;


--
-- FUNCTION
--   get_ENFORCE_SERIALITY_FLAG
--
-- Purpose
--   get ENFORCE_SERIALITY_FLAG of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ENFORCE_SERIALITY_FLAG(request_id in number) return fnd_concurrent_requests.ENFORCE_SERIALITY_FLAG%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ENFORCE_SERIALITY_FLAG);
  else
     return(NULL);
  end if;

end get_ENFORCE_SERIALITY_FLAG;


--
-- FUNCTION
--   get_SINGLE_THREAD_FLAG
--
-- Purpose
--   get SINGLE_THREAD_FLAG of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_SINGLE_THREAD_FLAG(request_id in number) return fnd_concurrent_requests.SINGLE_THREAD_FLAG%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.SINGLE_THREAD_FLAG);
  else
     return(NULL);
  end if;

end get_SINGLE_THREAD_FLAG;


--
-- FUNCTION
--   get_HAS_SUB_REQUEST
--
-- Purpose
--   get HAS_SUB_REQUEST of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_HAS_SUB_REQUEST(request_id in number) return fnd_concurrent_requests.HAS_SUB_REQUEST%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.HAS_SUB_REQUEST);
  else
     return(NULL);
  end if;

end get_HAS_SUB_REQUEST;


--
-- FUNCTION
--   get_IS_SUB_REQUEST
--
-- Purpose
--   get IS_SUB_REQUEST of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_IS_SUB_REQUEST(request_id in number) return fnd_concurrent_requests.IS_SUB_REQUEST%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.IS_SUB_REQUEST);
  else
     return(NULL);
  end if;

end get_IS_SUB_REQUEST;


--
-- FUNCTION
--   get_IMPLICIT_CODE
--
-- Purpose
--   get IMPLICIT_CODE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_IMPLICIT_CODE(request_id in number) return fnd_concurrent_requests.IMPLICIT_CODE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.IMPLICIT_CODE);
  else
     return(NULL);
  end if;

end get_IMPLICIT_CODE;


--
-- FUNCTION
--   get_UPDATE_PROTECTED
--
-- Purpose
--   get UPDATE_PROTECTED of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_UPDATE_PROTECTED(request_id in number) return fnd_concurrent_requests.UPDATE_PROTECTED%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.UPDATE_PROTECTED);
  else
     return(NULL);
  end if;

end get_UPDATE_PROTECTED;


--
-- FUNCTION
--   get_QUEUE_METHOD_CODE
--
-- Purpose
--   get QUEUE_METHOD_CODE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_QUEUE_METHOD_CODE(request_id in number) return fnd_concurrent_requests.QUEUE_METHOD_CODE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.QUEUE_METHOD_CODE);
  else
     return(NULL);
  end if;

end get_QUEUE_METHOD_CODE;


--
-- FUNCTION
--   get_ARGUMENT_INPUT_METHOD_CODE
--
-- Purpose
--   get ARGUMENT_INPUT_METHOD_CODE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT_INPUT_METHOD_CODE(request_id in number) return fnd_concurrent_requests.ARGUMENT_INPUT_METHOD_CODE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT_INPUT_METHOD_CODE);
  else
     return(NULL);
  end if;

end get_ARGUMENT_INPUT_METHOD_CODE;


--
-- FUNCTION
--   get_ORACLE_ID
--
-- Purpose
--   get ORACLE_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ORACLE_ID(request_id in number) return fnd_concurrent_requests.ORACLE_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ORACLE_ID);
  else
     return(NULL);
  end if;

end get_ORACLE_ID;


--
-- FUNCTION
--   get_PROGRAM_APPLICATION_ID
--
-- Purpose
--   get PROGRAM_APPLICATION_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PROGRAM_APPLICATION_ID(request_id in number) return fnd_concurrent_requests.PROGRAM_APPLICATION_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PROGRAM_APPLICATION_ID);
  else
     return(NULL);
  end if;

end get_PROGRAM_APPLICATION_ID;


--
-- FUNCTION
--   get_CONCURRENT_PROGRAM_ID
--
-- Purpose
--   get CONCURRENT_PROGRAM_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CONCURRENT_PROGRAM_ID(request_id in number) return fnd_concurrent_requests.CONCURRENT_PROGRAM_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CONCURRENT_PROGRAM_ID);
  else
     return(NULL);
  end if;

end get_CONCURRENT_PROGRAM_ID;


--
-- FUNCTION
--   get_RESPONSIB_APPLICATION_ID
--
-- Purpose
--   get RESPONSIBILITY_APPLICATION_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESPONSIB_APPLICATION_ID(request_id in number) return fnd_concurrent_requests.RESPONSIBILITY_APPLICATION_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESPONSIBILITY_APPLICATION_ID);
  else
     return(NULL);
  end if;

end get_RESPONSIB_APPLICATION_ID;


--
-- FUNCTION
--   get_RESPONSIBILITY_ID
--
-- Purpose
--   get RESPONSIBILITY_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESPONSIBILITY_ID(request_id in number) return fnd_concurrent_requests.RESPONSIBILITY_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESPONSIBILITY_ID);
  else
     return(NULL);
  end if;

end get_RESPONSIBILITY_ID;


--
-- FUNCTION
--   get_NUMBER_OF_ARGUMENTS
--
-- Purpose
--   get NUMBER_OF_ARGUMENTS of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_NUMBER_OF_ARGUMENTS(request_id in number) return fnd_concurrent_requests.NUMBER_OF_ARGUMENTS%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.NUMBER_OF_ARGUMENTS);
  else
     return(NULL);
  end if;

end get_NUMBER_OF_ARGUMENTS;


--
-- FUNCTION
--   get_NUMBER_OF_COPIES
--
-- Purpose
--   get NUMBER_OF_COPIES of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_NUMBER_OF_COPIES(request_id in number) return fnd_concurrent_requests.NUMBER_OF_COPIES%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.NUMBER_OF_COPIES);
  else
     return(NULL);
  end if;

end get_NUMBER_OF_COPIES;


--
-- FUNCTION
--   get_SAVE_OUTPUT_FLAG
--
-- Purpose
--   get SAVE_OUTPUT_FLAG of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_SAVE_OUTPUT_FLAG(request_id in number) return fnd_concurrent_requests.SAVE_OUTPUT_FLAG%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.SAVE_OUTPUT_FLAG);
  else
     return(NULL);
  end if;

end get_SAVE_OUTPUT_FLAG;


--
-- FUNCTION
--   get_NLS_COMPLIANT
--
-- Purpose
--   get NLS_COMPLIANT of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_NLS_COMPLIANT(request_id in number) return fnd_concurrent_requests.NLS_COMPLIANT%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.NLS_COMPLIANT);
  else
     return(NULL);
  end if;

end get_NLS_COMPLIANT;


--
-- FUNCTION
--   get_LAST_UPDATE_LOGIN
--
-- Purpose
--   get LAST_UPDATE_LOGIN of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_LAST_UPDATE_LOGIN(request_id in number) return fnd_concurrent_requests.LAST_UPDATE_LOGIN%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.LAST_UPDATE_LOGIN);
  else
     return(NULL);
  end if;

end get_LAST_UPDATE_LOGIN;


--
-- FUNCTION
--   get_NLS_LANGUAGE
--
-- Purpose
--   get NLS_LANGUAGE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_NLS_LANGUAGE(request_id in number) return fnd_concurrent_requests.NLS_LANGUAGE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.NLS_LANGUAGE);
  else
     return(NULL);
  end if;

end get_NLS_LANGUAGE;


--
-- FUNCTION
--   get_NLS_TERRITORY
--
-- Purpose
--   get NLS_TERRITORY of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_NLS_TERRITORY(request_id in number) return fnd_concurrent_requests.NLS_TERRITORY%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.NLS_TERRITORY);
  else
     return(NULL);
  end if;

end get_NLS_TERRITORY;


--
-- FUNCTION
--   get_PRINTER
--
-- Purpose
--   get PRINTER of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PRINTER(request_id in number) return fnd_concurrent_requests.PRINTER%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PRINTER);
  else
     return(NULL);
  end if;

end get_PRINTER;


--
-- FUNCTION
--   get_PRINT_STYLE
--
-- Purpose
--   get PRINT_STYLE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PRINT_STYLE(request_id in number) return fnd_concurrent_requests.PRINT_STYLE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PRINT_STYLE);
  else
     return(NULL);
  end if;

end get_PRINT_STYLE;


--
-- FUNCTION
--   get_PRINT_GROUP
--
-- Purpose
--   get PRINT_GROUP of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PRINT_GROUP(request_id in number) return fnd_concurrent_requests.PRINT_GROUP%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PRINT_GROUP);
  else
     return(NULL);
  end if;

end get_PRINT_GROUP;


--
-- FUNCTION
--   get_REQ_CLASS_APPLICATION_ID
--
-- Purpose
--   get REQUEST_CLASS_APPLICATION_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_REQ_CLASS_APPLICATION_ID(request_id in number) return fnd_concurrent_requests.REQUEST_CLASS_APPLICATION_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.REQUEST_CLASS_APPLICATION_ID);
  else
     return(NULL);
  end if;

end get_REQ_CLASS_APPLICATION_ID;


--
-- FUNCTION
--   get_CONC_REQUEST_CLASS_ID
--
-- Purpose
--   get CONCURRENT_REQUEST_CLASS_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CONC_REQUEST_CLASS_ID(request_id in number) return fnd_concurrent_requests.CONCURRENT_REQUEST_CLASS_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CONCURRENT_REQUEST_CLASS_ID);
  else
     return(NULL);
  end if;

end get_CONC_REQUEST_CLASS_ID;


--
-- FUNCTION
--   get_PARENT_REQUEST_ID
--
-- Purpose
--   get PARENT_REQUEST_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PARENT_REQUEST_ID(request_id in number) return fnd_concurrent_requests.PARENT_REQUEST_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PARENT_REQUEST_ID);
  else
     return(NULL);
  end if;

end get_PARENT_REQUEST_ID;


--
-- FUNCTION
--   get_CONC_LOGIN_ID
--
-- Purpose
--   get CONC_LOGIN_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CONC_LOGIN_ID(request_id in number) return fnd_concurrent_requests.CONC_LOGIN_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CONC_LOGIN_ID);
  else
     return(NULL);
  end if;

end get_CONC_LOGIN_ID;


--
-- FUNCTION
--   get_LANGUAGE_ID
--
-- Purpose
--   get LANGUAGE_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_LANGUAGE_ID(request_id in number) return fnd_concurrent_requests.LANGUAGE_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.LANGUAGE_ID);
  else
     return(NULL);
  end if;

end get_LANGUAGE_ID;


--
-- FUNCTION
--   get_DESCRIPTION
--
-- Purpose
--   get DESCRIPTION of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_DESCRIPTION(request_id in number) return fnd_concurrent_requests.DESCRIPTION%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.DESCRIPTION);
  else
     return(NULL);
  end if;

end get_DESCRIPTION;


--
-- FUNCTION
--   get_REQ_INFORMATION
--
-- Purpose
--   get REQ_INFORMATION of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_REQ_INFORMATION(request_id in number) return fnd_concurrent_requests.REQ_INFORMATION%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.REQ_INFORMATION);
  else
     return(NULL);
  end if;

end get_REQ_INFORMATION;


--
-- FUNCTION
--   get_RESUBMIT_INTERVAL
--
-- Purpose
--   get RESUBMIT_INTERVAL of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESUBMIT_INTERVAL(request_id in number) return fnd_concurrent_requests.RESUBMIT_INTERVAL%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESUBMIT_INTERVAL);
  else
     return(NULL);
  end if;

end get_RESUBMIT_INTERVAL;


--
-- FUNCTION
--   get_RESUB_INTERVAL_UNIT_CODE
--
-- Purpose
--   get RESUBMIT_INTERVAL_UNIT_CODE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESUB_INTERVAL_UNIT_CODE(request_id in number) return fnd_concurrent_requests.RESUBMIT_INTERVAL_UNIT_CODE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESUBMIT_INTERVAL_UNIT_CODE);
  else
     return(NULL);
  end if;

end get_RESUB_INTERVAL_UNIT_CODE;


--
-- FUNCTION
--   get_RESUB_INTERVAL_TYPE_CODE
--
-- Purpose
--   get RESUBMIT_INTERVAL_TYPE_CODE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESUB_INTERVAL_TYPE_CODE(request_id in number) return fnd_concurrent_requests.RESUBMIT_INTERVAL_TYPE_CODE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESUBMIT_INTERVAL_TYPE_CODE);
  else
     return(NULL);
  end if;

end get_RESUB_INTERVAL_TYPE_CODE;


--
-- FUNCTION
--   get_RESUBMIT_TIME
--
-- Purpose
--   get RESUBMIT_TIME of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESUBMIT_TIME(request_id in number) return fnd_concurrent_requests.RESUBMIT_TIME%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESUBMIT_TIME);
  else
     return(NULL);
  end if;

end get_RESUBMIT_TIME;


--
-- FUNCTION
--   get_RESUBMIT_END_DATE
--
-- Purpose
--   get RESUBMIT_END_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESUBMIT_END_DATE(request_id in number) return fnd_concurrent_requests.RESUBMIT_END_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESUBMIT_END_DATE);
  else
     return(NULL);
  end if;

end get_RESUBMIT_END_DATE;


--
-- FUNCTION
--   get_RESUBMITTED
--
-- Purpose
--   get RESUBMITTED of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESUBMITTED(request_id in number) return fnd_concurrent_requests.RESUBMITTED%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESUBMITTED);
  else
     return(NULL);
  end if;

end get_RESUBMITTED;


--
-- FUNCTION
--   get_CONTROLLING_MANAGER
--
-- Purpose
--   get CONTROLLING_MANAGER of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CONTROLLING_MANAGER(request_id in number) return fnd_concurrent_requests.CONTROLLING_MANAGER%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CONTROLLING_MANAGER);
  else
     return(NULL);
  end if;

end get_CONTROLLING_MANAGER;


--
-- FUNCTION
--   get_ACTUAL_START_DATE
--
-- Purpose
--   get ACTUAL_START_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ACTUAL_START_DATE(request_id in number) return fnd_concurrent_requests.ACTUAL_START_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ACTUAL_START_DATE);
  else
     return(NULL);
  end if;

end get_ACTUAL_START_DATE;


--
-- FUNCTION
--   get_ACTUAL_COMPLETION_DATE
--
-- Purpose
--   get ACTUAL_COMPLETION_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ACTUAL_COMPLETION_DATE(request_id in number) return fnd_concurrent_requests.ACTUAL_COMPLETION_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ACTUAL_COMPLETION_DATE);
  else
     return(NULL);
  end if;

end get_ACTUAL_COMPLETION_DATE;


--
-- FUNCTION
--   get_COMPLETION_TEXT
--
-- Purpose
--   get COMPLETION_TEXT of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_COMPLETION_TEXT(request_id in number) return fnd_concurrent_requests.COMPLETION_TEXT%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.COMPLETION_TEXT);
  else
     return(NULL);
  end if;

end get_COMPLETION_TEXT;


--
-- FUNCTION
--   get_OUTCOME_PRODUCT
--
-- Purpose
--   get OUTCOME_PRODUCT of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_OUTCOME_PRODUCT(request_id in number) return fnd_concurrent_requests.OUTCOME_PRODUCT%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.OUTCOME_PRODUCT);
  else
     return(NULL);
  end if;

end get_OUTCOME_PRODUCT;


--
-- FUNCTION
--   get_OUTCOME_CODE
--
-- Purpose
--   get OUTCOME_CODE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_OUTCOME_CODE(request_id in number) return fnd_concurrent_requests.OUTCOME_CODE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.OUTCOME_CODE);
  else
     return(NULL);
  end if;

end get_OUTCOME_CODE;


--
-- FUNCTION
--   get_CPU_SECONDS
--
-- Purpose
--   get CPU_SECONDS of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CPU_SECONDS(request_id in number) return fnd_concurrent_requests.CPU_SECONDS%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CPU_SECONDS);
  else
     return(NULL);
  end if;

end get_CPU_SECONDS;


--
-- FUNCTION
--   get_LOGICAL_IOS
--
-- Purpose
--   get LOGICAL_IOS of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_LOGICAL_IOS(request_id in number) return fnd_concurrent_requests.LOGICAL_IOS%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.LOGICAL_IOS);
  else
     return(NULL);
  end if;

end get_LOGICAL_IOS;


--
-- FUNCTION
--   get_PHYSICAL_IOS
--
-- Purpose
--   get PHYSICAL_IOS of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PHYSICAL_IOS(request_id in number) return fnd_concurrent_requests.PHYSICAL_IOS%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PHYSICAL_IOS);
  else
     return(NULL);
  end if;

end get_PHYSICAL_IOS;


--
-- FUNCTION
--   get_LOGFILE_NAME
--
-- Purpose
--   get LOGFILE_NAME of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_LOGFILE_NAME(request_id in number) return fnd_concurrent_requests.LOGFILE_NAME%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.LOGFILE_NAME);
  else
     return(NULL);
  end if;

end get_LOGFILE_NAME;


--
-- FUNCTION
--   get_LOGFILE_NODE_NAME
--
-- Purpose
--   get LOGFILE_NODE_NAME of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_LOGFILE_NODE_NAME(request_id in number) return fnd_concurrent_requests.LOGFILE_NODE_NAME%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.LOGFILE_NODE_NAME);
  else
     return(NULL);
  end if;

end get_LOGFILE_NODE_NAME;


--
-- FUNCTION
--   get_OUTFILE_NAME
--
-- Purpose
--   get OUTFILE_NAME of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_OUTFILE_NAME(request_id in number) return fnd_concurrent_requests.OUTFILE_NAME%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.OUTFILE_NAME);
  else
     return(NULL);
  end if;

end get_OUTFILE_NAME;


--
-- FUNCTION
--   get_OUTFILE_NODE_NAME
--
-- Purpose
--   get OUTFILE_NODE_NAME of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_OUTFILE_NODE_NAME(request_id in number) return fnd_concurrent_requests.OUTFILE_NODE_NAME%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.OUTFILE_NODE_NAME);
  else
     return(NULL);
  end if;

end get_OUTFILE_NODE_NAME;


--
-- FUNCTION
--   get_ARGUMENT_TEXT
--
-- Purpose
--   get ARGUMENT_TEXT of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT_TEXT(request_id in number) return fnd_concurrent_requests.ARGUMENT_TEXT%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT_TEXT);
  else
     return(NULL);
  end if;

end get_ARGUMENT_TEXT;


--
-- FUNCTION
--   get_ARGUMENT1
--
-- Purpose
--   get ARGUMENT1 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT1(request_id in number) return fnd_concurrent_requests.ARGUMENT1%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT1);
  else
     return(NULL);
  end if;

end get_ARGUMENT1;


--
-- FUNCTION
--   get_ARGUMENT2
--
-- Purpose
--   get ARGUMENT2 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT2(request_id in number) return fnd_concurrent_requests.ARGUMENT2%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT2);
  else
     return(NULL);
  end if;

end get_ARGUMENT2;


--
-- FUNCTION
--   get_ARGUMENT3
--
-- Purpose
--   get ARGUMENT3 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT3(request_id in number) return fnd_concurrent_requests.ARGUMENT3%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT3);
  else
     return(NULL);
  end if;

end get_ARGUMENT3;


--
-- FUNCTION
--   get_ARGUMENT4
--
-- Purpose
--   get ARGUMENT4 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT4(request_id in number) return fnd_concurrent_requests.ARGUMENT4%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT4);
  else
     return(NULL);
  end if;

end get_ARGUMENT4;


--
-- FUNCTION
--   get_ARGUMENT5
--
-- Purpose
--   get ARGUMENT5 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT5(request_id in number) return fnd_concurrent_requests.ARGUMENT5%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT5);
  else
     return(NULL);
  end if;

end get_ARGUMENT5;


--
-- FUNCTION
--   get_ARGUMENT6
--
-- Purpose
--   get ARGUMENT6 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT6(request_id in number) return fnd_concurrent_requests.ARGUMENT6%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT6);
  else
     return(NULL);
  end if;

end get_ARGUMENT6;


--
-- FUNCTION
--   get_ARGUMENT7
--
-- Purpose
--   get ARGUMENT7 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT7(request_id in number) return fnd_concurrent_requests.ARGUMENT7%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT7);
  else
     return(NULL);
  end if;

end get_ARGUMENT7;


--
-- FUNCTION
--   get_ARGUMENT8
--
-- Purpose
--   get ARGUMENT8 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT8(request_id in number) return fnd_concurrent_requests.ARGUMENT8%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT8);
  else
     return(NULL);
  end if;

end get_ARGUMENT8;


--
-- FUNCTION
--   get_ARGUMENT9
--
-- Purpose
--   get ARGUMENT9 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT9(request_id in number) return fnd_concurrent_requests.ARGUMENT9%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT9);
  else
     return(NULL);
  end if;

end get_ARGUMENT9;


--
-- FUNCTION
--   get_ARGUMENT10
--
-- Purpose
--   get ARGUMENT10 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT10(request_id in number) return fnd_concurrent_requests.ARGUMENT10%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT10);
  else
     return(NULL);
  end if;

end get_ARGUMENT10;


--
-- FUNCTION
--   get_ARGUMENT11
--
-- Purpose
--   get ARGUMENT11 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT11(request_id in number) return fnd_concurrent_requests.ARGUMENT11%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT11);
  else
     return(NULL);
  end if;

end get_ARGUMENT11;


--
-- FUNCTION
--   get_ARGUMENT12
--
-- Purpose
--   get ARGUMENT12 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT12(request_id in number) return fnd_concurrent_requests.ARGUMENT12%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT12);
  else
     return(NULL);
  end if;

end get_ARGUMENT12;


--
-- FUNCTION
--   get_ARGUMENT13
--
-- Purpose
--   get ARGUMENT13 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT13(request_id in number) return fnd_concurrent_requests.ARGUMENT13%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT13);
  else
     return(NULL);
  end if;

end get_ARGUMENT13;


--
-- FUNCTION
--   get_ARGUMENT14
--
-- Purpose
--   get ARGUMENT14 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT14(request_id in number) return fnd_concurrent_requests.ARGUMENT14%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT14);
  else
     return(NULL);
  end if;

end get_ARGUMENT14;


--
-- FUNCTION
--   get_ARGUMENT15
--
-- Purpose
--   get ARGUMENT15 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT15(request_id in number) return fnd_concurrent_requests.ARGUMENT15%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT15);
  else
     return(NULL);
  end if;

end get_ARGUMENT15;


--
-- FUNCTION
--   get_ARGUMENT16
--
-- Purpose
--   get ARGUMENT16 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT16(request_id in number) return fnd_concurrent_requests.ARGUMENT16%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT16);
  else
     return(NULL);
  end if;

end get_ARGUMENT16;


--
-- FUNCTION
--   get_ARGUMENT17
--
-- Purpose
--   get ARGUMENT17 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT17(request_id in number) return fnd_concurrent_requests.ARGUMENT17%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT17);
  else
     return(NULL);
  end if;

end get_ARGUMENT17;


--
-- FUNCTION
--   get_ARGUMENT18
--
-- Purpose
--   get ARGUMENT18 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT18(request_id in number) return fnd_concurrent_requests.ARGUMENT18%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT18);
  else
     return(NULL);
  end if;

end get_ARGUMENT18;


--
-- FUNCTION
--   get_ARGUMENT19
--
-- Purpose
--   get ARGUMENT19 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT19(request_id in number) return fnd_concurrent_requests.ARGUMENT19%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT19);
  else
     return(NULL);
  end if;

end get_ARGUMENT19;


--
-- FUNCTION
--   get_ARGUMENT20
--
-- Purpose
--   get ARGUMENT20 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT20(request_id in number) return fnd_concurrent_requests.ARGUMENT20%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT20);
  else
     return(NULL);
  end if;

end get_ARGUMENT20;


--
-- FUNCTION
--   get_ARGUMENT21
--
-- Purpose
--   get ARGUMENT21 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT21(request_id in number) return fnd_concurrent_requests.ARGUMENT21%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT21);
  else
     return(NULL);
  end if;

end get_ARGUMENT21;


--
-- FUNCTION
--   get_ARGUMENT22
--
-- Purpose
--   get ARGUMENT22 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT22(request_id in number) return fnd_concurrent_requests.ARGUMENT22%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT22);
  else
     return(NULL);
  end if;

end get_ARGUMENT22;


--
-- FUNCTION
--   get_ARGUMENT23
--
-- Purpose
--   get ARGUMENT23 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT23(request_id in number) return fnd_concurrent_requests.ARGUMENT23%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT23);
  else
     return(NULL);
  end if;

end get_ARGUMENT23;


--
-- FUNCTION
--   get_ARGUMENT24
--
-- Purpose
--   get ARGUMENT24 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT24(request_id in number) return fnd_concurrent_requests.ARGUMENT24%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT24);
  else
     return(NULL);
  end if;

end get_ARGUMENT24;


--
-- FUNCTION
--   get_ARGUMENT25
--
-- Purpose
--   get ARGUMENT25 of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ARGUMENT25(request_id in number) return fnd_concurrent_requests.ARGUMENT25%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ARGUMENT25);
  else
     return(NULL);
  end if;

end get_ARGUMENT25;


--
-- FUNCTION
--   get_CRM_THRSHLD
--
-- Purpose
--   get CRM_THRSHLD of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CRM_THRSHLD(request_id in number) return fnd_concurrent_requests.CRM_THRSHLD%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CRM_THRSHLD);
  else
     return(NULL);
  end if;

end get_CRM_THRSHLD;


--
-- FUNCTION
--   get_CRM_TSTMP
--
-- Purpose
--   get CRM_TSTMP of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CRM_TSTMP(request_id in number) return fnd_concurrent_requests.CRM_TSTMP%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CRM_TSTMP);
  else
     return(NULL);
  end if;

end get_CRM_TSTMP;


--
-- FUNCTION
--   get_CRITICAL
--
-- Purpose
--   get CRITICAL of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CRITICAL(request_id in number) return fnd_concurrent_requests.CRITICAL%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CRITICAL);
  else
     return(NULL);
  end if;

end get_CRITICAL;


--
-- FUNCTION
--   get_REQUEST_TYPE
--
-- Purpose
--   get REQUEST_TYPE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_REQUEST_TYPE(request_id in number) return fnd_concurrent_requests.REQUEST_TYPE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.REQUEST_TYPE);
  else
     return(NULL);
  end if;

end get_REQUEST_TYPE;


--
-- FUNCTION
--   get_ORACLE_PROCESS_ID
--
-- Purpose
--   get ORACLE_PROCESS_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ORACLE_PROCESS_ID(request_id in number) return fnd_concurrent_requests.ORACLE_PROCESS_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ORACLE_PROCESS_ID);
  else
     return(NULL);
  end if;

end get_ORACLE_PROCESS_ID;


--
-- FUNCTION
--   get_ORACLE_SESSION_ID
--
-- Purpose
--   get ORACLE_SESSION_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ORACLE_SESSION_ID(request_id in number) return fnd_concurrent_requests.ORACLE_SESSION_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ORACLE_SESSION_ID);
  else
     return(NULL);
  end if;

end get_ORACLE_SESSION_ID;


--
-- FUNCTION
--   get_OS_PROCESS_ID
--
-- Purpose
--   get OS_PROCESS_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_OS_PROCESS_ID(request_id in number) return fnd_concurrent_requests.OS_PROCESS_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.OS_PROCESS_ID);
  else
     return(NULL);
  end if;

end get_OS_PROCESS_ID;


--
-- FUNCTION
--   get_PRINT_JOB_ID
--
-- Purpose
--   get PRINT_JOB_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PRINT_JOB_ID(request_id in number) return fnd_concurrent_requests.PRINT_JOB_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PRINT_JOB_ID);
  else
     return(NULL);
  end if;

end get_PRINT_JOB_ID;


--
-- FUNCTION
--   get_OUTPUT_FILE_TYPE
--
-- Purpose
--   get OUTPUT_FILE_TYPE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_OUTPUT_FILE_TYPE(request_id in number) return fnd_concurrent_requests.OUTPUT_FILE_TYPE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.OUTPUT_FILE_TYPE);
  else
     return(NULL);
  end if;

end get_OUTPUT_FILE_TYPE;


--
-- FUNCTION
--   get_RELEASE_CLASS_APP_ID
--
-- Purpose
--   get RELEASE_CLASS_APP_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RELEASE_CLASS_APP_ID(request_id in number) return fnd_concurrent_requests.RELEASE_CLASS_APP_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RELEASE_CLASS_APP_ID);
  else
     return(NULL);
  end if;

end get_RELEASE_CLASS_APP_ID;


--
-- FUNCTION
--   get_RELEASE_CLASS_ID
--
-- Purpose
--   get RELEASE_CLASS_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RELEASE_CLASS_ID(request_id in number) return fnd_concurrent_requests.RELEASE_CLASS_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RELEASE_CLASS_ID);
  else
     return(NULL);
  end if;

end get_RELEASE_CLASS_ID;


--
-- FUNCTION
--   get_STALE_DATE
--
-- Purpose
--   get STALE_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_STALE_DATE(request_id in number) return fnd_concurrent_requests.STALE_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.STALE_DATE);
  else
     return(NULL);
  end if;

end get_STALE_DATE;


--
-- FUNCTION
--   get_CANCEL_OR_HOLD
--
-- Purpose
--   get CANCEL_OR_HOLD of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CANCEL_OR_HOLD(request_id in number) return fnd_concurrent_requests.CANCEL_OR_HOLD%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CANCEL_OR_HOLD);
  else
     return(NULL);
  end if;

end get_CANCEL_OR_HOLD;


--
-- FUNCTION
--   get_NOTIFY_ON_PP_ERROR
--
-- Purpose
--   get NOTIFY_ON_PP_ERROR of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_NOTIFY_ON_PP_ERROR(request_id in number) return fnd_concurrent_requests.NOTIFY_ON_PP_ERROR%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.NOTIFY_ON_PP_ERROR);
  else
     return(NULL);
  end if;

end get_NOTIFY_ON_PP_ERROR;


--
-- FUNCTION
--   get_CD_ID
--
-- Purpose
--   get CD_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CD_ID(request_id in number) return fnd_concurrent_requests.CD_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CD_ID);
  else
     return(NULL);
  end if;

end get_CD_ID;


--
-- FUNCTION
--   get_REQUEST_LIMIT
--
-- Purpose
--   get REQUEST_LIMIT of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_REQUEST_LIMIT(request_id in number) return fnd_concurrent_requests.REQUEST_LIMIT%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.REQUEST_LIMIT);
  else
     return(NULL);
  end if;

end get_REQUEST_LIMIT;


--
-- FUNCTION
--   get_CRM_RELEASE_DATE
--
-- Purpose
--   get CRM_RELEASE_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_CRM_RELEASE_DATE(request_id in number) return fnd_concurrent_requests.CRM_RELEASE_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.CRM_RELEASE_DATE);
  else
     return(NULL);
  end if;

end get_CRM_RELEASE_DATE;


--
-- FUNCTION
--   get_POST_REQUEST_STATUS
--
-- Purpose
--   get POST_REQUEST_STATUS of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_POST_REQUEST_STATUS(request_id in number) return fnd_concurrent_requests.POST_REQUEST_STATUS%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.POST_REQUEST_STATUS);
  else
     return(NULL);
  end if;

end get_POST_REQUEST_STATUS;


--
-- FUNCTION
--   get_COMPLETION_CODE
--
-- Purpose
--   get COMPLETION_CODE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_COMPLETION_CODE(request_id in number) return fnd_concurrent_requests.COMPLETION_CODE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.COMPLETION_CODE);
  else
     return(NULL);
  end if;

end get_COMPLETION_CODE;


--
-- FUNCTION
--   get_INCREMENT_DATES
--
-- Purpose
--   get INCREMENT_DATES of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_INCREMENT_DATES(request_id in number) return fnd_concurrent_requests.INCREMENT_DATES%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.INCREMENT_DATES);
  else
     return(NULL);
  end if;

end get_INCREMENT_DATES;


--
-- FUNCTION
--   get_RESTART
--
-- Purpose
--   get RESTART of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESTART(request_id in number) return fnd_concurrent_requests.RESTART%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESTART);
  else
     return(NULL);
  end if;

end get_RESTART;


--
-- FUNCTION
--   get_ENABLE_TRACE
--
-- Purpose
--   get ENABLE_TRACE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ENABLE_TRACE(request_id in number) return fnd_concurrent_requests.ENABLE_TRACE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ENABLE_TRACE);
  else
     return(NULL);
  end if;

end get_ENABLE_TRACE;


--
-- FUNCTION
--   get_RESUB_COUNT
--
-- Purpose
--   get RESUB_COUNT of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESUB_COUNT(request_id in number) return fnd_concurrent_requests.RESUB_COUNT%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESUB_COUNT);
  else
     return(NULL);
  end if;

end get_RESUB_COUNT;


--
-- FUNCTION
--   get_NLS_CODESET
--
-- Purpose
--   get NLS_CODESET of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_NLS_CODESET(request_id in number) return fnd_concurrent_requests.NLS_CODESET%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.NLS_CODESET);
  else
     return(NULL);
  end if;

end get_NLS_CODESET;


--
-- FUNCTION
--   get_OFILE_SIZE
--
-- Purpose
--   get OFILE_SIZE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_OFILE_SIZE(request_id in number) return fnd_concurrent_requests.OFILE_SIZE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.OFILE_SIZE);
  else
     return(NULL);
  end if;

end get_OFILE_SIZE;


--
-- FUNCTION
--   get_LFILE_SIZE
--
-- Purpose
--   get LFILE_SIZE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_LFILE_SIZE(request_id in number) return fnd_concurrent_requests.LFILE_SIZE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.LFILE_SIZE);
  else
     return(NULL);
  end if;

end get_LFILE_SIZE;


--
-- FUNCTION
--   get_STALE
--
-- Purpose
--   get STALE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_STALE(request_id in number) return fnd_concurrent_requests.STALE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.STALE);
  else
     return(NULL);
  end if;

end get_STALE;


--
-- FUNCTION
--   get_SECURITY_GROUP_ID
--
-- Purpose
--   get SECURITY_GROUP_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_SECURITY_GROUP_ID(request_id in number) return fnd_concurrent_requests.SECURITY_GROUP_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.SECURITY_GROUP_ID);
  else
     return(NULL);
  end if;

end get_SECURITY_GROUP_ID;


--
-- FUNCTION
--   get_RESOURCE_CONSUMER_GROUP
--
-- Purpose
--   get RESOURCE_CONSUMER_GROUP of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_RESOURCE_CONSUMER_GROUP(request_id in number) return fnd_concurrent_requests.RESOURCE_CONSUMER_GROUP%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.RESOURCE_CONSUMER_GROUP);
  else
     return(NULL);
  end if;

end get_RESOURCE_CONSUMER_GROUP;


--
-- FUNCTION
--   get_EXP_DATE
--
-- Purpose
--   get EXP_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_EXP_DATE(request_id in number) return fnd_concurrent_requests.EXP_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.EXP_DATE);
  else
     return(NULL);
  end if;

end get_EXP_DATE;


--
-- FUNCTION
--   get_QUEUE_APP_ID
--
-- Purpose
--   get QUEUE_APP_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_QUEUE_APP_ID(request_id in number) return fnd_concurrent_requests.QUEUE_APP_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.QUEUE_APP_ID);
  else
     return(NULL);
  end if;

end get_QUEUE_APP_ID;


--
-- FUNCTION
--   get_QUEUE_ID
--
-- Purpose
--   get QUEUE_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_QUEUE_ID(request_id in number) return fnd_concurrent_requests.QUEUE_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.QUEUE_ID);
  else
     return(NULL);
  end if;

end get_QUEUE_ID;


--
-- FUNCTION
--   get_OPS_INSTANCE
--
-- Purpose
--   get OPS_INSTANCE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_OPS_INSTANCE(request_id in number) return fnd_concurrent_requests.OPS_INSTANCE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.OPS_INSTANCE);
  else
     return(NULL);
  end if;

end get_OPS_INSTANCE;


--
-- FUNCTION
--   get_INTERIM_STATUS_CODE
--
-- Purpose
--   get INTERIM_STATUS_CODE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_INTERIM_STATUS_CODE(request_id in number) return fnd_concurrent_requests.INTERIM_STATUS_CODE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.INTERIM_STATUS_CODE);
  else
     return(NULL);
  end if;

end get_INTERIM_STATUS_CODE;


--
-- FUNCTION
--   get_ROOT_REQUEST_ID
--
-- Purpose
--   get ROOT_REQUEST_ID of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ROOT_REQUEST_ID(request_id in number) return fnd_concurrent_requests.ROOT_REQUEST_ID%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ROOT_REQUEST_ID);
  else
     return(NULL);
  end if;

end get_ROOT_REQUEST_ID;


--
-- FUNCTION
--   get_ORIGIN
--
-- Purpose
--   get ORIGIN of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_ORIGIN(request_id in number) return fnd_concurrent_requests.ORIGIN%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.ORIGIN);
  else
     return(NULL);
  end if;

end get_ORIGIN;


--
-- FUNCTION
--   get_NLS_NUMERIC_CHARACTERS
--
-- Purpose
--   get NLS_NUMERIC_CHARACTERS of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_NLS_NUMERIC_CHARACTERS(request_id in number) return fnd_concurrent_requests.NLS_NUMERIC_CHARACTERS%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.NLS_NUMERIC_CHARACTERS);
  else
     return(NULL);
  end if;

end get_NLS_NUMERIC_CHARACTERS;


--
-- FUNCTION
--   get_PP_START_DATE
--
-- Purpose
--   get PP_START_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PP_START_DATE(request_id in number) return fnd_concurrent_requests.PP_START_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PP_START_DATE);
  else
     return(NULL);
  end if;

end get_PP_START_DATE;


--
-- FUNCTION
--   get_PP_END_DATE
--
-- Purpose
--   get PP_END_DATE of a request based on request_id
--   if request_id is not given, obtain from fnd_global
--
-- Note
--   returns NULL on failure
--
function get_PP_END_DATE(request_id in number) return fnd_concurrent_requests.PP_END_DATE%TYPE is
v_status	boolean;

begin
  v_status := get_all_req_detail_reqid(request_id);
  if (v_status = TRUE) then
     return(request_rec.PP_END_DATE);
  else
     return(NULL);
  end if;

end get_PP_END_DATE;


end FND_CONC_REQ_DETAIL;

/
