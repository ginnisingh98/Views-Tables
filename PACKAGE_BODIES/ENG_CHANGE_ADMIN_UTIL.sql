--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_ADMIN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_ADMIN_UTIL" AS
/* $Header: ENGADUTB.pls 115.7 2004/02/18 11:33:37 sdarbha ship $ */

FUNCTION check_delete_for_reason (
    p_reason_Code      IN  VARCHAR2) RETURN NUMBER IS

delete_flag NUMBER := 1;

BEGIN
    select 2
    into   delete_flag
    from   dual
    where  exists (select 1
					from eng_engineering_changes
					where reason_code = p_reason_Code
		union all
		select 1 from eng_change_type_reasons
		where reason_code = p_reason_code
			);

    return (delete_flag);

EXCEPTION  WHEN NO_DATA_FOUND THEN
    return (delete_flag);
END;

FUNCTION check_delete_for_priority (
    p_priority_code      IN  VARCHAR2) RETURN NUMBER IS

delete_flag NUMBER := 1;

BEGIN
    select 2
    into   delete_flag
    from   dual
    where  exists (select 1
                    from eng_engineering_changes
                    where priority_code = p_priority_code
                   UNION ALL
                   SELECT 1
                   FROM ENG_CHANGE_TYPE_PRIORITIES
                   WHERE priority_code = p_priority_code);

    return (delete_flag);

EXCEPTION  WHEN NO_DATA_FOUND THEN
    return (delete_flag);
END;

FUNCTION check_delete_for_status (
    p_status_code      IN  NUMBER
    ) RETURN NUMBER IS

delete_flag NUMBER := 1;
CURSOR c_checkseededstatus(cp_status_code VARCHAR2) IS
SELECT 2
FROM ENG_CHANGE_STATUSES
WHERE  SEEDED_FLAG='Y'
AND    STATUS_CODE=cp_status_code;

BEGIN
  OPEN c_checkseededstatus(cp_status_code => p_status_code);
  FETCH c_checkseededstatus into delete_flag;
  CLOSE c_checkseededstatus;
  -- Check for Changes Existent for this status ONLY when if its not
  -- seeded status
  IF delete_flag <> 2 then
    select 2
    into   delete_flag
    from   dual
    where  exists (select 1
                   from eng_engineering_changes eec
                   where eec.status_type = p_status_code);
  END IF;
  return (delete_flag);

EXCEPTION  WHEN NO_DATA_FOUND THEN
    return (delete_flag);
END;


FUNCTION check_delete_for_phase (
    p_status_Code      IN  NUMBER,
    p_change_type_id IN NUMBER
    ) RETURN NUMBER IS

delete_flag NUMBER := 1;

BEGIN
    select 2
    into   delete_flag
    from   dual
    where  exists (select 1
					from eng_engineering_changes
					where status_Code = p_status_Code
					and change_order_type_id =p_change_type_id);

    return (delete_flag);

EXCEPTION  WHEN NO_DATA_FOUND THEN
    return (delete_flag);
END;


FUNCTION check_classifications_delete
 (
     p_classification_id  IN NUMBER
    ) RETURN NUMBER  IS

delete_flag NUMBER := 1;


BEGIN

  -- Check for Changes/Types Existent for this classifaction _id

    select 2
    into   delete_flag
    from   dual
    where  exists (select 1
                   from eng_engineering_changes eec
                   where eec.classification_id = p_classification_id )
		   or
           exists  (select 1
                   from eng_change_type_class_codes ectcc
                   where ectcc.classification_id = p_classification_id )
		    ;

  return (delete_flag);

EXCEPTION  WHEN NO_DATA_FOUND THEN
    return (delete_flag);
END;

END ENG_CHANGE_ADMIN_UTIL;



/
