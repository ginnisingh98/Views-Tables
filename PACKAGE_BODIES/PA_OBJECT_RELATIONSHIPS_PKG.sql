--------------------------------------------------------
--  DDL for Package Body PA_OBJECT_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OBJECT_RELATIONSHIPS_PKG" as
/* $Header: PAOBRPKB.pls 120.1 2005/08/19 16:36:25 mwasowic noship $ */


procedure INSERT_ROW
(                       p_user_id               IN      NUMBER,
   			p_object_type_from	IN	VARCHAR2,
			p_object_id_from1	IN	NUMBER,
			p_object_id_from2	IN	NUMBER,
			p_object_id_from3	IN	NUMBER,
			p_object_id_from4	IN	NUMBER,
			p_object_id_from5	IN	NUMBER,
			p_object_type_to	IN	VARCHAR2,
			p_object_id_to1		IN	NUMBER,
			p_object_id_to2 	IN	NUMBER,
			p_object_id_to3		IN	NUMBER,
			p_object_id_to4		IN	NUMBER,
			p_object_id_to5		IN	NUMBER,
			p_relationship_type	IN	VARCHAR2,
			p_relationship_subtype	IN	VARCHAR2,
                        p_lag_day               IN      NUMBER,
                        p_imported_lag          IN      VARCHAR2,
			p_priority		IN	VARCHAR2,
                        p_pm_product_code       IN      VARCHAR2,
                        p_weighting_percentage  IN      NUMBER := 0,
                  --FPM bug 3301192
                        p_comments              IN      VARCHAR2 := NULL,
                        p_status_code           IN      VARCHAR2 := NULL,
                   --end FPM bug 3301192
			x_object_relationship_id OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			x_return_status		 OUT	NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

  cursor C is select object_relationship_id from PA_OBJECT_RELATIONSHIPS
              where OBJECT_RELATIONSHIP_ID = X_OBJECT_RELATIONSHIP_ID ;
  x_object_relationship c%rowtype;

begin

  x_return_status := 'S';

  select pa_object_relationships_s.nextval into x_object_relationship_id
  from dual;

  insert into PA_OBJECT_RELATIONSHIPS (
            object_relationship_id,
			object_type_from,
			object_id_from1,
			object_id_from2,
			object_id_from3,
			object_id_from4,
			object_id_from5,
			object_type_to,
			object_id_to1,
			object_id_to2,
			object_id_to3,
			object_id_to4,
			object_id_to5,
			relationship_type,
			relationship_subtype,
			lag_day,
                        imported_lag,
			priority,
                        pm_product_code,
                        Record_Version_Number,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATE_LOGIN,
                        weighting_percentage,
                  --FPM bug 3301192
                        comments,
                        status_code
                  --end FPM bug 3301192
                        )
  values (  x_object_relationship_id,
			p_object_type_from,
			p_object_id_from1,
			p_object_id_from2,
			p_object_id_from3,
			p_object_id_from4,
			p_object_id_from5,
			p_object_type_to,
			p_object_id_to1,
			p_object_id_to2,
			p_object_id_to3,
			p_object_id_to4,
			p_object_id_to5,
			p_relationship_type,
			p_relationship_subtype,
			p_lag_day,
                        p_imported_lag,
			p_priority,
                        p_pm_product_code,
                        1,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        p_weighting_percentage,
                  --FPM bug 3301192
                        p_comments,
                        p_status_code
                   --end FPM bug 3301192
          );

  open c;
  fetch c into x_object_relationship;
  if (c%notfound) then
      x_return_status := 'E';
      close c;
    -- raise no_data_found;
  end if;
  close c;

EXCEPTION when others then
      x_return_status := 'U';
end INSERT_ROW;

procedure UPDATE_ROW
(       p_user_id               IN      NUMBER,
        p_object_relationship_id       IN      NUMBER,
        p_relationship_type     IN      VARCHAR2,
        p_relationship_subtype  IN      VARCHAR2,
        p_lag_day               IN      NUMBER,
        p_priority              IN      VARCHAR2,
        p_pm_product_code       IN      VARCHAR2,
	p_weighting_percentage  IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  --FPM bug 3301192
        p_comments              IN      VARCHAR2 := NULL,
        p_status_code           IN      VARCHAR2 := NULL,
  --end FPM bug 3301192
        p_record_version_number IN      NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

Begin

       x_return_status := 'S';

       if p_weighting_percentage = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM then

            update pa_object_relationships
            set
            relationship_subtype = p_relationship_subtype,
            lag_day              = p_lag_day,
            priority             = p_priority,
   --FPM bug 3301192
            comments             = p_comments,
            status_code          = p_status_code,
   --end FPM bug 3301192
            record_version_number = record_version_number + 1,
            last_updated_by      = p_user_id
            where
            object_relationship_id = p_object_relationship_id and
            record_version_number = p_record_version_number and
            pm_product_code is null;

            if (sql%notfound) then
      -- Modified by HSIU
      -- BUG 1712957
      -- Changed message to PA_RECORD_CHANGED
      --            fnd_message.set_name('PA','PA_XC_RECORD_CHANGED');
                fnd_message.set_name('PA','PA_RECORD_CHANGED');
                x_return_status := 'E';
             end if;

      else
            update pa_object_relationships
            set
            relationship_subtype = p_relationship_subtype,
            lag_day              = p_lag_day,
            priority             = p_priority,
   --FPM bug 3301192
            comments             = p_comments,
            status_code          = p_status_code,
   --end FPM bug 3301192
            record_version_number = record_version_number + 1,
            weighting_percentage = p_weighting_percentage,
            last_updated_by      = p_user_id
            where
            object_relationship_id = p_object_relationship_id and
            record_version_number = p_record_version_number and
            pm_product_code is null;

            if (sql%notfound) then
                fnd_message.set_name('PA','PA_RECORD_CHANGED');
                x_return_status := 'E';
             end if;

      end if;

EXCEPTION when others then
      x_return_status := 'U';

End;

procedure DELETE_ROW (
        p_object_relationship_id IN	NUMBER,
        p_object_type_from      IN      VARCHAR2,
        p_object_id_from1       IN      NUMBER,
        p_object_id_from2       IN      NUMBER,
        p_object_id_from3       IN      NUMBER,
        p_object_id_from4       IN      NUMBER,
        p_object_id_from5       IN      NUMBER,
        p_object_type_to        IN      VARCHAR2,
        p_object_id_to1         IN      NUMBER,
        p_object_id_to2         IN      NUMBER,
        p_object_id_to3         IN      NUMBER,
        p_object_id_to4         IN      NUMBER,
        p_object_id_to5         IN      NUMBER,
	p_record_version_number  IN	NUMBER,
        p_pm_product_code        IN     VARCHAR2,
	x_return_status		 OUT	NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
begin

    x_return_status := 'S';

    if p_object_relationship_id is null or p_object_relationship_id = FND_API.G_MISS_NUM then
       if p_object_type_to is null and (p_object_id_to1 is null or p_object_id_to1 = FND_API.G_MISS_NUM) then
          delete from pa_object_relationships
           where object_type_from = 'PA_TASKS'
             and object_id_from1 = p_object_id_from1
             and object_id_from2 = p_object_id_from2;

          delete from pa_object_relationships
           where object_type_to = 'PA_TASKS'
             and object_id_to1 = p_object_id_from1
             and object_id_to2 = p_object_id_from2;

       else
          delete from pa_object_relationships
           where object_type_from in ('PA_TASKS', 'PA_PROJECTS')
             and object_type_to in ('PA_TASKS', 'PA_PROJECTS')
             and object_id_from1 = p_object_id_from1
             and object_id_to1 = p_object_id_to1
             and pm_product_code is not null;
       end if;

    else
       delete from pa_object_relationships
       where object_relationship_id = p_object_relationship_id
       and record_version_number = nvl(p_record_version_number,record_version_number);

       if (sql%notfound) then
-- Modified by HSIU
-- BUG 1712957
-- Changed message to PA_RECORD_CHANGED
--          fnd_message.set_name('PA','PA_XC_RECORD_CHANGED');
          fnd_message.set_name('PA','PA_RECORD_CHANGED');
          x_return_status := 'E';
       end if;

    end if;


EXCEPTION when others then
    x_return_status := 'U';

end DELETE_ROW;

end PA_OBJECT_RELATIONSHIPS_PKG;


/
