--------------------------------------------------------
--  DDL for Package Body PER_ORG_BGT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ORG_BGT_PKG" AS
/* $Header: pebgt02t.pkb 115.0 99/07/17 18:47:10 porting ship $ */
--
-- PROCEDURE GET_MANAGERS: Populate No of managers, manager name and
-- managers employee number within the control block.
-- If no managers then manager name reflects this.
-- If more than one then manager name also reflects this.
-- else if only one manager then the name and emp no is provided.
--
procedure get_managers(X_ORGANIZATION_ID   Number,
                       X_BUSINESS_GROUP_ID Number,
                       X_NO_OF_MANAGERS    IN OUT VARCHAR2,
                       X_MANAGER_NAME      IN OUT VARCHAR2,
                       X_MANAGER_EMP_NO    IN OUT VARCHAR2) is
--
l_real_manager_name	varchar2 (240);
--
begin
  --
  hr_utility.set_message('801','HR_ALL_MANAGERS');
  --
  -- Assume more than one manager so set string to "Managers"
  --
  X_MANAGER_NAME := hr_utility.get_message;
  --
  -- Obtain number of managers and concatenate with "Managers"
  -- Get all the data in a single cursor - we have to use group functions for
  -- the manager's name and number, so we use MAX. If the count = 1, the name
  -- and number we get must be the correct ones; if count != 1 we're not
  -- interested in which name and number we'll get, as we discard them anyway.
  -- This approach removes the need for a second cursor to get the name and
  -- number separately. RMF 15.11.94.
  --
  SELECT  COUNT(E.PERSON_ID),
	  '** ' || COUNT(E.PERSON_ID) ||' '|| X_MANAGER_NAME,
	  MAX(E.FULL_NAME),
          MAX(E.EMPLOYEE_NUMBER)
  INTO	  X_NO_OF_MANAGERS,
	  X_MANAGER_NAME,
	  l_real_manager_name,
	  X_MANAGER_EMP_NO
  FROM    PER_ALL_PEOPLE E
  ,       PER_ALL_ASSIGNMENTS A
  WHERE   E.CURRENT_EMPLOYEE_FLAG = 'Y'
  AND     A.PERSON_ID             = E.PERSON_ID
  AND     A.ORGANIZATION_ID       = X_ORGANIZATION_ID
  AND     A.BUSINESS_GROUP_ID     = X_BUSINESS_GROUP_ID
  AND     A.ASSIGNMENT_TYPE       = 'E'
  AND     A.MANAGER_FLAG          = 'Y';
  --
  if X_NO_OF_MANAGERS = 0 then
    -- Set manager name to "No Managers"
    --
    hr_utility.set_message('801','HR_ALL_NO_MANAGERS');
    X_MANAGER_NAME := hr_utility.get_message;
    X_MANAGER_EMP_NO := NULL;
    --
  elsif X_NO_OF_MANAGERS = 1 then
    -- set X_MANAGER_NAME to the manager name retrieved
    --
    X_MANAGER_NAME := l_real_manager_name;
    --
  else
     -- more than one manager, so clear the manager emp no. We've already set
     -- the manager name to "** n Managers **".
     X_MANAGER_EMP_NO := NULL;
  end if;
  --
end get_managers;
--
END PER_ORG_BGT_PKG;

/
