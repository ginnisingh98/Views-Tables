--------------------------------------------------------
--  DDL for Package Body PA_SYSTEM_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SYSTEM_NUMBERS_PKG" AS
--$Header: PASNUMTB.pls 120.0 2005/05/30 07:05:56 appldev noship $

procedure GET_NEXT_NUMBER (
         p_system_number_id     IN  NUMBER     := NULL
        ,p_object1_pk1_value    IN  NUMBER     := NULL
        ,p_object1_type         IN  VARCHAR2   := NULL
        ,p_object2_pk1_value    IN  NUMBER     := NULL
        ,p_object2_type         IN  VARCHAR2   := NULL

        ,x_system_number_id      OUT NOCOPY NUMBER
        ,x_next_number           OUT NOCOPY NUMBER
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2
) is

   l_system_id NUMBER;
   l_next_number NUMBER;

 /*CURSOR lock_number_record
  IS
  SELECT system_number_id
  FROM PA_SYSTEM_NUMBERS
  WHERE p_object1_pk1_value  = object1_pk1_value
  FOR UPDATE of system_number_id NOWAIT; */

  CURSOR c_next_num IS
    SELECT system_number_id, next_number
    from PA_SYSTEM_NUMBERS
     where system_number_id = p_system_number_id;

  cp_next_num  c_next_num%ROWTYPE;

  CURSOR c_next_obj_num IS
    SELECT system_number_id, next_number
    from PA_SYSTEM_NUMBERS
     where p_object1_pk1_value = object1_pk1_value
     and   p_object1_type      = object1_type
     and   nvl(p_object2_pk1_value,0) = nvl(object2_pk1_value,0)
     and   nvl(p_object2_type,' ')     = nvl(object2_type,' ')
    FOR UPDATE of next_number NOWAIT;

  cp_next_obj_num  c_next_obj_num%ROWTYPE;

BEGIN

  pa_debug.init_err_stack('PA_SYSTEM_NUMBERS_PKG:GET_NEXT_NUMBER');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_system_number_id is null then
  	if p_object1_pk1_value is null OR p_object1_type is null then
     		PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_CI_SYS_NUM_NULL_VALUES');
     		x_return_status := FND_API.G_RET_STS_ERROR;
     		PA_DEBUG.RESET_ERR_STACK;
     		return;
        end if;
  end if;


  --if record already exists, retrieve the next available number
  if p_system_number_id is not null then
      	open c_next_num;
  	fetch c_next_num into cp_next_num;
  	if (c_next_num%notfound) then
    		close c_next_num;
    		raise no_data_found;
  	end if;
   	l_system_id 	:= cp_next_num.system_number_id;
   	l_next_number 	:= cp_next_num.next_number;
  	close c_next_num;
  else
        open c_next_obj_num;
        fetch c_next_obj_num into cp_next_obj_num;
        -- here we need to add a new record for these 2 objects
        if (c_next_obj_num%notfound) then
                close c_next_obj_num;
		INSERT_ROW (
         		p_object1_pk1_value
        		,p_object1_type
        		,p_object2_pk1_value
        		,p_object2_type
        		,NULL
        		,x_next_number
        		,x_system_number_id
        		,x_return_status
        		,x_msg_count
        		,x_msg_data);
                --l_system_id     := x_system_number_id;
                --l_next_number   := x_next_number;
                return;

        else
        	l_system_id     := cp_next_obj_num.system_number_id;
        	l_next_number   := cp_next_obj_num.next_number;
        	close c_next_obj_num;
        end if;
  end if;

  x_system_number_id := l_system_id;
  x_next_number      := l_next_number;

--now bump the existing number
 UPDATE_ROW (
        l_system_id,null,null,null,null,l_next_number+1,x_return_status,x_msg_count,x_msg_data);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end GET_NEXT_NUMBER;

procedure INSERT_ROW (
         p_object1_pk1_value    IN  NUMBER
        ,p_object1_type         IN  VARCHAR2

        ,p_object2_pk1_value    IN  NUMBER     := NULL
        ,p_object2_type         IN  VARCHAR2   := NULL
        ,p_next_number          IN  NUMBER     := NULL

        ,x_next_number           OUT NOCOPY NUMBER
  	,x_system_number_id      OUT NOCOPY NUMBER
  	,x_return_status         OUT NOCOPY VARCHAR2
  	,x_msg_count             OUT NOCOPY NUMBER
 	,x_msg_data              OUT NOCOPY VARCHAR2
) is

   l_system_id NUMBER;
   l_next_number NUMBER;
   l_rowid ROWID;


   cursor C is select ROWID from PA_SYSTEM_NUMBERS
     where system_number_id = l_system_id;


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --get the unique system number id from the Oracle Sequence
  /* Commented for bug 3866224 to remove hard coded schema reference and modified as below
  SELECT pa.pa_system_numbers_s.nextval */
  SELECT pa_system_numbers_s.nextval
  INTO l_system_id
  FROM DUAL;

  if p_next_number is NULL then
  	l_next_number := 1;
  else
        l_next_number := p_next_number;
  end if;

  insert into PA_SYSTEM_NUMBERS (
        system_number_id
        ,object1_pk1_value
	,object1_type
        ,object2_pk1_value
        ,object2_type
        ,next_number
    ,LAST_UPDATED_BY
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN

  ) VALUES (
         l_system_id
        ,p_object1_pk1_value
        ,p_object1_type
        ,p_object2_pk1_value
        ,p_object2_type
        ,l_next_number+1
    ,fnd_global.user_id
    ,fnd_global.user_id
    ,sysdate
    ,sysdate
    ,fnd_global.user_id
    );


  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  x_system_number_id := l_system_id;
  x_next_number      := l_next_number;

EXCEPTION
   -- set error message: in case more than user CREATED a new row
   WHEN DUP_VAL_ON_INDEX then
                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                    ,p_msg_name       => 'PA_UPDATE_FAILED');
                x_return_status := FND_API.G_RET_STS_ERROR;


    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end INSERT_ROW;

procedure UPDATE_ROW (
        p_system_number_id     IN  NUMBER     := NULL
        ,p_object1_pk1_value    IN  NUMBER    := NULL
        ,p_object1_type         IN  VARCHAR2  := NULL

        ,p_object2_pk1_value    IN  NUMBER     := NULL
        ,p_object2_type         IN  VARCHAR2   := NULL
        ,p_next_number          IN  NUMBER     := NULL

        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2
) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  update PA_SYSTEM_NUMBERS set
         object1_pk1_value		= Nvl(p_object1_pk1_value,object1_pk1_value)
        ,object1_type			= Nvl(p_object1_type,object1_type)
        ,object2_pk1_value		= Nvl(p_object2_pk1_value,object2_pk1_value)
        ,object2_type			= Nvl(p_object2_type,object2_type)
        ,next_number			= Nvl(p_next_number,next_number)
        ,LAST_UPDATED_BY           = fnd_global.user_id
        ,LAST_UPDATE_DATE          = sysdate
        ,LAST_UPDATE_LOGIN         = fnd_global.login_id
    where system_number_id = nvl(p_system_number_id,0)
    OR (object1_pk1_value  = p_object1_pk1_value AND
        p_object1_type     = p_object1_type      AND
	nvl(object2_pk1_value, 0)  = nvl(p_object2_pk1_value,0)  AND
        nvl(p_object2_type,' ')    = nvl(p_object2_type,' ')   );

   if (sql%notfound) then
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_CI_SYS_NUM_NOT_FOUND');
       x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end UPDATE_ROW;



procedure DELETE_ROW (
         p_system_number_id     IN  NUMBER    := NULL
        ,p_object1_pk1_value    IN  NUMBER    := NULL
        ,p_object1_type         IN  VARCHAR2  := NULL

        ,p_object2_pk1_value    IN  NUMBER     := NULL
        ,p_object2_type         IN  VARCHAR2   := NULL

  ,x_return_status               OUT NOCOPY    VARCHAR2
  ,x_msg_count                   OUT NOCOPY    NUMBER
  ,x_msg_data                    OUT NOCOPY    VARCHAR2

) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM  PA_SYSTEM_NUMBERS
    where system_number_id = nvl(p_system_number_id,0)
    OR (object1_pk1_value  = p_object1_pk1_value AND
        p_object1_type     = p_object1_type      AND
        nvl(object2_pk1_value, 0)  = nvl(p_object2_pk1_value,0)  AND
        nvl(p_object2_type,' ')    = nvl(p_object2_type,' ')   );



EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end DELETE_ROW;

END  PA_SYSTEM_NUMBERS_PKG;

/
