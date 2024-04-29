--------------------------------------------------------
--  DDL for Package Body AMW_SETUP_RISK_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_SETUP_RISK_TYPES_PVT" as
/* $Header: amwvrtpb.pls 120.1 2006/04/17 07:43:39 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_SETUP_RISK_TYPES_PVT
-- Purpose
-- 		  	for handling setup risk type actions
--
-- History
-- 		  	07/14/2004    tsho     Creates
-- ===============================================================


G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'AMW_SETUP_RISK_TYPES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) 	:= 'amwvrtpb.pls';

-- ===============================================================
-- Procedure name
--          Reassign_Risk_Type
-- Purpose
-- 		  	Reassign specified risk type to other parent risk type.
-- ===============================================================
PROCEDURE Reassign_Risk_Type(
    p_setup_risk_type_id         IN   NUMBER,
    p_parent_setup_risk_type_id  IN   NUMBER
)IS
BEGIN
    null;
END Reassign_Risk_Type;


-- ===============================================================
-- Procedure name
--          Delete_Risk_Types
-- Purpose
-- 		  	Delete specified risk type and its descendant.
--          Delete associations records in AMW_COMPLIANCE_ENV_ASSOCS
--          for the specified risk type and its descendant.
-- ===============================================================
PROCEDURE Delete_Risk_Types(
    p_setup_risk_type_id  IN         NUMBER,
    p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
    p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
    p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
)IS
  l_setup_risk_type_id NUMBER;

  -- store the target setup risk types
  l_risk_type_list G_NUMBER_TABLE;

  i NUMBER;

BEGIN
  -- create savepoint if p_commit is true
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT Delete_Risk_Types_Save;
  END IF;

  -- initialize message list if p_init_msg_list is set to true
  if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
    fnd_msg_pub.initialize;
  end if;

  l_setup_risk_type_id := p_setup_risk_type_id;
  l_risk_type_list := GET_ALL_DESCENDANTS(l_setup_risk_type_id);

  IF (l_risk_type_list.FIRST is not NULL) THEN
    FOR i in 0 .. l_risk_type_list.LAST LOOP
      delete from AMW_SETUP_RISK_TYPES_B
      where SETUP_RISK_TYPE_ID = l_risk_type_list(i);
    END LOOP; -- end of for

    FOR i in 0 .. l_risk_type_list.LAST LOOP
      delete from AMW_SETUP_RISK_TYPES_TL
      where SETUP_RISK_TYPE_ID = l_risk_type_list(i)
      and SETUP_RISK_TYPE_ID not in (
        select SETUP_RISK_TYPE_ID from AMW_SETUP_RISK_TYPES_B
      )
      and SETUP_RISK_TYPE_ID not in (
        select PARENT_SETUP_RISK_TYPE_ID from AMW_SETUP_RISK_TYPES_B
        where parent_setup_risk_type_id is not null
      );
    END LOOP; -- end of for

    FOR i in 0 .. l_risk_type_list.LAST LOOP
      delete from AMW_RISK_TYPE
      where RISK_TYPE_CODE = (
        select RISK_TYPE_CODE
        from AMW_SETUP_RISK_TYPES_B
        where SETUP_RISK_TYPE_ID = l_risk_type_list(i)
      );
    END LOOP; -- end of for

  END IF; -- end of if: l_risk_type_list

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO Delete_Risk_Types_Save;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                  p_data    =>   x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO Delete_Risk_Types_Save;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_SETUP_RISK_TYPES_PVT',
                               p_procedure_name =>    'Delete_Risk_Types',
                               p_error_text     =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                 p_data    =>   x_msg_data);

END Delete_Risk_Types;


-- ===============================================================
-- Procedure name
--          InValidate_Risk_Types
-- Purpose
-- 		  	InValidate(End-Date) specified risk type and its descendants.
-- Notes
--          Should update those descendant's end_date to be the same as its end_date
--          if the descendant's end_date is null or end_date is later than its end_date.
--          At any point of time, child's(descendant) end_date cannot be later than
--          parent's end_date.(aka, if parent risk type is invalid, so is all its descendants).
-- ===============================================================
PROCEDURE InValidate_Risk_Types(
    p_setup_risk_type_id  IN         NUMBER,
    p_end_date            IN         DATE,
    p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
    p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
    p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

  l_setup_risk_type_id NUMBER;

  -- store the target setup risk types
  l_risk_type_list G_NUMBER_TABLE;

  i NUMBER;

BEGIN
  -- create savepoint if p_commit is true
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT InValidate_Risk_Types_Save;
  END IF;

  -- initialize message list if p_init_msg_list is set to true
  if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
    fnd_msg_pub.initialize;
  end if;

  -- initialize return status to success
  x_return_status := fnd_api.g_ret_sts_success;


  l_setup_risk_type_id := p_setup_risk_type_id;
  l_risk_type_list := GET_ALL_DESCENDANTS(l_setup_risk_type_id);

  IF (l_risk_type_list.FIRST is not NULL) THEN
    -- update its end_date
    update AMW_SETUP_RISK_TYPES_B
       set END_DATE = p_end_date
     where SETUP_RISK_TYPE_ID = l_risk_type_list(0);

    -- should update those descendant's end_date to be the same as its end_date
    -- if the descendant's end_date is null or end_date is later than its end_date
    FOR i in 1 .. l_risk_type_list.LAST LOOP
      --DBMS_OUTPUT.PUT_LINE(' l_risk_type_list('||i||') = '||l_risk_type_list(i));
      update AMW_SETUP_RISK_TYPES_B
         set END_DATE = p_end_date
       where SETUP_RISK_TYPE_ID = l_risk_type_list(i)
         and (END_DATE IS NULL OR END_DATE > p_end_date);
    END LOOP; -- end of for
  END IF; -- end of if: l_risk_type_list

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO InValidate_Risk_Types_Save;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                  p_data    =>   x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO InValidate_Risk_Types_Save;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_SETUP_RISK_TYPES_PVT',
                               p_procedure_name =>    'InValidate_Risk_Types',
                               p_error_text     =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                 p_data    =>   x_msg_data);

END InValidate_Risk_Types;


-- ===============================================================
-- Function name
--          RISK_TYPE_PRESENT
-- Purpose
-- 		    return non translated character (Y/N) to indicate the
--          selected(associated) Setup Risk Type to specified RiskRevId
-- ===============================================================
FUNCTION RISK_TYPE_PRESENT (
    p_risk_rev_id         IN         NUMBER,
    p_risk_type_code      IN         VARCHAR2
) RETURN VARCHAR2 IS

n     number;
BEGIN
   select count(*)
   into n
   from amw_risk_type
   where risk_rev_id = p_risk_rev_id
   and   risk_type_code = p_risk_type_code;

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
END   RISK_TYPE_PRESENT;


-- ===============================================================
-- Function name
--          RISK_TYPE_PRESENT_MEAN
-- Purpose
-- 		    return translated meaning (Yes/No) to indicate the
--          selected(associated) Setup Risk Type to specified RiskRevId
-- ===============================================================
FUNCTION RISK_TYPE_PRESENT_MEAN (
    p_risk_rev_id         IN         NUMBER,
    p_risk_type_code      IN         VARCHAR2
) RETURN VARCHAR2 IS

n     number;
yes   varchar2(80);
no    varchar2(80);
BEGIN
   select count(*)
   into n
   from amw_risk_type
   where risk_rev_id = p_risk_rev_id
   and   risk_type_code = p_risk_type_code;

   select meaning
   into yes
   from fnd_lookups
   where lookup_type='YES_NO'
   and lookup_code='Y';

   select meaning
   into no
   from fnd_lookups
   where lookup_type='YES_NO'
   and lookup_code='N';

   if n > 0 then
       return yes;
   else
       return no;
   end if;
END   RISK_TYPE_PRESENT_MEAN;


-- ===============================================================
-- Function name
--          IS_SELF_DESCENDANT_ASSOC_TO_RISK
-- Purpose
-- 		    return non translated character (Y/N) to indicate if the
--          Setup Risk Type or at least one of its descendants are
--          associated to specified RiskRevId under specfied compliance
-- ===============================================================
FUNCTION IS_DESCENDANT_ASSOC_TO_RISK (
    p_risk_rev_id         IN         NUMBER,
    p_setup_risk_type_id  IN         NUMBER,
    p_compliance_env_id   IN         NUMBER
) RETURN VARCHAR2 IS

  l_setup_risk_type_id NUMBER;
  l_risk_rev_id NUMBER;
  l_compliance_env_id NUMBER;

  -- store the setup risk types
  l_risk_type_list G_NUMBER_TABLE;

  i NUMBER;
  l_dummy NUMBER;
  isDescendantAssociatedToRisk VARCHAR2(1);

  -- find if specified risk type or any of its descendants are associated with the specified risk_rev_id
  cursor is_assoc_risk_c (l_setup_risk_type_id IN NUMBER, l_risk_rev_id IN NUMBER, l_compliance_env_id IN NUMBER) is
      SELECT assoc.risk_type_id
        from amw_risk_type assoc,
             amw_setup_risk_types_b rt,
             amw_compliance_env_assocs compEnv
       where assoc.risk_rev_id = l_risk_rev_id
         and rt.setup_risk_type_id = l_setup_risk_type_id
         and assoc.risk_type_code = rt.risk_type_code
         and compEnv.object_type = 'SETUP_RISK_TYPE'
         and compEnv.pk1 = l_setup_risk_type_id
         and compEnv.compliance_env_id = l_compliance_env_id;

BEGIN

  isDescendantAssociatedToRisk := 'N';
  l_setup_risk_type_id := p_setup_risk_type_id;
  l_risk_rev_id := p_risk_rev_id;
  l_compliance_env_id := p_compliance_env_id;
  l_risk_type_list := GET_ALL_DESCENDANTS(l_setup_risk_type_id);

  IF (l_risk_type_list.FIRST is not NULL) THEN
    FOR i in 0 .. l_risk_type_list.LAST LOOP
      OPEN is_assoc_risk_c (l_risk_type_list(i), l_risk_rev_id, l_compliance_env_id);
      FETCH is_assoc_risk_c INTO l_dummy;
      CLOSE is_assoc_risk_c;

      IF (l_dummy is not NULL) THEN
        isDescendantAssociatedToRisk := 'Y';
        EXIT;
      END IF;

    END LOOP;
  END IF;

  return isDescendantAssociatedToRisk;

END IS_DESCENDANT_ASSOC_TO_RISK;



-- ===============================================================
-- Procedure name
--          PROCESS_RISK_TYPE_ASSOCS
-- Purpose
-- 		    Update the risk-riskTypes associations(store in table AMW_RISK_TYPE)
--          depending on the specified p_select_flag .
-- ===============================================================
PROCEDURE PROCESS_RISK_TYPE_ASSOCS (
                   p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
                   p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
                   p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
                   p_select_flag         IN         VARCHAR2,
                   p_risk_rev_id         IN         NUMBER,
                   p_risk_type_code      IN         VARCHAR2,
                   x_return_status       OUT NOCOPY VARCHAR2,
                   x_msg_count           OUT NOCOPY NUMBER,
                   x_msg_data            OUT NOCOPY VARCHAR2
)IS

l_creation_date         date;
l_created_by            number;
l_last_update_date      date;
l_last_updated_by       number;
l_last_update_login     number;
l_risk_type_assoc_id    number;
l_object_version_number number;

BEGIN

  -- create savepoint if p_commit is true
     IF p_commit = FND_API.G_TRUE THEN
          SAVEPOINT setup_risk_type_assoc_save;
     END IF;

  -- initialize message list if p_init_msg_list is set to true
     if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
          fnd_msg_pub.initialize;
     end if;

  -- initialize return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     delete from amw_risk_type
     where risk_rev_id = p_risk_rev_id
     and   risk_type_code = p_risk_type_code;

     if (p_select_flag = 'Y') then
          l_creation_date := SYSDATE;
          l_created_by := FND_GLOBAL.USER_ID;
          l_last_update_date := SYSDATE;
          l_last_updated_by := FND_GLOBAL.USER_ID;
          l_last_update_login := FND_GLOBAL.USER_ID;
          l_object_version_number := 1;

          select amw_risk_type_s.nextval into l_risk_type_assoc_id from dual;

          insert into amw_risk_type (risk_type_id,
                                     risk_rev_id,
                                     risk_type_code,
                                     creation_date,
                                     created_by,
                                     last_update_date,
                                     last_updated_by,
                                     last_update_login,
                                     object_version_number)
          values (l_risk_type_assoc_id,
                  p_risk_rev_id,
                  p_risk_type_code,
                  l_creation_date,
                  l_created_by,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login,
                  l_object_version_number);

       end if;
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO setup_risk_type_assoc_save;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                  p_data    =>   x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO setup_risk_type_assoc_save;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_SETUP_RISK_TYPES_PVT',
                               p_procedure_name =>    'PROCESS_RISK_TYPE_ASSOCS',
                               p_error_text     =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                 p_data    =>   x_msg_data);

END PROCESS_RISK_TYPE_ASSOCS;


-- ===============================================================
-- Function name
--          GET_ALL_DESCENDANTS
-- Purpose
-- 		    to get all the descendants of specified risk type
-- ===============================================================
FUNCTION GET_ALL_DESCENDANTS (
    p_setup_risk_type_id         IN         NUMBER
) RETURN G_NUMBER_TABLE IS

  l_setup_risk_type_id NUMBER;

  -- store the target setup risk types
  risk_type_list G_NUMBER_TABLE;
  risk_type_list_cur PLS_INTEGER;
  risk_type_list_size PLS_INTEGER;
  tbl_risk_type_id G_NUMBER_TABLE;

  -- find the direct children of specified setup risk type
  cursor get_child_risk_type_c (l_setup_risk_type_id IN NUMBER) is
      SELECT SETUP_RISK_TYPE_ID
        from amw_setup_risk_types_b
       where PARENT_SETUP_RISK_TYPE_ID  = l_setup_risk_type_id;

  -- find how many direct children of specified setup risk type
  cursor get_child_count_c (l_setup_risk_type_id IN NUMBER) is
      SELECT count(*)
        from amw_setup_risk_types_b
       where PARENT_SETUP_RISK_TYPE_ID  = l_setup_risk_type_id;

  last_index PLS_INTEGER;
  i NUMBER;
  n NUMBER;


BEGIN

  risk_type_list_cur := 0;
  risk_type_list_size := 1;
  risk_type_list(0) := p_setup_risk_type_id;

  WHILE (risk_type_list_cur < risk_type_list_size) LOOP
    l_setup_risk_type_id := risk_type_list(risk_type_list_cur);

    OPEN get_child_risk_type_c (l_setup_risk_type_id);
    FETCH get_child_risk_type_c BULK COLLECT INTO tbl_risk_type_id;
    CLOSE get_child_risk_type_c;

    BEGIN
      -- see if we found out any children
      IF (tbl_risk_type_id.FIRST is NULL) THEN
        last_index := 0;
      ELSE
        last_index := tbl_risk_type_id.LAST;
      END IF;
    EXCEPTION
      WHEN others THEN
        last_index := 0;
    END;


    FOR i in 1 .. last_index LOOP
      risk_type_list(risk_type_list_size) := tbl_risk_type_id(i);
      --DBMS_OUTPUT.PUT_LINE(' put into risk_type_list => '||tbl_risk_type_id(i));
      risk_type_list_size := risk_type_list_size + 1;
    END LOOP; -- end of for: last_index

    -- advance to next risk type on working list
    risk_type_list_cur := risk_type_list_cur + 1;

  END LOOP; -- end of while: risk_type_list_cur

  RETURN risk_type_list;

END GET_ALL_DESCENDANTS;


-- ===============================================================
-- Function name
--          IS_DESCENDANT
-- Purpose
-- 		    return 'Y' if the passed-in p_target_setup_risk_type is the descendants
--          of specified risk type (p_setup_risk_type_id)
-- Notes
--          one is not oneself's descendant
--          aka, if p_target_setup_risk_type_id == p_setup_risk_type_id,
--          the return value is 'N'.
-- ===============================================================
FUNCTION IS_DESCENDANT (
    p_target_setup_risk_type_id  IN         NUMBER,
    p_setup_risk_type_id         IN         NUMBER
) RETURN VARCHAR2 IS

  l_setup_risk_type_id NUMBER;

  -- store the setup risk types
  l_risk_type_list G_NUMBER_TABLE;

  i NUMBER;
  isDescendant VARCHAR2(1);

BEGIN
  isDescendant := 'N';
  l_setup_risk_type_id := p_setup_risk_type_id;
  l_risk_type_list := GET_ALL_DESCENDANTS(l_setup_risk_type_id);

  IF (l_risk_type_list.FIRST is not NULL) THEN
    FOR i in 1 .. l_risk_type_list.LAST LOOP
      IF (l_risk_type_list(i) = p_target_setup_risk_type_id) THEN
        isDescendant := 'Y';
        EXIT;
      END IF;
    END LOOP;
  END IF;

  return isDescendant;

END IS_DESCENDANT;


-- ===============================================================
-- Function name
--          IS_PARENT
-- Purpose
-- 		    return 'Y' if the passed-in p_target_setup_risk_type is the direct parent
--          of specified risk type (p_setup_risk_type_id)
-- ===============================================================
FUNCTION IS_PARENT (
    p_target_setup_risk_type_id  IN         NUMBER,
    p_setup_risk_type_id         IN         NUMBER
) RETURN VARCHAR2
IS
  l_setup_risk_type_id NUMBER;
  l_parent_setup_risk_type_id NUMBER;
  isParent VARCHAR2(1);

  -- find the direct parent of specified setup risk type
  cursor get_parent_risk_type_c (l_setup_risk_type_id IN NUMBER) is
      SELECT PARENT_SETUP_RISK_TYPE_ID
        from amw_setup_risk_types_b
       where SETUP_RISK_TYPE_ID  = l_setup_risk_type_id;

BEGIN
  isParent := 'N';
  l_setup_risk_type_id := p_setup_risk_type_id;

  OPEN get_parent_risk_type_c (l_setup_risk_type_id);
  FETCH get_parent_risk_type_c INTO l_parent_setup_risk_type_id;
  CLOSE get_parent_risk_type_c;

  IF (l_parent_setup_risk_type_id = p_target_setup_risk_type_id)THEN
    isParent := 'Y';
  ELSE
    isParent := 'N';
  END IF;

  return isParent;

END IS_PARENT;




-- ===============================================================
-- Function name
--          CAN_HAVE_CHILD
-- Purpose
-- 		    return non translated character (Y/N) to indicate the
--          specified parent_setup_risk_type can have target setup_risk_type as child.
-- History
--          10/06/2004 tsho: bug 3902475,
--          if p_parent_setup_risk_type_id is the current direct parent of p_target_setup_risk_type_id
--          will return 'N' to prevent current parent shows up in LOV list
-- ===============================================================
FUNCTION CAN_HAVE_CHILD (
    p_target_setup_risk_type_id   IN         NUMBER,
    p_parent_setup_risk_type_id   IN         NUMBER
) RETURN VARCHAR2 IS

  l_setup_risk_type_id NUMBER;
  l_isParent VARCHAR2(1);
  last_index NUMBER;
  canHaveChild VARCHAR2(1);

  -- store the associated compliance env
  compliance_env_list G_NUMBER_TABLE;

  -- find the associated compliance env of specified setup risk type
  cursor get_assoc_env_c (l_setup_risk_type_id IN NUMBER) is
      SELECT COMPLIANCE_ENV_ID
        from amw_compliance_env_assocs
       where OBJECT_TYPE = 'SETUP_RISK_TYPE'
         and PK1 = l_setup_risk_type_id;

BEGIN
    l_setup_risk_type_id := p_target_setup_risk_type_id;
    l_isParent := IS_PARENT (p_target_setup_risk_type_id  => p_parent_setup_risk_type_id,
                             p_setup_risk_type_id         => p_target_setup_risk_type_id);
    canHaveChild := 'Y';

    -- 10/06/2004 tsho: bug 3902475, should return 'N'
    -- if p_parent_setup_risk_type_id is the current direct parent of p_target_setup_risk_type_id
    IF (l_isParent = 'Y' ) THEN
      return 'N';
    END IF;

    -- if parent is the root (can always add child to root)
    IF (p_parent_setup_risk_type_id = -1) THEN
      return 'Y';
    END IF;

    OPEN get_assoc_env_c (l_setup_risk_type_id);
    FETCH get_assoc_env_c BULK COLLECT INTO compliance_env_list;
    CLOSE get_assoc_env_c;

    BEGIN
      -- see if we found out any children
      IF (compliance_env_list.FIRST is NULL) THEN
        last_index := 0;
      ELSE
        last_index := compliance_env_list.LAST;
      END IF;
    EXCEPTION
      WHEN others THEN
        last_index := 0;
    END;


    FOR i in 1 .. last_index LOOP
      -- if the passed-in p_parent_setup_risk_type_id is not yet associated with compliance_env_list(i)
      -- than p_parent_setup_risk_type_id cannot have child p_target_setup_risk_type_id
      IF ('N' = AMW_COMPLIANCE_ENV_ASSOCS_PVT.COMPLIANCE_ENVS_PRESENT(
                            p_compliance_env_id => compliance_env_list(i)
                           ,p_object_type       => 'SETUP_RISK_TYPE'
                           ,p_pk1               => p_parent_setup_risk_type_id)) THEN
        canHaveChild := 'N';
        exit;
      END IF;
    END LOOP;

  return canHaveChild;

END CAN_HAVE_CHILD;


-- ===============================================================
-- Procedure name
--          IS_ASSOC_TO_RISK
-- Purpose
-- 		    x_is_assoc_to_risk is 'Y' if at least ONE of the passed-in
--          p_setup_risk_type and its descendants
--          are currently associated with risks in ame_risk_type table.
-- ===============================================================
PROCEDURE IS_ASSOC_TO_RISK (
    p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
    p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
    p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
    p_setup_risk_type_id  IN         NUMBER,
    x_is_assoc_to_risk    OUT NOCOPY VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

  l_setup_risk_type_id NUMBER;

  -- store the setup risk types
  l_risk_type_list G_NUMBER_TABLE;

  i NUMBER;
  l_dummy NUMBER;
  isAssociatedToRisk VARCHAR2(1);

  -- find if there's associated risk of specified setup risk type
  cursor get_assoc_risk_count_c (l_setup_risk_type_id IN NUMBER) is
      SELECT count(*)
        from amw_risk_type assoc,
             amw_setup_risk_types_b rt
       where rt.setup_risk_type_id = l_setup_risk_type_id
         and assoc.risk_type_code = rt.risk_type_code;

BEGIN
  -- create savepoint if p_commit is true
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT IS_ASSOC_TO_RISK_SAVE;
  END IF;

  -- initialize message list if p_init_msg_list is set to true
  if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
    fnd_msg_pub.initialize;
  end if;

  -- initialize return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  x_is_assoc_to_risk := 'N';
  isAssociatedToRisk := 'N';
  l_setup_risk_type_id := p_setup_risk_type_id;
  l_risk_type_list := GET_ALL_DESCENDANTS(l_setup_risk_type_id);

  IF (l_risk_type_list.FIRST is not NULL) THEN
    FOR i in 0 .. l_risk_type_list.LAST LOOP
      OPEN get_assoc_risk_count_c (l_risk_type_list(i));
      FETCH get_assoc_risk_count_c INTO l_dummy;
      CLOSE get_assoc_risk_count_c;

      IF (l_dummy > 0) THEN
        isAssociatedToRisk := 'Y';
        EXIT;
      END IF;

    END LOOP;
  END IF;

  x_is_assoc_to_risk := isAssociatedToRisk;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO IS_ASSOC_TO_RISK_SAVE;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                  p_data    =>   x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO IS_ASSOC_TO_RISK_SAVE;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_SETUP_RISK_TYPES_PVT',
                               p_procedure_name =>    'Delete_Risk_Types',
                               p_error_text     =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                 p_data    =>   x_msg_data);

END IS_ASSOC_TO_RISK;


-- ----------------------------------------------------------------------

END AMW_SETUP_RISK_TYPES_PVT;

/
