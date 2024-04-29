--------------------------------------------------------
--  DDL for Package Body AP_WEB_OA_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_OA_PREFERENCES_PKG" AS
/* $Header: apwoapfb.pls 115.7 2002/12/26 10:14:16 srinvenk noship $ */

PROCEDURE ValidateApprover(p_employee_id IN NUMBER,
                           p_approver_name IN OUT NOCOPY VARCHAR2,
                           p_approver_id IN OUT NOCOPY NUMBER,
                           p_return_status OUT NOCOPY VARCHAR2,
                           p_msg_count OUT NOCOPY NUMBER,
                           p_msg_data OUT NOCOPY VARCHAR2)
IS
  -- scratch variable for validate approver
  l_error_message VARCHAR2(2000) := NULL;
BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_OA_PREFERENCES_PKG',
                                   'start ValidateApprover');

  -- Initalize global message table
  fnd_msg_pub.initialize;

  -- Validate approver and get the ID
  AP_WEB_VALIDATE_UTIL.ValidateApprover(p_employee_id,
                           p_approver_name,
			   p_approver_id,
			   l_error_message);

  -- Report error
  IF (l_error_message IS NOT NULL) THEN
    fnd_message.set_encoded(l_error_message);
    fnd_msg_pub.add();
  END IF;

  -- Report the errors
  FND_MSG_PUB.count_and_get(p_count => p_msg_count,
                            p_data  => p_msg_data);
  p_return_status := '';

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_OA_PREFERENCES_PKG',
                                   'end ValidateApprover');

END;


END AP_WEB_OA_PREFERENCES_PKG;

/
