--------------------------------------------------------
--  DDL for Package Body AMW_SIGNIFICANT_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_SIGNIFICANT_ELEMENTS_PKG" as
/* $Header: amwvsigb.pls 120.0 2005/05/31 22:13:47 appldev noship $ */


-- ===============================================================
-- Package name
--          AMW_SIGNIFICANT_ELEMENTS_PKG
-- Purpose
--
-- History
-- 		  	12/18/2003    tsho     Creates
-- ===============================================================



-- ===============================================================
-- Function name
--          ELEMENT_PRESENT
-- Purpose
-- 		  	return 'Y' if there's element for the specified object_id;
--          return 'N' otherwise.
-- ===============================================================
FUNCTION ELEMENT_PRESENT (
    P_OBJECT_ID IN NUMBER,
    P_OBJECT_TYPE IN VARCHAR2,
    P_ELEMENT_CODE IN VARCHAR2
) RETURN VARCHAR2
IS

n     number;

BEGIN
   select count(*)
   into n
   from AMW_SIGNIFICANT_ELEMENTS
   where pk1 = P_OBJECT_ID
   and   object_type = P_OBJECT_TYPE
   and   element_code = P_ELEMENT_CODE;

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;

END   ELEMENT_PRESENT;



-- ===============================================================
-- Procedure name
--          PROCESS_ELEMENTS
-- Purpose
-- 		  	update the elements for specified object_id
-- Notes
--          OBJECT_TYPE = 'PROCESS' with PK1 = PROCESS_REV_ID
--          OBJECT_TYPE = 'PROCESS_ORG' with PK1 = PROCESS_ORGANIZATION_ID
-- ===============================================================
PROCEDURE PROCESS_ELEMENTS (
    p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
    p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
    p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
    p_select_flag         IN         VARCHAR2,
    p_object_id           IN         NUMBER,
    p_object_type         IN         VARCHAR2,
    p_element_code        IN         VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
)
IS

l_creation_date         date;
l_created_by            number;
l_last_update_date      date;
l_last_updated_by       number;
l_last_update_login     number;
l_significant_element_id  number;
l_object_version_number number;

BEGIN

  -- create savepoint if p_commit is true
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT PROCESS_ELEMENTS_SAVE;
  END IF;

  -- initialize message list if p_init_msg_list is set to true
  if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
    fnd_msg_pub.initialize;
  end if;

  -- initialize return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  delete from AMW_SIGNIFICANT_ELEMENTS
  where pk1 = p_object_id
  and   object_type = p_object_type
  and   element_code = p_element_code;

  if (p_select_flag = 'Y') then
    l_creation_date := SYSDATE;
    l_created_by := FND_GLOBAL.USER_ID;
    l_last_update_date := SYSDATE;
    l_last_updated_by := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.USER_ID;
    l_object_version_number := 1;

    select AMW_SIGNIFICANT_ELEMENT_S.nextval into l_significant_element_id from dual;

    insert into AMW_SIGNIFICANT_ELEMENTS (
        significant_element_id,
        object_type,
        pk1,
        element_code,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        object_version_number
    ) values (
        l_significant_element_id,
        p_object_type,
        p_object_id,
        p_element_code,
        l_creation_date,
        l_created_by,
        l_last_update_date,
        l_last_updated_by,
        l_last_update_login,
        l_object_version_number
    );

  end if;

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.to_Boolean( p_commit ) THEN
        ROLLBACK TO PROCESS_ELEMENTS_SAVE;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_count  =>   x_msg_count,
                                p_data   =>   x_msg_data);
    WHEN OTHERS THEN
      IF FND_API.to_Boolean( p_commit ) THEN
        ROLLBACK TO PROCESS_ELEMENTS_SAVE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_SIGNIFICANT_ELEMENTS_PKG',
                              p_procedure_name =>    'PROCESS_ELEMENTS',
                              p_error_text     =>     SUBSTRB(SQLERRM,1,240));

      fnd_msg_pub.count_and_get(p_count  =>   x_msg_count,
                                p_data   =>   x_msg_data);

END PROCESS_ELEMENTS;


-- ===============================================================
-- Function name
--          ELEMENT_PRESENT_IN_LATEST
-- Purpose
-- 	    return 'Y' if there's element for the specified object_id;
--          return 'N' otherwise.
-- Created  nirmakum
-- Reason   AMW.D, for knowing if there is a latest association of a significant element
--                 to a process
-- ===============================================================

FUNCTION ELEMENT_PRESENT_IN_LATEST (
    P_OBJECT_ID IN NUMBER,
    P_OBJECT_TYPE IN VARCHAR2,
    P_ELEMENT_CODE IN VARCHAR2
    ) RETURN VARCHAR2
IS
n pls_integer;
BEGIN
  select 1 into n
  from AMW_SIGNIFICANT_ELEMENTS
  where pk1 = P_OBJECT_ID
  and object_type = P_OBJECT_TYPE
  and element_code = P_ELEMENT_CODE
  and deletion_date is null;

  return 'Y';
exception
    when no_data_found then
        return 'N';
    when too_many_rows then
        return 'Y';
end ELEMENT_PRESENT_IN_LATEST;


-- ----------------------------------------------------------------------

FUNCTION ELEMENT_PRESENT_IN_REVISION (
    P_OBJECT_ID IN NUMBER,
    P_OBJECT_TYPE IN VARCHAR2,
    P_ELEMENT_CODE IN VARCHAR2
    ) RETURN VARCHAR2
IS
n pls_integer;
BEGIN
  select 1 into n
  from AMW_SIGNIFICANT_ELEMENTS ASE,
  AMW_PROCESS AP
  where AP.process_rev_id = P_OBJECT_ID
  and ASE.pk1 = AP.PROCESS_ID
  and ASE.object_type = P_OBJECT_TYPE
  and ASE.element_code = P_ELEMENT_CODE
--  and ASE.approval_date <= AP.approval_end_date
  and (ASE.deletion_approval_date IS NULL OR ASE.deletion_approval_date > AP.approval_end_date)
  and (ASE.approval_date <= AP.approval_end_date OR AP.approval_end_date is null);



  return 'Y';
exception
    when no_data_found then
        return 'N';
    when too_many_rows then
        return 'Y';
end ELEMENT_PRESENT_IN_REVISION;

END AMW_SIGNIFICANT_ELEMENTS_PKG;

/
