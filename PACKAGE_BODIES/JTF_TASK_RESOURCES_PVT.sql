--------------------------------------------------------
--  DDL for Package Body JTF_TASK_RESOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_RESOURCES_PVT" AS
/* $Header: jtfvtkrb.pls 115.26 2002/12/05 00:08:31 cjang ship $ */



 Function validate_resource_type_code
(p_resource_type_code in varchar2 ) return boolean


is
    cursor c_resource_type_code is
    select 1 from jtf_objects_vl
    where object_code =  p_resource_type_code ;

    x char ;
begin
    open c_resource_type_code ;
    fetch c_resource_type_code into x ;
    if c_resource_type_code%notfound then
        close c_resource_type_code ;
	return FALSE ;
    else
        close c_resource_type_code ;
        return true ;
    end if ;
end ;

PROCEDURE validate_task_template (
        x_return_status           	OUT NOCOPY      VARCHAR2                ,
        p_task_template_id        	IN       NUMBER 	DEFAULT NULL ,
        p_task_name			        IN	     VARCHAR2 	DEFAULT NULL ,
        x_task_template_id          OUT NOCOPY      NUMBER                  ,
        x_task_name              	OUT NOCOPY      VARCHAR2
)
    IS
        CURSOR c_task_id
        IS
            SELECT task_template_id ,task_name
              FROM jtf_task_templates_tl
             WHERE task_template_id = p_task_template_id
             OR	task_name = p_task_name;



        l_task_template_id        jtf_task_templates_tl.task_template_id%TYPE;
        l_task_name		  jtf_task_templates_tl.task_name%TYPE;
        done             BOOLEAN                      := FALSE;
    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;

        --- Assume correct task id is supplied
        IF p_task_template_id IS NOT NULL
        THEN
            OPEN c_task_id;
            FETCH c_task_id INTO l_task_template_id,l_task_name;


            IF c_task_id%NOTFOUND
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TEMP_ID');
                fnd_message.set_token('TASK_TEMPLATE_ID',P_TASK_TEMPLATE_ID);
                fnd_msg_pub.add;


            END IF;

        END IF;

        x_task_template_id := l_task_template_id;
        x_task_name	   := l_task_name;

    END;


  PROCEDURE validate_task_type (
        x_return_status           	OUT NOCOPY      VARCHAR2                ,
        p_task_type_id        		IN       NUMBER  	DEFAULT NULL ,
        p_name				        IN	     VARCHAR2 	DEFAULT NULL ,
        x_task_type_id             	OUT NOCOPY      NUMBER                  ,
        x_task_name			        OUT NOCOPY	     VARCHAR2                 )
    IS
        CURSOR c_task_type_id
        IS
            SELECT task_type_id ,name
              FROM jtf_task_types_tl
             WHERE task_type_id = p_task_type_id
             OR name= p_name;



        l_task_type_id        jtf_task_types_tl.task_type_id%TYPE;
        l_task_name	      jtf_task_types_tl.name%TYPE;
        done             BOOLEAN                      := FALSE;
    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;

        --- Assume correct task type id is supplied
        IF p_task_type_id IS NOT NULL
        THEN
            OPEN c_task_type_id;
            FETCH c_task_type_id INTO l_task_type_id,l_task_name;


            IF c_task_type_id%NOTFOUND
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TYPE_ID');
                fnd_message.set_token('TASK_TYPE_ID',P_TASK_TYPE_ID);
                fnd_msg_pub.add;


            END IF;

        END IF;

        x_task_type_id := l_task_type_id;
        x_task_name:=l_task_name;

    END;


   Procedure VALIDATE_ENABLED_FLAG
            (L_API_NAME 		IN	VARCHAR2,
            P_FLAG				IN	VARCHAR2,
            P_FLAG_NAME			IN	VARCHAR2) IS

    BEGIN
   if (p_flag is not null) then
 	if (p_flag not in ('Y','N')) then
 		raise fnd_api.g_exc_error;
 	end if;
  end if;
  END;


 procedure dump_long_line(txt in varchar2, v_str in varchar2) is
    ln  integer := length(v_str);
    st  integer := 1;
  begin

    loop

      st := st + 72;
      exit when (st >= ln);
    end loop;
  end dump_long_line;


	Procedure  CREATE_TASK_RSRC_REQ
	(P_API_VERSION			IN	NUMBER					            ,
	P_INIT_MSG_LIST			IN	VARCHAR2  DEFAULT FND_API.G_FALSE	,
	P_COMMIT			    IN	VARCHAR2  DEFAULT FND_API.G_FALSE	,
	P_TASK_ID			    IN	NUMBER	  DEFAULT NULL			    ,
	P_TASK_NAME			    IN	VARCHAR2  DEFAULT NULL			    ,
	P_TASK_NUMBER			IN	VARCHAR2  DEFAULT NULL			    ,
	P_TASK_TYPE_ID			IN	NUMBER 	  DEFAULT NULL			    ,
	P_TASK_TYPE_NAME		IN	VARCHAR2  DEFAULT NULL			    ,
	P_TASK_TEMPLATE_ID		IN	NUMBER	  DEFAULT NULL			    ,
	P_TASK_TEMPLATE_NAME	IN	VARCHAR2  DEFAULT NULL			    ,
	P_RESOURCE_TYPE_CODE	IN	VARCHAR2				            ,
	P_REQUIRED_UNITS		IN	NUMBER 	 				            ,
	P_ENABLED_FLAG			IN	VARCHAR2 DEFAULT jtf_task_utl.g_no	,
	X_RETURN_STATUS			OUT NOCOPY	VARCHAR2				            ,
	X_MSG_COUNT			    OUT NOCOPY	NUMBER 					            ,
	X_MSG_DATA			    OUT NOCOPY	VARCHAR2				            ,
	X_RESOURCE_REQ_ID		OUT NOCOPY	NUMBER					         ,
        p_attribute1              IN       VARCHAR2 DEFAULT null,
        p_attribute2              IN       VARCHAR2 DEFAULT null,
        p_attribute3              IN       VARCHAR2 DEFAULT null,
        p_attribute4              IN       VARCHAR2 DEFAULT null,
        p_attribute5              IN       VARCHAR2 DEFAULT null,
        p_attribute6              IN       VARCHAR2 DEFAULT null,
        p_attribute7              IN       VARCHAR2 DEFAULT null,
        p_attribute8              IN       VARCHAR2 DEFAULT null,
        p_attribute9              IN       VARCHAR2 DEFAULT null,
        p_attribute10             IN       VARCHAR2 DEFAULT null,
        p_attribute11             IN       VARCHAR2 DEFAULT null,
        p_attribute12             IN       VARCHAR2 DEFAULT null,
        p_attribute13             IN       VARCHAR2 DEFAULT null,
        p_attribute14             IN       VARCHAR2 DEFAULT null,
        p_attribute15             IN       VARCHAR2 DEFAULT null,
        p_attribute_category      IN       VARCHAR2 DEFAULT null        )  IS



  	--

	--Declare the variables
	--

	l_api_version       		constant number 					    := 1.0				              ;
	l_api_name          		constant varchar2(30) 					:= 'CREATE_TASK_RSRC_REQ'  	      ;
	l_return_status     		varchar2(1)           					:= fnd_api.g_ret_sts_success 	  ;
	l_task_id           		jtf_tasks_b.task_id%type  				:= P_TASK_ID 			          ;
	l_task_number       		jtf_tasks_b.task_number%type  			:= P_TASK_NUMBER 		          ;
	l_task_name			        jtf_tasks_tl.task_name%type				:= P_TASK_NAME			          ;
	l_task_type_id			    jtf_task_types_b.task_type_id%type		:= P_TASK_TYPE_ID		          ;
	l_task_type_name		    jtf_task_types_tl.name%type				:= P_TASK_TYPE_NAME		          ;
	l_task_template_id		    jtf_task_templates_b.task_template_id%type:= P_TASK_TEMPLATE_ID		      ;
	l_task_template_name		jtf_task_templates_tl.task_name%type	:= P_TASK_TEMPLATE_NAME		      ;
	l_enabled_flag      		jtf_task_rsc_reqs.enabled_flag%type 	:= P_ENABLED_FLAG		          ;
	l_resource_type_code		jtf_task_rsc_reqs.resource_type_code%type:= P_RESOURCE_TYPE_CODE		  ;
	l_required_units		    jtf_task_rsc_reqs.required_units%type	:= P_REQUIRED_UNITS		          ;
	--l_resp_appl_id		    NUMBER	 						        := p_resp_appl_id		;
	--l_resp_id			        NUMBER	 						        := p_resp_id			;
	--l_user_id			        NUMBER	 						:= p_user_id			;
	--l_login_id			    NUMBER	 						:= p_login_id			;
	l_msg_data          		VARCHAR2(2000) 										;
	l_msg_count         		NUMBER 											;
	x                                   		char 									;
	l_resource_req_id		NUMBER;
	l_rowid				rowid;


  	cursor rr_cur3 (l_rowid in rowid ) is
    	select 1 from jtf_task_rsc_reqs
    	where rowid = l_rowid ;

  BEGIN


    	savepoint create_task_resource_pvt ;

   	 x_return_status := fnd_api.g_ret_sts_success ;



    	--if p_enabled_flag = jtf_task_utl.g_yes then


   	select JTF_TASK_RSC_REQS_S.nextval into  l_resource_req_id
   	from dual ;





 	JTF_TASK_RSC_REQS_PKG.INSERT_ROW (
  		X_ROWID  => l_rowid,
  		X_RESOURCE_REQ_ID => l_resource_req_id,
  		X_TASK_TYPE_ID   =>  l_task_type_id,
  		X_TASK_ID => l_task_id,
  		X_TASK_TEMPLATE_ID => l_task_template_id,
  		X_REQUIRED_UNITS => l_required_units,
  		X_ENABLED_FLAG => l_enabled_flag,
        x_attribute1 => p_attribute1 ,
        x_attribute2 => p_attribute2 ,
        x_attribute3 => p_attribute3 ,
        x_attribute4 => p_attribute4 ,
        x_attribute5 => p_attribute5 ,
        x_attribute6 => p_attribute6 ,
        x_attribute7 => p_attribute7 ,
        x_attribute8 => p_attribute8 ,
        x_attribute9 => p_attribute9 ,
        x_attribute10 => p_attribute10 ,
        x_attribute11 => p_attribute11 ,
        x_attribute12 => p_attribute12 ,
        x_attribute13 => p_attribute13 ,
        x_attribute14 => p_attribute14 ,
        x_attribute15 => p_attribute15,
        x_attribute_category => p_attribute_category ,
        X_RESOURCE_TYPE_CODE =>l_resource_type_code,
  		X_CREATION_DATE => sysdate ,
        X_CREATED_BY => jtf_task_utl.created_by ,
        X_LAST_UPDATE_DATE => sysdate ,
        X_LAST_UPDATED_BY => -1  ,
        X_LAST_UPDATE_LOGIN => jtf_task_utl.login_id );




       open rr_cur3 (l_rowid) ;
       fetch rr_cur3 into x ;

       IF rr_cur3%notfound THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error ;
            fnd_message.set_name('JTF' ,'JTF_TASK_INSERTING_RESOURCE') ;
            fnd_msg_pub.add ;
            raise fnd_api.g_exc_unexpected_error ;

       ELSE

            X_RESOURCE_REQ_ID := l_resource_req_id ;
       end if ;

	exception
 		when fnd_api.g_exc_unexpected_error then

        	rollback to create_task_resource_pvt ;
        	x_return_status := fnd_api.g_ret_sts_unexp_error ;
        	fnd_msg_pub.count_and_get ( p_count => x_msg_count ,
        			    p_data => x_msg_data );
   		 when others then

        	rollback to create_task_resource_pvt ;
        	x_return_status := fnd_api.g_ret_sts_unexp_error ;

        	fnd_msg_pub.count_and_get ( p_count => x_msg_count ,
                                    p_data => x_msg_data );
	END;







--Procedure to Update the Task Resource Requirements


	Procedure  UPDATE_TASK_RSCR_REQ
	(P_API_VERSION			IN	NUMBER					            ,
	P_OBJECT_VERSION_NUMBER	IN OUT NOCOPY	NUMBER 	 				        ,
	P_INIT_MSG_LIST			IN	VARCHAR2 DEFAULT FND_API.G_FALSE	,
	P_COMMIT			    IN	VARCHAR2 DEFAULT FND_API.G_FALSE	,
	P_RESOURCE_REQ_ID		IN	NUMBER 					            ,
	P_TASK_ID			    IN	NUMBER 	 default null			    ,
	P_TASK_NAME			    IN	VARCHAR2 default null			    ,
	P_TASK_NUMBER			IN	VARCHAR2 default null			    ,
	P_TASK_TYPE_ID			IN	NUMBER 	 default null			    ,
	P_TASK_TYPE_NAME		IN	VARCHAR2 				            ,
	P_TASK_TEMPLATE_ID		IN	NUMBER   default null			    ,
	P_TASK_TEMPLATE_NAME	IN	VARCHAR2				            ,
	P_RESOURCE_TYPE_CODE	IN	VARCHAR2				            ,
	P_REQUIRED_UNITS		IN	NUMBER 	 				            ,
	P_ENABLED_FLAG			IN	VARCHAR2 DEFAULT jtf_task_utl.g_no	,
	X_RETURN_STATUS			OUT NOCOPY	VARCHAR2				            ,
	X_MSG_COUNT			    OUT NOCOPY	NUMBER 					            ,
	X_MSG_DATA			    OUT NOCOPY	VARCHAR2				            ,
            p_attribute1              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute2              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute3              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute4              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute5              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute6              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute7              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute8              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute9              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute10             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute11             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute12             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute13             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute14             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute15             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute_category      IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char  )  IS


	--Declare the variables
	--

	l_api_version       		constant number 					            := 1.0				    ;
	l_api_name          		constant varchar2(30) 					        := 'CREATE_TASK_RSRC_REQ';
	l_return_status     		varchar2(1)           					        := fnd_api.g_ret_sts_success;
	l_task_id           		jtf_tasks_b.task_id%type  				        := P_TASK_ID 			;
	l_task_number       		jtf_tasks_b.task_number%type  				    := P_TASK_NUMBER 		;
	l_task_name			        jtf_tasks_tl.task_name%type				        := P_TASK_NAME			;
	l_task_type_id			    jtf_task_types_b.task_type_id%type			    := P_TASK_TYPE_ID		;
	l_task_type_name		    jtf_task_types_tl.name%type				        := P_TASK_TYPE_NAME		;
	l_task_template_id		    jtf_task_templates_b.task_template_id%type		:= P_TASK_TEMPLATE_ID	;
	l_task_template_name		jtf_task_templates_tl.task_name%type			:= P_TASK_TEMPLATE_NAME	;
	l_enabled_flag      		jtf_task_rsc_reqs.enabled_flag%type 			:= P_ENABLED_FLAG		;
	l_resource_type_code		jtf_task_rsc_reqs.resource_type_code%type		:= P_RESOURCE_TYPE_CODE	;
	l_required_units		    jtf_task_rsc_reqs.required_units%type			:= P_REQUIRED_UNITS		;
	--l_resp_appl_id		    NUMBER	 						                := p_resp_appl_id		;
	--l_resp_id			        NUMBER	 						                := p_resp_id			;
	--l_user_id			        NUMBER	 						                := p_user_id			;
	--l_login_id			    NUMBER	 						                := p_login_id			;
	l_msg_data          		VARCHAR2(2000) 										                    ;
	l_msg_count         		NUMBER 											                        ;
	x                           CHAR 									                                ;
	l_resource_req_id		    NUMBER                                          := p_resource_req_id    ;
	l_rowid				        rowid                                                                   ;





	cursor trsr_get_cur is
	select
	P_TASK_ID  task_id ,
	P_TASK_TYPE_ID  task_type_id ,
	P_TASK_TEMPLATE_ID  task_template_id ,
	P_RESOURCE_TYPE_CODE  resource_type_code ,
	REQUIRED_UNITS required_units,
	ENABLED_FLAG enabled_flag,
decode( p_attribute1 , fnd_api.g_miss_char , attribute1 , p_attribute1 )  attribute1  ,
decode( p_attribute2 , fnd_api.g_miss_char , attribute2 , p_attribute2 )  attribute2  ,
decode( p_attribute3 , fnd_api.g_miss_char , attribute3 , p_attribute3 )  attribute3  ,
decode( p_attribute4 , fnd_api.g_miss_char , attribute4 , p_attribute4 )  attribute4  ,
decode( p_attribute5 , fnd_api.g_miss_char , attribute5 , p_attribute5 )  attribute5  ,
decode( p_attribute6 , fnd_api.g_miss_char , attribute6 , p_attribute6 )  attribute6  ,
decode( p_attribute7 , fnd_api.g_miss_char , attribute7 , p_attribute7 )  attribute7  ,
decode( p_attribute8 , fnd_api.g_miss_char , attribute8 , p_attribute8 )  attribute8  ,
decode( p_attribute9 , fnd_api.g_miss_char , attribute9 , p_attribute9 )  attribute9  ,
decode( p_attribute10 , fnd_api.g_miss_char , attribute10 , p_attribute10 )  attribute10  ,
decode( p_attribute11 , fnd_api.g_miss_char , attribute11 , p_attribute11 )  attribute11  ,
decode( p_attribute12 , fnd_api.g_miss_char , attribute12 , p_attribute12 )  attribute12  ,
decode( p_attribute13 , fnd_api.g_miss_char , attribute13 , p_attribute13 )  attribute13  ,
decode( p_attribute14 , fnd_api.g_miss_char , attribute14 , p_attribute14 )  attribute14  ,
decode( p_attribute15 , fnd_api.g_miss_char , attribute15 , p_attribute15 )  attribute15 ,
decode( p_attribute_category,fnd_api.g_miss_char,attribute_category,p_attribute_category) attribute_category
	from jtf_task_rsc_reqs
	where resource_req_id = l_resource_req_id ;

	x                                   char ;



	task_res                        trsr_get_cur%rowtype ;

	BEGIN


          savepoint update_task_resource_pvt ;

          x_return_status := fnd_api.g_ret_sts_success ;



         open trsr_get_cur ;
         fetch trsr_get_cur into task_res ;

         if trsr_get_cur%notfound then
               fnd_message.set_name( 'JTF', 'JTF_TASK_INV_RES_REQ_ID') ;
               fnd_msg_pub.add ;
               x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
               raise fnd_api.g_exc_unexpected_error ;
        end if ;

	--l_required_units := task_res.REQUIRED_UNITS ;

        l_enabled_flag := task_res.ENABLED_FLAG ;

        if L_ENABLED_FLAG IS NULL THEN
            L_ENABLED_FLAG  := jtf_task_utl.g_no ;
        END IF ;

        if l_task_id IS NULL then

            l_task_id := task_res.task_id ;
        end if ;

	if l_task_template_id IS NULL  then

            l_task_template_id := task_res.task_template_id ;
        end if ;

	if l_task_type_id  IS NULL then

            l_task_type_id := task_res.task_type_id ;
        end if ;



      /*  if  validate_resource_type_code ( p_resource_type_code  =>l_resource_type_code) then
             l_resource_type_code:=task_res.resource_type_code;

          else
              raise fnd_api.g_exc_error ;

          end if ; */

          --Task can be updated only if it is active

        --if l_enabled_flag = fnd_api.G_true then


        jtf_task_resources_pub.lock_task_resources
        ( P_API_VERSION                 =>	1.0 ,
         P_INIT_MSG_LIST                =>	fnd_api.g_false ,
         P_COMMIT                       =>	fnd_api.g_false ,
         P_RESOURCE_REQUIREMENT_ID      =>	l_resource_req_id ,
         P_OBJECT_VERSION_NUMBER        =>	p_object_version_number,
         X_RETURN_STATUS                =>	x_return_status ,
         X_MSG_DATA                     =>	x_msg_data ,
         X_MSG_COUNT                    =>	x_msg_count ) ;

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;


        p_object_version_number := p_object_version_number + 1 ;


		JTF_TASK_RSC_REQS_PKG.UPDATE_ROW (
  		X_RESOURCE_REQ_ID 	=>l_resource_req_id,
  		X_TASK_TYPE_ID 		=>l_task_type_id,
  		X_TASK_ID 		=> l_task_id ,
  		X_TASK_TEMPLATE_ID 	=> l_task_template_id,
  		X_REQUIRED_UNITS 	=> l_required_units,
  		X_ENABLED_FLAG 		=> l_enabled_flag,
  		X_OBJECT_VERSION_NUMBER => p_object_version_number,
            x_attribute1 => task_res.attribute1 ,
            x_attribute2 => task_res.attribute2 ,
            x_attribute3 => task_res.attribute3 ,
            x_attribute4 => task_res.attribute4 ,
            x_attribute5 => task_res.attribute5 ,
            x_attribute6 => task_res.attribute6 ,
            x_attribute7 => task_res.attribute7 ,
            x_attribute8 => task_res.attribute8 ,
            x_attribute9 => task_res.attribute9 ,
            x_attribute10 => task_res.attribute10 ,
            x_attribute11 => task_res.attribute11 ,
            x_attribute12 => task_res.attribute12 ,
            x_attribute13 => task_res.attribute13 ,
            x_attribute14 => task_res.attribute14 ,
            x_attribute15 => task_res.attribute15 ,
            x_attribute_category => task_res.attribute_category ,
  		X_RESOURCE_TYPE_CODE 	=> l_resource_type_code,
  		X_LAST_UPDATE_DATE    	=>sysdate,
  		X_LAST_UPDATED_BY     	=> -1 ,
  		X_LAST_UPDATE_LOGIN   	=>jtf_task_utl.login_id
  		);




  -- end if;


    if trsr_get_cur%isopen then
        close trsr_get_cur ;
    end if ;

    if fnd_api.to_boolean(p_commit) then
        commit work ;
    end if ;

   -- fnd_msg_pub.count_and_get( p_count => x_msg_count ,
				--p_data  => x_msg_data ) ;


exception
  when fnd_api.g_exc_unexpected_error then
        if trsr_get_cur%isopen then
             close trsr_get_cur ;
        end if ;
        rollback to update_task_resource_pvt ;
        fnd_message.set_name( 'JTF', 'JTF_TASK_UPD_RES_REQ_ID') ;
        fnd_message.set_token('RESOURCE_REQ_ID',P_RESOURCE_REQ_ID);
        fnd_msg_pub.add ;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        fnd_msg_pub.count_and_get ( p_count => x_msg_count ,
        			    p_data => x_msg_data );
    when others then
        if trsr_get_cur%isopen then
             close trsr_get_cur ;
        end if ;
        rollback to update_task_resource_pvt ;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        fnd_msg_pub.count_and_get ( p_count => x_msg_count ,
                                    p_data => x_msg_data );
end ;



--Procedure to Delete the Task Resource Requirements



    Procedure  DELETE_TASK_RSRC_REQ
    (P_API_VERSION			    IN		NUMBER					            ,
    P_OBJECT_VERSION_NUMBER		IN		NUMBER   				            ,
    P_INIT_MSG_LIST			    IN		VARCHAR2 DEFAULT FND_API.G_FALSE	,
    P_COMMIT			        IN		VARCHAR2 DEFAULT FND_API.G_FALSE	,
    P_RESOURCE_REQ_ID		    IN		NUMBER 					            ,
    X_RETURN_STATUS			    OUT NOCOPY		VARCHAR2				            ,
    X_MSG_COUNT			        OUT NOCOPY		NUMBER 					            ,
    X_MSG_DATA			        OUT NOCOPY		VARCHAR2 				             ) IS




    l_resource_req_id         jtf_task_rsc_reqs.resource_req_id%TYPE := p_resource_req_id ;



    x char;

    cursor c_res_req_del is
    select 1
    from jtf_task_rsc_reqs
    where resource_req_id = l_resource_req_id ;


    begin

    savepoint delete_task_resource_pvt ;

    x_return_status := fnd_api.g_ret_sts_success ;

    ---call the table handler to delete the resource req


    jtf_task_resources_pub.lock_task_resources
        ( P_API_VERSION                 =>	1.0 ,
         P_INIT_MSG_LIST                =>	fnd_api.g_false ,
         P_COMMIT                       =>	fnd_api.g_false ,
         P_RESOURCE_REQUIREMENT_ID      =>	l_resource_req_id ,
         P_OBJECT_VERSION_NUMBER        =>	p_object_version_number,
         X_RETURN_STATUS                =>	x_return_status ,
         X_MSG_DATA                     =>	x_msg_data ,
         X_MSG_COUNT                    =>	x_msg_count ) ;

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;


   JTF_TASK_RSC_REQS_PKG.DELETE_ROW
	( X_RESOURCE_REQ_ID 		=> 	l_resource_req_id );

    open c_res_req_del;
    fetch c_res_req_del into x ;

    if c_res_req_del%found then
             fnd_message.set_name( 'JTF', 'JTF_TASK_DELETING_RES_REQ_ID') ;
             fnd_msg_pub.add ;
             x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
             raise fnd_api.g_exc_unexpected_error ;
             close c_res_req_del ;


    else
             close c_res_req_del ;
    end if ;

    if c_res_req_del%isopen then
        close c_res_req_del ;
    end if;

    if fnd_api.to_boolean(p_commit) then
        commit work ;
    end if ;

    fnd_msg_pub.count_and_get( p_count => x_msg_count ,
                                p_data  => x_msg_data ) ;


exception
    when fnd_api.g_exc_unexpected_error then
        rollback to delete_task_resource_pvt ;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        fnd_msg_pub.count_and_get ( p_count => x_msg_count ,
                                    p_data => x_msg_data );


    when others then
        rollback to delete_task_resource_pvt;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        fnd_msg_pub.count_and_get ( p_count => x_msg_count ,
                                    p_data => x_msg_data );
end ;






--Procedure to get the Task Resource Req

 Procedure   GET_TASK_RSRC_REQ
    (
    P_API_VERSION			    IN	NUMBER	 			          ,
    P_INIT_MSG_LIST			    IN	VARCHAR2 	DEFAULT G_FALSE	  ,
    P_COMMIT			        IN	VARCHAR2	DEFAULT G_FALSE	  ,
    P_RESOURCE_REQ_ID		    IN	NUMBER 				          ,
    P_RESOURCE_REQ_NAME		    IN	VARCHAR2	DEFAULT NULL	  ,
    P_TASK_ID			        IN	NUMBER 		DEFAULT NULL	  ,
    P_TASK_NAME			        IN	VARCHAR2	DEFAULT NULL	  ,
    P_TASK_TYPE_ID			    IN	NUMBER 		DEFAULT NULL	  ,
    P_TASK_TYPE_NAME		    IN	VARCHAR2	DEFAULT NULL	  ,
    P_TASK_TEMPLATE_ID		    IN	NUMBER		DEFAULT NULL	  ,
    P_TASK_TEMPLATE_NAME		IN	VARCHAR2	DEFAULT NULL	  ,
    P_SORT_DATA                	IN  JTF_TASK_RESOURCES_PUB.SORT_DATA,
    P_QUERY_OR_NEXT_CODE       	IN  VARCHAR2    	default 'Q'	  ,
    P_START_POINTER            	IN  NUMBER				          ,
    P_REC_WANTED               	IN  NUMBER				          ,
    P_SHOW_ALL                 	IN  VARCHAR2    	default 'Y'	  ,
    P_RESOURCE_TYPE_CODE		IN	VARCHAR2			          ,
    P_REQUIRED_UNITS		    IN	NUMBER 				          ,
    P_ENABLED_FLAG			    IN	VARCHAR2	DEFAULT jtf_task_utl.g_no ,
    X_RETURN_STATUS			    OUT NOCOPY	VARCHAR2			          ,
    X_MSG_COUNT			        OUT NOCOPY	NUMBER				          ,
    X_MSG_DATA			        OUT NOCOPY	VARCHAR2 			          ,
    X_TASK_RSC_REQ_REC		    OUT NOCOPY	JTF_TASK_RESOURCES_PUB.TASK_RSC_REQ_TBL,
    X_TOTAL_RETRIEVED          	OUT NOCOPY NUMBER				          ,
    X_TOTAL_RETURNED           	OUT NOCOPY NUMBER 				          )  IS

   -- declare variables
    l_api_name      varchar2(30) := 'GET_TASK_RSRC_REQ';
    v_cursor_id     integer;
    v_dummy         integer;
    v_cnt           integer;
    v_end           integer;
    v_start         integer;
    v_type          jtf_task_resources_pub.task_rsc_req_rec;
    v_tbl		  jtf_task_resources_pub.task_rsc_req_tbl;
    v_select	  varchar2(2000);




    Procedure create_sql_statement is

      v_index   integer;
      v_first   integer;
      v_comma   varchar2(5);
      v_where   varchar2(2000);
     -- v_select   varchar2(2000);
      v_and     char(1) := 'N';

      procedure add_to_sql (p_in     varchar2,  --value in parameter
                            p_bind   varchar2,  --bind variable to use
                            p_field  varchar2   --field associated with parameter

                            ) is
          v_str varchar2(10);
        begin
        -- add_to_sql
          if (p_in is not null) then
            if (v_and = 'N') then
              v_str := ' ';

              v_and := 'Y';
            else
              v_str := ' and ';
            end if;
            v_where := v_where   || v_str ||
                        p_field  || ' = :'  ||
                        p_bind;
          end if;
        end add_to_sql;

    begin

    --create_sql_statement

      v_select := 'select  '||'RESOURCE_REQ_ID,'||
                      'TASK_TYPE_ID,'||
                      'TASK_ID,'||
                      'TASK_TEMPLATE_ID,'||
                      'RESOURCE_TYPE_CODE,'||
                      'REQUIRED_UNITS,'||
                      'ENABLED_FLAG,'||
                      'ATTRIBUTE1,'||
                      'ATTRIBUTE2,'||
                      'ATTRIBUTE3,'||
                      'ATTRIBUTE4,'||
                      'ATTRIBUTE5,'||
                      'ATTRIBUTE6,'||
                      'ATTRIBUTE7,'||
                      'ATTRIBUTE8,'||
                      'ATTRIBUTE9,'||
                      'ATTRIBUTE10,'||
                      'ATTRIBUTE11,'||
                      'ATTRIBUTE12,'||
                      'ATTRIBUTE13,'||
                      'ATTRIBUTE14,'||
                      'ATTRIBUTE15,'||
                      'ATTRIBUTE_CATEGORY '||
                 'from jtf_task_rsc_reqs ';

      add_to_sql(to_char(P_RESOURCE_REQ_ID),'b1', 'resource_req_id');
      add_to_sql(to_char(P_TASK_TYPE_ID),'b2', 'task_type_id');
      add_to_sql(to_char(P_TASK_ID),'b3', 'task_id');
      add_to_sql(to_char(P_TASK_TEMPLATE_ID),'b4', 'task_template_id');
      add_to_sql(P_RESOURCE_TYPE_CODE,'b5', 'resource_type_code');
      add_to_sql(to_char(P_REQUIRED_UNITS),'b6', 'required_units');
      add_to_sql(P_ENABLED_FLAG,'b7', 'enabled_flag');


      if (v_where is not null) then
        v_select := v_select || ' where ' ||v_where;
      end if;


      if (p_sort_data.count > 0) then --there is a sort preference

        v_select := v_select || ' order by ';

        v_index := p_sort_data.first;
        v_first := v_index;

        loop

          if (v_first = v_index) then
            v_comma := ' ';
          else
            v_comma := ', ';

          end if;

          v_select := v_select || v_comma ||
                      p_sort_data(v_index).field_name  || ' ' ;

          -- ascending or descending order
          if (p_sort_data(v_index).asc_dsc_flag = 'A') then
            v_select := v_select || 'asc ';
          elsif (p_sort_data(v_index).asc_dsc_flag = 'D') then
            v_select := v_select || 'desc ';
          end if;

          exit when v_index = p_sort_data.last;

          v_index := p_sort_data.next(v_index);

        end loop;

      end if;

    end create_sql_statement;

  begin



    x_return_status := fnd_api.g_ret_sts_success;


   X_TASK_RSC_REQ_REC.delete;

    if (p_query_or_next_code = 'Q') then


      v_tbl.delete;

      create_sql_statement;

      dump_long_line('v_sel:',v_select);

      v_cursor_id := dbms_sql.open_cursor;

      dbms_sql.parse(v_cursor_id, v_select, dbms_sql.v7);

      -- bind variables only if they added to the sql statement
      if (P_RESOURCE_REQ_ID is not null) then
        dbms_sql.bind_variable(v_cursor_id, ':b1', p_resource_req_id);
      end if;

      if (P_TASK_TYPE_ID is not null) then
        dbms_sql.bind_variable(v_cursor_id, ':b2', p_task_type_id);
      end if;

      if (P_TASK_ID is not null) then
        dbms_sql.bind_variable(v_cursor_id, ':b3', p_task_id);
      end if;

      if (P_TASK_TEMPLATE_ID is not null) then
        dbms_sql.bind_variable(v_cursor_id, ':b4', p_task_template_id);
      end if;

      if (P_RESOURCE_TYPE_CODE is not null) then
        dbms_sql.bind_variable(v_cursor_id, ':b5', p_resource_type_code);

      end if;

      if (P_REQUIRED_UNITS is not null) then
        dbms_sql.bind_variable(v_cursor_id, ':b6', p_required_units);
      end if;

      if (P_ENABLED_FLAG is not null) then
        dbms_sql.bind_variable(v_cursor_id, ':b7',p_enabled_flag );
      end if;

      -- define the output columns
      dbms_sql.define_column(v_cursor_id,  1, v_type.RESOURCE_REQ_ID     	   );


      dbms_sql.define_column(v_cursor_id,  2, v_type.TASK_TYPE_ID       	   );

      dbms_sql.define_column(v_cursor_id,  3, v_type.TASK_ID			   );

      dbms_sql.define_column(v_cursor_id,  4, v_type.TASK_TEMPLATE_ID   	   );

      dbms_sql.define_column(v_cursor_id,  5, v_type.RESOURCE_TYPE_CODE ,  	 30);

      dbms_sql.define_column(v_cursor_id,  6, v_type.REQUIRED_UNITS                );

      dbms_sql.define_column(v_cursor_id,   7, v_type.ENABLED_FLAG,   	        1  );

      dbms_sql.define_column(v_cursor_id,  8, v_type.ATTRIBUTE1,                150);

      dbms_sql.define_column(v_cursor_id,  9, v_type.ATTRIBUTE2,                150);

      dbms_sql.define_column(v_cursor_id,  10, v_type.ATTRIBUTE3,               150);

      dbms_sql.define_column(v_cursor_id,  11, v_type.ATTRIBUTE4,               150);

      dbms_sql.define_column(v_cursor_id,  12, v_type.ATTRIBUTE5,               150);

      dbms_sql.define_column(v_cursor_id,  13, v_type.ATTRIBUTE6,               150);

      dbms_sql.define_column(v_cursor_id, 14, v_type.ATTRIBUTE7,                150);

      dbms_sql.define_column(v_cursor_id, 15, v_type.ATTRIBUTE8,                150);

      dbms_sql.define_column(v_cursor_id, 16, v_type.ATTRIBUTE9,                150);

      dbms_sql.define_column(v_cursor_id, 17, v_type.ATTRIBUTE10,               150);

      dbms_sql.define_column(v_cursor_id, 18, v_type.ATTRIBUTE11,               150);

      dbms_sql.define_column(v_cursor_id, 19, v_type.ATTRIBUTE12,               150);


      dbms_sql.define_column(v_cursor_id, 20, v_type.ATTRIBUTE13,               150);

      dbms_sql.define_column(v_cursor_id, 21, v_type.ATTRIBUTE14,               150);

      dbms_sql.define_column(v_cursor_id, 22, v_type.ATTRIBUTE15,               150);

      dbms_sql.define_column(v_cursor_id, 23, v_type.ATTRIBUTE_CATEGORY,        30);



      v_dummy := dbms_sql.execute(v_cursor_id);



      v_cnt := 0;

      loop

        exit when (dbms_sql.fetch_rows(v_cursor_id) = 0);

        v_cnt := v_cnt + 1;

        -- retrieve the rows from the buffer

        dbms_sql.column_value(v_cursor_id,  1, v_type.RESOURCE_REQ_ID);
        dbms_sql.column_value(v_cursor_id,  2, v_type.TASK_TYPE_ID);
        dbms_sql.column_value(v_cursor_id,  3, v_type.TASK_ID);
        dbms_sql.column_value(v_cursor_id,  4, v_type.TASK_TEMPLATE_ID);
        dbms_sql.column_value(v_cursor_id,  5, v_type.RESOURCE_TYPE_CODE);
        dbms_sql.column_value(v_cursor_id,  6, v_type.REQUIRED_UNITS);
        dbms_sql.column_value(v_cursor_id,  7, v_type.ENABLED_FLAG);
        dbms_sql.column_value(v_cursor_id,  8, v_type.ATTRIBUTE1);
        dbms_sql.column_value(v_cursor_id,  9, v_type.ATTRIBUTE2);
        dbms_sql.column_value(v_cursor_id, 10, v_type.ATTRIBUTE3);
        dbms_sql.column_value(v_cursor_id, 11, v_type.ATTRIBUTE4);
        dbms_sql.column_value(v_cursor_id, 12, v_type.ATTRIBUTE5);
        dbms_sql.column_value(v_cursor_id, 13, v_type.ATTRIBUTE6);
        dbms_sql.column_value(v_cursor_id, 14, v_type.ATTRIBUTE7);

        dbms_sql.column_value(v_cursor_id, 15, v_type.ATTRIBUTE8);
        dbms_sql.column_value(v_cursor_id, 16, v_type.ATTRIBUTE9);
        dbms_sql.column_value(v_cursor_id, 17, v_type.ATTRIBUTE10);
        dbms_sql.column_value(v_cursor_id, 18, v_type.ATTRIBUTE11);
        dbms_sql.column_value(v_cursor_id, 19, v_type.ATTRIBUTE12);
        dbms_sql.column_value(v_cursor_id, 20, v_type.ATTRIBUTE13);
        dbms_sql.column_value(v_cursor_id, 21, v_type.ATTRIBUTE14);
        dbms_sql.column_value(v_cursor_id, 22, v_type.ATTRIBUTE15);
        dbms_sql.column_value(v_cursor_id, 23, v_type.ATTRIBUTE_CATEGORY);


        --                     'v_type.resource_req_id:'||
        --                     to_char(v_type.resource_req_id));


        v_tbl(v_cnt) := v_type;

      end loop;

      dbms_sql.close_cursor(v_cursor_id);

    end if;
    --p_query_or_next_code;

    -- copy records to be returned back

    x_total_retrieved := v_tbl.count;


    -- if table is empty do nothing
    if (x_total_retrieved > 0) then
      if (p_show_all = 'Y') then -- return all the rows
        v_start := v_tbl.first;
        v_end   := v_tbl.last;
      else
       v_start := p_start_pointer;
        v_end   := p_start_pointer + p_rec_wanted - 1;
        if (v_end > v_tbl.last) then
          v_end := v_tbl.last;
        end if;
      end if;


      for v_cnt in v_start..v_end loop
        X_TASK_RSC_REQ_REC(v_cnt) := v_tbl(v_cnt);
      end loop;
    end if;

    x_total_returned := X_TASK_RSC_REQ_REC.count;

  exception

        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get

                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
                 p_data => x_msg_data
                );
        WHEN OTHERS THEN

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
                END IF;
                FND_MSG_PUB.Count_And_Get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );


      end;


 End  ;

/
