--------------------------------------------------------
--  DDL for Package Body AMW_COMPLIANCE_ENV_ASSOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_COMPLIANCE_ENV_ASSOCS_PVT" as
/* $Header: amwvenvb.pls 120.0 2005/05/31 23:30:18 appldev noship $ */

-- ===============================================================
-- Function name
--          COMPLIANCE_ENVS_PRESENT
-- Purpose
-- 		    return non-translated character (Y/N) to indicate the
--          selected(associated) Compliance Environment
-- History
--          12.09.2004 tsho: bug 3902348 fixed
-- ===============================================================
FUNCTION COMPLIANCE_ENVS_PRESENT (
    p_compliance_env_id   IN         NUMBER,
    p_object_type         IN         VARCHAR2,
    p_pk1                 IN         NUMBER,
    p_pk2                 IN         NUMBER     := NULL,
    p_pk3                 IN         NUMBER     := NULL,
    p_pk4                 IN         NUMBER     := NULL,
    p_pk5                 IN         NUMBER     := NULL
) RETURN VARCHAR2 IS

n     number;
BEGIN
   select count(*)
   into n
   from amw_compliance_env_assocs
   where pk1 = p_pk1
   and   object_type = p_object_type
   and   compliance_env_id = p_compliance_env_id;

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
END   COMPLIANCE_ENVS_PRESENT;


-- ===============================================================
-- Function name
--          COMPLIANCE_ENVS_PRESENT_MEAN
-- Purpose
-- 		    return translated meaning (Yes/No) to indicate the
--          selected(associated) Compliance Environment
-- ===============================================================
FUNCTION COMPLIANCE_ENVS_PRESENT_MEAN (
    p_compliance_env_id   IN         NUMBER,
    p_object_type         IN         VARCHAR2,
    p_pk1                 IN         NUMBER,
    p_pk2                 IN         NUMBER     := NULL,
    p_pk3                 IN         NUMBER     := NULL,
    p_pk4                 IN         NUMBER     := NULL,
    p_pk5                 IN         NUMBER     := NULL
) RETURN VARCHAR2 IS

n     number;
yes   varchar2(80);
no    varchar2(80);
BEGIN
   select count(*)
   into n
   from amw_compliance_env_assocs
   where pk1 = p_pk1
   and   object_type = p_object_type
   and   compliance_env_id = p_compliance_env_id;

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
END   COMPLIANCE_ENVS_PRESENT_MEAN;



-- ===============================================================
-- Function name
--          COMPLIANCE_ENVS_DISABLE
-- Purpose
--          this function is used for OBJECT_TYPE = 'SETUP_RISK_TYPE'.
-- 		    return non translated character (Y/N) to indicate the
--          specified Compliance Environment should be disabled or not
--          for the children of passed-in parent, p_pk1(ie, parent_setup_risk_type_id)
-- ===============================================================
FUNCTION COMPLIANCE_ENVS_DISABLE (
    p_compliance_env_id   IN         NUMBER,
    p_object_type         IN         VARCHAR2, -- 'SETUP_RISK_TYPE'
    p_pk1                 IN         NUMBER, -- parent setup_risk_type_id
    p_object_id           IN         NUMBER     := NULL,  -- setup_risk_type_id
    p_pk2                 IN         NUMBER     := NULL,
    p_pk3                 IN         NUMBER     := NULL,
    p_pk4                 IN         NUMBER     := NULL,
    p_pk5                 IN         NUMBER     := NULL
) RETURN VARCHAR2 IS

  l_disabled     varchar2(1);
  n number;
  m number;
  l_parent_setup_risk_type_id number;
  l_setup_risk_type_id number;

  -- find the parent of specified setup risk type
  cursor get_parent_risk_type_c (l_setup_risk_type_id IN NUMBER) is
      SELECT parent_setup_risk_type_id
        from amw_setup_risk_types_b
       where setup_risk_type_id  = l_setup_risk_type_id;

  -- find out is the parent of specified setup risk type is associated this env already
  cursor is_associated_env_c (l_setup_risk_type_id IN NUMBER) is
      SELECT count(*)
        from amw_compliance_env_assocs
       where pk1 = l_setup_risk_type_id
         and object_type = 'SETUP_RISK_TYPE'
         and compliance_env_id = p_compliance_env_id;

  -- 12.09.2004 tsho: find out is the direct children of specified setup risk type is associated this env already
  cursor is_child_associated_env_c (l_setup_risk_type_id IN NUMBER) is
      SELECT count(*)
        from amw_compliance_env_assocs
       where pk1 in (
               select b.setup_risk_type_id
                 from amw_setup_risk_types_b b
                where b.parent_setup_risk_type_id = l_setup_risk_type_id
             )
         and object_type = 'SETUP_RISK_TYPE'
         and compliance_env_id = p_compliance_env_id;

BEGIN
   l_disabled := 'Y';
   l_parent_setup_risk_type_id := p_pk1;
   l_setup_risk_type_id := p_object_id;

   -- find the parent setup_risk_type
   if (p_object_type = 'SETUP_RISK_TYPE') then
    --BEGIN
      /*
      OPEN get_parent_risk_type_c (p_pk1);
      FETCH get_parent_risk_type_c INTO l_parent_setup_risk_type_id;
      CLOSE get_parent_risk_type_c;
      */

      -- itself is the root
      if (l_parent_setup_risk_type_id is NULL) then
        l_disabled := 'Y';
      else
        -- 12.09.2004 tsho: should disable the checkbox if any of its descendants are already associated with this env
        OPEN is_child_associated_env_c (l_setup_risk_type_id);
        FETCH is_child_associated_env_c INTO m;
        CLOSE is_child_associated_env_c;

        if (m >0) then
          -- its direct children are already associated with this env, disable this env choice for preventing from disassociating
          l_disabled := 'Y';
        else
          -- since its direct children are not yet associated with this env,
          -- can continue check if its parent node is the root node, then itself can associate with this env
          if (l_parent_setup_risk_type_id = -1) then
            l_disabled := 'N';
          else
            OPEN is_associated_env_c (l_parent_setup_risk_type_id);
            FETCH is_associated_env_c INTO n;
            CLOSE is_associated_env_c;

            if (n >0) then
              -- its parent is already associated with this env, thus child can associate with it as well
              l_disabled := 'N';
            else
              -- parent is not yet associated with this env, disable this env choice for child association
              l_disabled := 'Y';
            end if; -- end of if: n >0

          end if; -- end of if :l_parent_setup_risk_type_id = -1
        end if; -- end of if: m >0

      end if; -- end of if: l_parent_setup_risk_type_id is NULL

    /*
    EXCEPTION
    WHEN no_data_found then
      -- no parent found for specified setup_risk_type, itself is the root
      -- root node is not allowed to associate with any env.
      l_disabled := 'Y';
    END;
    */

   end if; --  end of if: p_object_type

   return l_disabled;

END COMPLIANCE_ENVS_DISABLE;





-- ===============================================================
-- Procedure name
--          PROCESS_COMPLIANCE_ENV_ASSOCS
-- Purpose
-- 		    Update the compliance environment associations depending
--          on the specified p_select_flag .
--          The p_pk1 is co-related with p_object_type, for exampel:
--          if p_object_type is SETUP_RISK_TYPE, then
--          p_pk1 is SETUP_RISK_TYPE_ID .
-- ===============================================================
PROCEDURE PROCESS_COMPLIANCE_ENV_ASSOCS (
                   p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
                   p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
                   p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
                   p_select_flag         IN         VARCHAR2,
                   p_compliance_env_id   IN         NUMBER,
                   p_object_type         IN         VARCHAR2,
                   p_pk1                 IN         NUMBER,
                   p_pk2                 IN         NUMBER     := NULL,
                   p_pk3                 IN         NUMBER     := NULL,
                   p_pk4                 IN         NUMBER     := NULL,
                   p_pk5                 IN         NUMBER     := NULL,
                   x_return_status       OUT NOCOPY VARCHAR2,
                   x_msg_count           OUT NOCOPY NUMBER,
                   x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_creation_date         date;
l_created_by            number;
l_last_update_date      date;
l_last_updated_by       number;
l_last_update_login     number;
l_compliance_env_assoc_id  number;
l_object_version_number number;

BEGIN

  -- create savepoint if p_commit is true
     IF p_commit = FND_API.G_TRUE THEN
          SAVEPOINT compliance_env_assocs_save;
     END IF;

  -- initialize message list if p_init_msg_list is set to true
     if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
          fnd_msg_pub.initialize;
     end if;

  -- initialize return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     delete from amw_compliance_env_assocs
     where pk1 = p_pk1
     and   object_type = p_object_type
     and   compliance_env_id = p_compliance_env_id;

     if (p_select_flag = 'Y') then
          l_creation_date := SYSDATE;
          l_created_by := FND_GLOBAL.USER_ID;
          l_last_update_date := SYSDATE;
          l_last_updated_by := FND_GLOBAL.USER_ID;
          l_last_update_login := FND_GLOBAL.USER_ID;
          l_object_version_number := 1;

          select amw_compliance_env_assoc_s.nextval into l_compliance_env_assoc_id from dual;

          insert into amw_compliance_env_assocs (compliance_env_assoc_id,
                                              compliance_env_id,
                                              object_type,
                                              pk1,
                                              pk2,
                                              pk3,
                                              pk4,
                                              pk5,
                                              creation_date,
                                              created_by,
                                              last_update_date,
                                              last_updated_by,
                                              last_update_login,
                                              object_version_number)
          values (l_compliance_env_assoc_id,
                  p_compliance_env_id,
                  p_object_type,
                  p_pk1,
                  p_pk2,
                  p_pk3,
                  p_pk4,
                  p_pk5,
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
              ROLLBACK TO compliance_env_assocs_save;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                  p_data    =>   x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO compliance_env_assocs_save;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_COMPLIANCE_ENV_ASSOCS_PVT',
                               p_procedure_name =>    'PROCESS_COMPLIANCE_ENV_ASSOCS',
                               p_error_text     =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                 p_data    =>   x_msg_data);

END PROCESS_COMPLIANCE_ENV_ASSOCS;


-- ===============================================================
-- Function name
--          COMPLIANCE_ENVS_IN_USE
-- Purpose
-- 		    return non translated character (Y/N) to indicate the
--          selected(associated) Compliance Environment is used for assoication
--          if it's in used, return 'Y', else, return 'N'.
-- Notes
--          don't need to bother which p_object_type it's associated with.
--          as long as it appears in amw_compliance_env_assocs table,
--          the return value will be 'Y'.
-- ===============================================================
FUNCTION COMPLIANCE_ENVS_IN_USE (
    p_compliance_env_id   IN         NUMBER
) RETURN VARCHAR2 IS

n     number;
BEGIN
   select count(*)
   into n
   from amw_compliance_env_assocs
   where compliance_env_id = p_compliance_env_id;

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
END COMPLIANCE_ENVS_IN_USE;


-- ----------------------------------------------------------------------
END AMW_COMPLIANCE_ENV_ASSOCS_PVT;


/
