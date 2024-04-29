--------------------------------------------------------
--  DDL for Package Body AMW_COMPONENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_COMPONENTS_PKG" as
/* $Header: amwvascb.pls 115.6 2004/04/02 01:08:23 npanandi noship $ */

FUNCTION COMPONENTS_PRESENT (
    P_OBJECT_ID IN NUMBER,
    P_OBJECT_TYPE IN VARCHAR2,
    P_COMPONENT_CODE IN VARCHAR2
) RETURN VARCHAR2 IS

n     number;
BEGIN
   -- 11.25.2003: use object_id and object_type instead
   /*
   select count(*)
   into n
   from amw_assessment_components
   where assessment_id = P_ASSESSMENT_ID
   and   component_code = P_COMPONENT_CODE;
   */
   select count(*)
   into n
   from amw_assessment_components
   where object_id = P_OBJECT_ID
   and   object_type = P_OBJECT_TYPE
   and   component_code = P_COMPONENT_CODE;


   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
END   COMPONENTS_PRESENT;


FUNCTION NEW_COMPONENTS_PRESENT (
    P_OBJECT_ID IN NUMBER,
    P_OBJECT_TYPE IN VARCHAR2,
    P_COMPONENT_CODE IN VARCHAR2
) RETURN VARCHAR2 IS

n     number;
yes   varchar2(80);
no    varchar2(80);
BEGIN
   -- 11.25.2003: use object_id and object_type instead
   /*
   select count(*)
   into n
   from amw_assessment_components
   where assessment_id = P_ASSESSMENT_ID
   and   component_code = P_COMPONENT_CODE;
   */
   select count(*)
   into n
   from amw_assessment_components
   where object_id = P_OBJECT_ID
   and   object_type = P_OBJECT_TYPE
   and   component_code = P_COMPONENT_CODE;

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
       ---return 'Y';
       return yes;
   else
       ---return 'N';
       return no;
   end if;
END   NEW_COMPONENTS_PRESENT;


PROCEDURE PROCESS_COMPONENTS (
    p_init_msg_list       IN         VARCHAR2,
    p_commit              IN        VARCHAR2,
    p_validate_only       IN        VARCHAR2,
    p_select_flag         IN         VARCHAR2,
 -- p_assessment_id       IN            NUMBER, -- 11.25.2003 tsho: obseleted, use object_id, object_type instead
    p_object_id           IN         NUMBER,       -- 11.25.2003 tsho: combined with object_type will replace assessment_id
    p_object_type         IN         VARCHAR2,     -- 11.25.2003 tsho: combined with obejct_id will replace assessment_id
    p_component_code      IN          VARCHAR2,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_other_component_value IN       VARCHAR2
) IS

      l_creation_date         date;
      l_created_by            number;
      l_last_update_date      date;
      l_last_updated_by       number;
      l_last_update_login     number;
      l_assessment_component_id  number;
      l_object_version_number number;

BEGIN

  -- create savepoint if p_commit is true
     IF p_commit = FND_API.G_TRUE THEN
          SAVEPOINT process_component_save;
     END IF;

  -- initialize message list if p_init_msg_list is set to true
     if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
          fnd_msg_pub.initialize;
     end if;

  -- initialize return status to success
     x_return_status := fnd_api.g_ret_sts_success;

      -- 11.25.2003: use object_id and object_type instead
      /*
      delete from amw_assessment_components
      where assessment_id = p_assessment_id
      and   component_code = p_component_code;
      */
      delete from amw_assessment_components
      where object_id = p_object_id
	  and   object_type = p_object_type
      and   component_code = p_component_code;


      if (p_select_flag = 'Y') then

          l_creation_date := SYSDATE;
          l_created_by := FND_GLOBAL.USER_ID;
          l_last_update_date := SYSDATE;
          l_last_updated_by := FND_GLOBAL.USER_ID;
          l_last_update_login := FND_GLOBAL.USER_ID;
          l_object_version_number := 1;

          select amw_assessment_components_s.nextval into l_assessment_component_id from dual;

          insert into amw_assessment_components (assessment_component_id,
                                              -- assessment_id, -- 11.25.2003 tsho: obseleted, use object_id and object_type instead
                                              object_type,      -- 11.25.2003: combined with object_id will replace assessment_id
                                              object_id,        -- 11.25.2003: combined with object_type will replace assessment_id
                                              component_code,
                                              other_component_value,
                                              creation_date,
                                              created_by,
                                              last_update_date,
                                              last_updated_by,
                                              last_update_login,
                                              object_version_number)
          values (l_assessment_component_id,
                  -- p_assessment_id,  -- 11.25.2003 tsho: obseleted, use object_id and object_type instead
                  p_object_type,
                  p_object_id,
                  p_component_code,
                  p_other_component_value,
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
              ROLLBACK TO assessment_component_save;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                      p_data   =>   x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO create_prop_person_support;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_COMPONENTS_PKG',
                            p_procedure_name    =>    'PROCESS_COMPONENTS',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                      p_data   =>   x_msg_data);

END PROCESS_COMPONENTS;

END AMW_COMPONENTS_PKG;

/
