--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_VIEW_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_VIEW_MESSAGE" AS
/* $Header: hriovmsg.pkb 120.2 2005/10/25 07:16:45 jtitmas noship $ */

FUNCTION get_not_used_msg RETURN VARCHAR2 IS
BEGIN
  RETURN REPLACE(fnd_message.get_string('HRI','HRI_NOT_USED'),'''','''''');
END get_not_used_msg;

FUNCTION get_unassigned_msg RETURN VARCHAR2 IS
BEGIN
  RETURN REPLACE(fnd_message.get_string('BIS','BIS_UNASSIGNED'),'''','''''');
END get_unassigned_msg;


FUNCTION get_direct_reports_msg RETURN VARCHAR2 IS
BEGIN
  RETURN REPLACE(fnd_message.get_string('BIS','BIS_PMF_DIRECT_REP'),'''','''''');
END get_direct_reports_msg;


FUNCTION get_others_msg RETURN VARCHAR2 IS
BEGIN
  RETURN REPLACE(fnd_message.get_string('HRI','HR_BIS_OTHERS'),'''','''''');
END get_others_msg;

FUNCTION get_notapplicable_msg RETURN VARCHAR2 IS
BEGIN
  RETURN REPLACE(fnd_message.get_string('HRI','HR_BIS_NOT_APPLICABLE'),'''','''''');
END get_notapplicable_msg;

FUNCTION get_notrated_msg RETURN VARCHAR2 IS
BEGIN
  RETURN REPLACE(fnd_message.get_string('HRI','HR_BIS_NOT_RATED'),'''','''''');
END get_notrated_msg;

FUNCTION get_all_msg RETURN VARCHAR2 IS
BEGIN
  RETURN REPLACE(fnd_message.get_string('BIS','BIS_ALL'),'''','''''');
END get_all_msg;

-- Returns a message string with no token substitution
FUNCTION get_message(p_msg_name  IN VARCHAR2,
                     p_app_name  IN VARCHAR2)
     RETURN VARCHAR2 IS

  l_msg     VARCHAR2(32000);

BEGIN

  l_msg := fnd_message.get_string
            (appin  => p_app_name,
             namein => p_msg_name);

  -- Trim blanks and returns
  l_msg := TRIM(both ' ' FROM l_msg);
  l_msg := TRIM(both fnd_global.local_chr(10) FROM l_msg);

  RETURN l_msg;

END get_message;

-- Returns a message string with no token substitution
FUNCTION get_message(p_msg_name  IN VARCHAR2)
     RETURN VARCHAR2 IS

  l_msg     VARCHAR2(32000);

BEGIN

  l_msg := get_message
            (p_msg_name => p_msg_name,
             p_app_name => 'HRI');

  RETURN l_msg;

END get_message;

--
END hri_oltp_view_message;

/
