--------------------------------------------------------
--  DDL for Package PON_PROFILE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_PROFILE_UTIL_PKG" AUTHID CURRENT_USER as
/*$Header: PONPRUTS.pls 120.4 2006/03/31 05:49:23 rpatel noship $ */

--This ref cursor type is used for any cursors we need to pass out
--to Java.  Namely addresses and all the subset preference stuff:
--payment methods, credit card types, payment terms, carrier,
--freight terms, fob.
type refCurTyp is Ref Cursor;
HZ_FAIL_EXCEPTION EXCEPTION;

OWNER_TABLE_NAME CONSTANT HZ_CODE_ASSIGNMENTS.OWNER_TABLE_NAME%TYPE := 'HZ_PARTIES';
PON_CLASSIFICATION CONSTANT HZ_CODE_ASSIGNMENTS.CLASS_CATEGORY%TYPE := 'PON_CLASSIFICATION';
TRADING_PARTNER CONSTANT HZ_CODE_ASSIGNMENTS.CLASS_CODE%TYPE := 'TRADING_PARTNER';
TRADING_PARTNER_USER CONSTANT HZ_CODE_ASSIGNMENTS.CLASS_CODE%TYPE := 'TRADING_PARTNER_USER';
PRIMARY_FLAG CONSTANT HZ_CODE_ASSIGNMENTS.PRIMARY_FLAG%TYPE := 'Y';
CONTENT_SOURCE_TYPE CONSTANT HZ_CODE_ASSIGNMENTS.CONTENT_SOURCE_TYPE%TYPE := 'USER_ENTERED';
APPLICATION_ID CONSTANT HZ_CODE_ASSIGNMENTS.APPLICATION_ID%TYPE := 396;
CREATED_BY_MODULE CONSTANT HZ_CODE_ASSIGNMENTS.CREATED_BY_MODULE%TYPE := 'PON';
OBJECT_VERSION_NUMBER CONSTANT HZ_CODE_ASSIGNMENTS.OBJECT_VERSION_NUMBER%TYPE := 0;
ACTIVE_STATUS CONSTANT HZ_CODE_ASSIGNMENTS.STATUS%TYPE := 'A';

PROCEDURE update_organization_start_date(
  p_party_id IN NUMBER
, x_status	OUT NOCOPY VARCHAR2
, x_exception_msg	OUT NOCOPY VARCHAR2
);

FUNCTION get_update_date_from_party (
  p_party_id IN NUMBER
) RETURN DATE;

FUNCTION get_update_date_from_location (
  p_location_id IN NUMBER
) RETURN DATE;

FUNCTION get_update_date_from_contact (
  p_contact_id IN NUMBER
) RETURN DATE;

PROCEDURE update_ins_party_pref_cover(
  p_party_id          in NUMBER
, p_app_short_name    in VARCHAR2
, p_pref_name         in VARCHAR2
, p_pref_value        in VARCHAR2 DEFAULT NULL
, p_pref_meaning      in VARCHAR2 DEFAULT NULL
, x_status            out nocopy VARCHAR2
, x_exception_msg     out nocopy VARCHAR2
);

PROCEDURE UPDATE_OR_INSERT_PARTY_PREF(
  p_party_id          in NUMBER
, p_app_short_name    in VARCHAR2
, p_pref_name         in VARCHAR2
, p_pref_value        in VARCHAR2    DEFAULT NULL
, p_pref_meaning        in VARCHAR2 DEFAULT NULL
, p_attribute1        in VARCHAR2 DEFAULT NULL
, p_attribute2        in VARCHAR2 DEFAULT NULL
, p_attribute3        in VARCHAR2 DEFAULT NULL
, p_attribute4        in VARCHAR2 DEFAULT NULL
, p_attribute5        in VARCHAR2 DEFAULT NULL
, x_status            out nocopy VARCHAR2
, x_exception_msg     out nocopy VARCHAR2
);

PROCEDURE DELETE_PARTY_PREF(
  p_party_id          in NUMBER
, p_app_short_name    in VARCHAR2
, p_pref_name         in VARCHAR2
, x_status            out nocopy VARCHAR2
, x_exception_msg     out nocopy VARCHAR2
);

PROCEDURE retrieve_party_pref_cover(
  p_party_id          IN NUMBER
, p_app_short_name    IN VARCHAR2
, p_pref_name         IN VARCHAR2
, x_pref_value        OUT NOCOPY VARCHAR2
, x_pref_meaning      OUT NOCOPY VARCHAR2
, x_status            OUT NOCOPY VARCHAR2
, x_exception_msg     OUT NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_PARTY_PREFERENCE(
  p_party_id          in NUMBER
, p_app_short_name    in VARCHAR2
, p_pref_name         in VARCHAR2
, x_pref_value        out nocopy VARCHAR2
, x_pref_meaning      out nocopy VARCHAR2
, x_attribute1        out nocopy VARCHAR2
, x_attribute2        out nocopy VARCHAR2
, x_attribute3        out nocopy VARCHAR2
, x_attribute4        out nocopy VARCHAR2
, x_attribute5        out nocopy VARCHAR2
, x_status            out nocopy VARCHAR2
, x_exception_msg     out nocopy VARCHAR2
);

PROCEDURE GET_PARTY_URL(
  party_id IN NUMBER
, url OUT NOCOPY VARCHAR2
, x_status OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
);

PROCEDURE GET_PARTY_SLOGAN(
  party_id IN NUMBER
, slogan OUT NOCOPY VARCHAR2
, x_status OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
);

PROCEDURE GET_PARTY_PORT(
  party_id IN NUMBER
, port OUT NOCOPY VARCHAR2
, x_status OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
);


PROCEDURE SET_WF_LANGUAGE(
  p_user_name IN VARCHAR2,
  p_language_code IN VARCHAR2
);

PROCEDURE GET_WF_LANGUAGE(
  p_user_name IN VARCHAR2,
  x_language_code OUT NOCOPY VARCHAR2
);

PROCEDURE GET_WF_LANGUAGE(
  p_user_id IN NUMBER,
  x_language_code OUT NOCOPY VARCHAR2
);

PROCEDURE SET_WF_TERRITORY(
  p_user_name IN VARCHAR2,
  p_territory_code IN VARCHAR2
);

PROCEDURE GET_WF_TERRITORY(
  p_user_name IN VARCHAR2,
  x_territory_code OUT NOCOPY VARCHAR2
);

PROCEDURE SET_WF_PREFERENCES(
  p_user_name IN VARCHAR2,
  p_language_code IN VARCHAR2,
  p_territory_code IN VARCHAR2
);

PROCEDURE GET_WF_PREFERENCES(
  p_user_name IN VARCHAR2,
  x_language_code OUT NOCOPY VARCHAR2,
  x_territory_code OUT NOCOPY VARCHAR2
);


--
-- GET_STRING- get a particular translated message
--             from the message dictionary database.
--   This is a one-call interface for when you just want to get a
--   message without doing any token substitution.
--   Returns NAMEIN (Msg name)  if the message cannot be found.
FUNCTION get_string(appin IN VARCHAR2,
		    namein IN VARCHAR2,
		    langin IN VARCHAR2) RETURN VARCHAR2;

FUNCTION SET_PRINT_OPTIONS RETURN VARCHAR2;

FUNCTION SAVE_PROFILE_OPTION(p_option_name IN VARCHAR2,
			     p_option_value IN VARCHAR2,
			     p_level_name IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE LINES_MORE_THAN_THRESHOLD(
        p_number_of_lines IN NUMBER,
        p_party_id IN NUMBER,
        x_is_super_large_neg OUT NOCOPY VARCHAR2);


END PON_PROFILE_UTIL_PKG;

 

/
