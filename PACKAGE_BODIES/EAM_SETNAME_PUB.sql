--------------------------------------------------------
--  DDL for Package Body EAM_SETNAME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SETNAME_PUB" AS
/* $Header: EAMPPSNB.pls 120.2 2006/03/21 15:43:03 hkarmach noship $ */
/*
--      API name        : EAM_SetName_PUB
--      Type            : Public
--      Function        : Insert, update and validation of the pm set name
--      Pre-reqs        : None.
*/

/* for de-bugging */
 /* g_sr_no		number ; */

/*
This procedure inserts a record in the eam_pm_set_names table
--      Parameters      :
--      IN              :       P_API_VERSION	IN NUMBER	REQUIRED
--                              P_INIT_MSG_LIST IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_COMMIT	IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_VALIDATION_LEVEL IN NUMBER	OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--				p_set_name              IN    varchar2 ,
--				p_description	      IN    varchar2 default null,
--				p_end_date	      IN    date default null    ,
--				p_ATTRIBUTE_CATEGORY    IN    VARCHAR2 default null,
--				p_ATTRIBUTE1            IN    VARCHAR2 default null,
--				p_ATTRIBUTE2            IN    VARCHAR2 default null,
--				p_ATTRIBUTE3            IN    VARCHAR2 default null,
--				p_ATTRIBUTE4            IN    VARCHAR2 default null,
--				p_ATTRIBUTE5            IN    VARCHAR2 default null,
--				p_ATTRIBUTE6            IN    VARCHAR2 default null,
--				p_ATTRIBUTE7            IN    VARCHAR2 default null,
--				p_ATTRIBUTE8            IN    VARCHAR2 default null,
--				p_ATTRIBUTE9            IN    VARCHAR2 default null,
--				p_ATTRIBUTE10           IN    VARCHAR2 default null,
--				p_ATTRIBUTE11           IN    VARCHAR2 default null,
--				p_ATTRIBUTE12           IN    VARCHAR2 default null,
--				p_ATTRIBUTE13           IN    VARCHAR2 default null,
--				p_ATTRIBUTE14           IN    VARCHAR2 default null,
--				p_ATTRIBUTE15           IN    VARCHAR2 default null,
--				p_end_date_val_req      IN    BOOLEAN  default true ,
--
--      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
--                              x_msg_count        OUT NOCOPY    NUMBER
--                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
--				x_new_set_name_id	OUT	NOCOPY	NUMBER
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
--      NOTE: p_end_date_validate flag will be false in case of migration, meaning no end date validation required for
--		migration. If the flag is true, only in that case the Validate_FutureEndDate function will be called.
*/

PROCEDURE Insert_PMSetName
(
	p_api_version         IN	NUMBER			,
	p_init_msg_list	    IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	    IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	    IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status	    OUT	NOCOPY VARCHAR2	,
	x_msg_count	    OUT	NOCOPY NUMBER	,
	x_msg_data	    OUT	NOCOPY VARCHAR2	,
	p_set_name              IN    varchar2 ,
	p_description	      IN    varchar2 default null,
	p_end_date	      IN    date default null    ,
	p_attribute_category    IN    VARCHAR2 default null,
	p_attribute1            IN    VARCHAR2 default null,
	p_attribute2            IN    VARCHAR2 default null,
	p_attribute3            IN    VARCHAR2 default null,
	p_attribute4            IN    VARCHAR2 default null,
	p_attribute5            IN    VARCHAR2 default null,
	p_attribute6            IN    VARCHAR2 default null,
	p_attribute7            IN    VARCHAR2 default null,
	p_attribute8            IN    VARCHAR2 default null,
	p_attribute9            IN    VARCHAR2 default null,
	p_attribute10           IN    VARCHAR2 default null,
	p_attribute11           IN    VARCHAR2 default null,
	p_attribute12           IN    VARCHAR2 default null,
	p_attribute13           IN    VARCHAR2 default null,
	p_attribute14           IN    VARCHAR2 default null,
	p_attribute15           IN    VARCHAR2 default null,
	p_organization_id       IN    number default null,
	p_local_flag	        IN    VARCHAR2 default 'N' ,
	x_new_set_name_id	OUT	NOCOPY	NUMBER ,
	--p_end_date_val_req      IN    BOOLEAN  default true
	p_end_date_val_req      IN    varchar2  default 'true'
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:='insert set name';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_set_name_id		NUMBER;
l_validated		boolean;
x_error_segments        NUMBER;
x_error_message         VARCHAR2(5000);
BEGIN

	/* Standard Start of API savepoint */
	SAVEPOINT Insert_PMSetName_PUB;

	/* Standard call to check for call compatibility. */
	IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME
					   )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	/* Initialize message list if p_init_msg_list is set to TRUE. */
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	/* Initialize API return status to success */
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	/* API body */
	/* Start validation calls */

	if (p_set_name is null) then
		raise_error('EAM_SET_NAME_NULL');
	end if;

	l_validated := Validate_SetNameUnique (p_set_name);
	IF (not l_validated) THEN
                raise_error('EAM_DUPLICATE_SETNAME');
        END IF;


	IF (p_end_date_val_req = 'true') THEN

		l_validated := Validate_FutureEndDate (p_end_date);
		IF (not l_validated) THEN
			raise_error('EAM_INVALID_END_DATE');
		END IF;

	END IF;

	/* validating the local flag */
	if nvl(p_local_flag, 'N') = 'Y' then
		if p_organization_id is null then
	 	        FND_MESSAGE.SET_NAME('EAM','EAM_PM_ORGID_REQUIRED');
	 	        FND_MSG_PUB.Add;
 		        RAISE FND_API.G_EXC_ERROR;
		end if;
	end if;


	/* Validating the DFF */

	l_validated := EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field (
						p_app_short_name	=>	'EAM',
						p_desc_flex_name	=>	'EAM_PM_SET_NAME',
						p_ATTRIBUTE_CATEGORY    =>	p_attribute_category ,
						p_ATTRIBUTE1            =>	p_attribute1          ,
						p_ATTRIBUTE2            =>	p_attribute2           ,
						p_ATTRIBUTE3            =>	p_attribute3            ,
						p_ATTRIBUTE4            =>	p_attribute4            ,
						p_ATTRIBUTE5            =>	p_attribute5            ,
						p_ATTRIBUTE6            =>	p_attribute6            ,
						p_ATTRIBUTE7            =>	p_attribute7            ,
						p_ATTRIBUTE8            =>	p_attribute8            ,
						p_ATTRIBUTE9            =>	p_attribute9            ,
						p_ATTRIBUTE10           =>	p_attribute10           ,
						p_ATTRIBUTE11           =>	p_attribute11           ,
						p_ATTRIBUTE12           =>	p_attribute12           ,
						p_ATTRIBUTE13           =>	p_attribute13           ,
						p_ATTRIBUTE14           =>	p_attribute14           ,
						p_ATTRIBUTE15           =>	p_attribute15 ,
						x_error_segments	=>	x_error_segments ,
						x_error_message		=>	x_error_message);
	IF (not l_validated) THEN
		  FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_DESC_FLEX');
		  FND_MESSAGE.SET_TOKEN('ERROR_MSG', x_error_message);
		  FND_MSG_PUB.Add;
		  RAISE FND_API.G_EXC_ERROR;
	END IF;


	/* End validation calls */

	SELECT EAM_PM_SET_NAMES_S.NEXTVAL INTO L_SET_NAME_ID FROM DUAL;

	X_NEW_SET_NAME_ID := L_SET_NAME_ID;

	INSERT INTO eam_pm_set_names
	(
		set_name_id           ,
		set_name              ,
		description           ,
		end_date              ,
		last_update_date      ,
		last_updated_by       ,
		creation_date         ,
		created_by            ,
		last_update_login     ,
		attribute_category    ,
		attribute1            ,
		attribute2            ,
		attribute3            ,
		attribute4            ,
		attribute5            ,
		attribute6            ,
		attribute7            ,
		attribute8            ,
		attribute9            ,
		attribute10           ,
		attribute11           ,
		attribute12           ,
		attribute13           ,
		attribute14           ,
		attribute15	      ,
		owning_organization_id,
		local_flag
	)
	VALUES
	(
		l_set_name_id		,
		p_set_name		 ,
		p_description	    	,
		p_end_date		,
		SYSDATE			,
		FND_GLOBAL.USER_ID	,
	        SYSDATE			,
		FND_GLOBAL.LOGIN_ID	,
		FND_GLOBAL.USER_ID	,
		p_attribute_category,
		p_attribute1        ,
		p_attribute2        ,
	        p_attribute3        ,
		p_attribute4        ,
	        p_attribute5        ,
		p_attribute6        ,
		p_attribute7        ,
		p_attribute8        ,
		p_attribute9        ,
		p_attribute10       ,
		p_attribute11       ,
		p_attribute12       ,
		p_attribute13       ,
		p_attribute14       ,
		p_attribute15       ,
		p_organization_id   ,
		p_local_flag
	);

	/* Standard check of p_commit. */
	IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN
		COMMIT WORK;
	END IF;
	/* Standard call to get message count and if count is 1, get message info. */
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		ROLLBACK TO Insert_PMSetName_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		ROLLBACK TO Insert_PMSetName_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN OTHERS THEN

		ROLLBACK TO Insert_PMSetName_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  		IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME ,
    	    			l_api_name
	    		);
		END IF;

		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

END Insert_PMSetName;


/*
This procedure updates a record in the eam_pm_set_names table
--      Parameters      :
--      IN              :       P_API_VERSION	IN NUMBER	REQUIRED
--                              P_INIT_MSG_LIST IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_COMMIT	IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_VALIDATION_LEVEL IN NUMBER	OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--
--
--      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
--                              x_msg_count        OUT NOCOPY    NUMBER
--                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
--      NOTE: p_end_date_validate flag will be false in case of migration, meaning no end date validation required for
--		migration. If the flag is true, only in that case the Validate_FutureEndDate function will be called.
*/

PROCEDURE Update_PMSetName
(
	p_api_version          IN	  NUMBER			,
	p_init_msg_list	    IN	  VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	    IN  	  VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	    IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status	    OUT	NOCOPY  VARCHAR2 ,
	x_msg_count	    OUT	NOCOPY  NUMBER	  ,
	x_msg_data	    OUT	NOCOPY  VARCHAR2 ,
	p_set_name_id          IN    NUMBER   ,
	p_set_name             IN    VARCHAR2 ,
	p_description	     IN    VARCHAR2 default null,
	p_end_date	     IN    DATE default null    ,
	p_attribute_category    IN    VARCHAR2 default null,
	p_attribute1            IN    VARCHAR2 default null,
	p_attribute2            IN    VARCHAR2 default null,
	p_attribute3            IN    VARCHAR2 default null,
	p_attribute4            IN    VARCHAR2 default null,
	p_attribute5            IN    VARCHAR2 default null,
	p_attribute6            IN    VARCHAR2 default null,
	p_attribute7            IN    VARCHAR2 default null,
	p_attribute8            IN    VARCHAR2 default null,
	p_attribute9            IN    VARCHAR2 default null,
	p_attribute10           IN    VARCHAR2 default null,
	p_attribute11           IN    VARCHAR2 default null,
	p_attribute12           IN    VARCHAR2 default null,
	p_attribute13           IN    VARCHAR2 default null,
	p_attribute14           IN    VARCHAR2 default null,
	p_attribute15           IN    VARCHAR2 default null,
	p_organization_id       IN    number default null,
	p_local_flag	        IN    VARCHAR2 default 'N',
	p_end_date_val_req      IN    varchar2  default 'true'
)
IS

l_api_name			CONSTANT VARCHAR2(30)	:='update set name';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_validated			boolean;
x_error_segments        NUMBER;
x_error_message         VARCHAR2(5000);

l_exists varchar2(1) := 'N';

l_end_date              DATE;
l_local_flag		varchar2(1);

l_set_name_id number;

BEGIN

	/* Standard Start of API savepoint */
	SAVEPOINT Update_PMSetName_PUB;

	/* Standard call to check for call compatibility. */
	IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME
					   )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	/* Initialize message list if p_init_msg_list is set to TRUE. */
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	/* Initialize API return status to success */
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	/* API body */
	/* Start validation calls */
	if (p_set_name is null) then
		raise_error('EAM_SET_NAME_NULL');
	end if;

	if p_set_name_id is null then
		select set_name_id into l_set_name_id
		from eam_pm_set_names
		where set_name = p_set_name;
	else
		l_set_name_id := p_set_name_id;
	end if;


	IF (p_end_date_val_req = 'true') THEN

		l_validated := Validate_FutureEndDate (p_end_date);
		IF (not l_validated) THEN
			--raise_error('END_DATE_NOT_IN_FUTURE');
			raise_error('EAM_INVALID_END_DATE');
		END IF;

	END IF;

	l_validated := Validate_SetName (l_set_name_id, p_set_name);

		IF (not l_validated) THEN
			--raise_error('SET_NAME_MUST_EXIST');
			raise_error('EAM_INVALID_SET_NAME');
		END IF;

	/* Validating the DFF */

	l_validated := EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field (
				p_app_short_name	=>	'EAM',
				p_desc_flex_name	=>	'EAM_PM_SET_NAME',
				p_ATTRIBUTE_CATEGORY    =>	p_attribute_category ,
				p_ATTRIBUTE1            =>	p_attribute1          ,
				p_ATTRIBUTE2            =>	p_attribute2           ,
				p_ATTRIBUTE3            =>	p_attribute3            ,
				p_ATTRIBUTE4            =>	p_attribute4            ,
				p_ATTRIBUTE5            =>	p_attribute5            ,
				p_ATTRIBUTE6            =>	p_attribute6            ,
				p_ATTRIBUTE7            =>	p_attribute7            ,
				p_ATTRIBUTE8            =>	p_attribute8            ,
				p_ATTRIBUTE9            =>	p_attribute9            ,
				p_ATTRIBUTE10           =>	p_attribute10           ,
				p_ATTRIBUTE11           =>	p_attribute11           ,
				p_ATTRIBUTE12           =>	p_attribute12           ,
				p_ATTRIBUTE13           =>	p_attribute13           ,
				p_ATTRIBUTE14           =>	p_attribute14           ,
				p_ATTRIBUTE15           =>	p_attribute15 ,
				x_error_segments	=>	x_error_segments ,
				x_error_message		=>	x_error_message);

	IF (not l_validated) THEN
	  --raise_error(x_error_message);
	  FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_DESC_FLEX');
	  FND_MESSAGE.SET_TOKEN('ERROR_MSG', x_error_message);
	  FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;

        END IF;
	--added to check whether the end date is allowed.
	-- we will not be allowing the updation of end date od seeded set names.

	  BEGIN
 	       SELECT end_date, local_flag
 	         INTO l_end_date, l_local_flag
 	         FROM eam_pm_set_names
 	        WHERE set_name_id = l_set_name_id;
 	     EXCEPTION
 	       WHEN NO_DATA_FOUND THEN
 	         raise_error('EAM_INVALID_SET_NAME');
 	     END;


 	    IF (    l_set_name_id = 1
 	         AND (
 	                (p_end_date is null and l_end_date is not null)
 	             OR (p_end_date is not null and l_end_date is null)
 	             OR (p_end_date <> l_end_date)
 	             )
 	        )
 	    THEN
 	        FND_MESSAGE.SET_NAME('EAM','EAM_SETNAME_SEED_DATE_NOUPD');
 	        FND_MSG_PUB.Add;
 	        RAISE FND_API.G_EXC_ERROR;
 	    END IF;



	--validation for local flag
	if nvl(p_local_flag, 'N') = 'Y' then

		if l_set_name_id = 1 then
	 	        FND_MESSAGE.SET_NAME('EAM','EAM_MAIN_GLOBAL');
	 	        FND_MSG_PUB.Add;
 		        RAISE FND_API.G_EXC_ERROR;
		end if;

		if p_organization_id is null then
	 	        FND_MESSAGE.SET_NAME('EAM','EAM_PM_ORGID_REQUIRED');
	 	        FND_MSG_PUB.Add;
 		        RAISE FND_API.G_EXC_ERROR;
		end if;

		if nvl(l_local_flag, 'N') = 'N' then

			begin
				select 'Y' into l_exists from dual
				where exists
				(
					select eps.*
					from eam_pm_schedulings eps, csi_item_instances cii, mtl_parameters mp
					where eps.set_name_id = l_set_name_id
					and eps.maintenance_object_id = cii.instance_id
					and cii.last_vld_organization_id = mp.organization_id
					and mp.maint_organization_id <> p_organization_id
				);
			exception
				when no_data_found then
					l_exists := 'N';
			end;

			if l_exists = 'Y' then
	 	        	FND_MESSAGE.SET_NAME('EAM','EAM_PM_SCHEDULE_EXISTS');
	 	        	FND_MESSAGE.SET_TOKEN('ENTITY1', p_set_name);
	 		        FND_MSG_PUB.Add;
 		       		RAISE FND_API.G_EXC_ERROR;
			end if;
		end if;
	end if;


	/* End validation calls */


	UPDATE
		eam_pm_set_names
	SET
		set_name         =  		p_set_name          		,
		description       = 		p_description	    		,
		end_date           =		p_end_date	    		,

		attribute_category =		p_attribute_category     	,
		attribute1         =		p_attribute1             	,
		attribute2         =		p_attribute2             	,
		attribute3         =		p_attribute3             	,
		attribute4         =		p_attribute4             	,
		attribute5         =		p_attribute5             	,
		attribute6         =		p_attribute6             	,
		attribute7         =		p_attribute7             	,
		attribute8         =		p_attribute8             	,
		attribute9         =		p_attribute9             	,
		attribute10        =		p_attribute10            	,
		attribute11        =		p_attribute11            	,
		attribute12        =		p_attribute12            	,
		attribute13        =		p_attribute13            	,
		attribute14        =		p_attribute14            	,
		attribute15    	=		p_attribute15			,

		owning_organization_id =	p_organization_id		,
		local_flag	=		p_local_flag
	WHERE
		set_name_id = l_set_name_id;


	/* Standard check of p_commit. */
	IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN
		COMMIT WORK;
	END IF;
	/* Standard call to get message count and if count is 1, get message info. */
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);



EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		ROLLBACK TO Update_PMSetName_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		ROLLBACK TO Update_PMSetName_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN OTHERS THEN

		ROLLBACK TO Update_PMSetName_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME ,
    	    			l_api_name
	    		);
		END IF;

		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

END Update_PMSetName;

/* validate set name exists at the time of update */
FUNCTION Validate_SetName
	(p_set_name_id NUMBER, p_set_name varchar2)
	return boolean
IS
	l_status number;
BEGIN

	SELECT
		count (*) into l_status
	FROM
		eam_pm_set_names
	WHERE
		set_name_id = p_set_name_id
		and set_name=p_set_name;

	IF l_status > 0 THEN

		RETURN TRUE;
	ELSE

		RETURN FALSE;
	END IF;

END Validate_SetName;

/* Validate set name is unique at the time of insert */
FUNCTION Validate_SetNameUnique
	(p_set_name VARCHAR2)
	return boolean
IS
	l_status number;
BEGIN

	SELECT
		count(*) into l_status
	FROM
		eam_pm_set_names
	WHERE
		set_name = p_set_name ;

	IF l_status = 0 THEN

		RETURN TRUE;
	ELSE

		RETURN FALSE;
	END IF;

END Validate_SetNameUnique;

/* Validating end date in future */
FUNCTION Validate_FutureEndDate
	(p_end_date DATE)
	return boolean
IS
	l_status varchar2 (10);
BEGIN
	if p_end_date is null then
		return true;
	end if;

	SELECT
		'PASS' into l_status
	FROM
		dual
	WHERE
		p_end_date > sysdate;

	IF (l_status = 'PASS') THEN

		RETURN TRUE;
	ELSE

		RETURN FALSE;
	END IF;
exception
	when no_data_found then
		return false;
END Validate_FutureEndDate;

/* private procedure for raising exceptions */

PROCEDURE RAISE_ERROR (ERROR VARCHAR2)
IS
BEGIN
	FND_MESSAGE.SET_NAME ('EAM', ERROR);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END;

PROCEDURE print_log(info varchar2) is
PRAGMA  AUTONOMOUS_TRANSACTION;
l_dummy number;
BEGIN

 /*if (g_sr_no is null or g_sr_no<0) then
		g_sr_no := 0;
	end if;

	g_sr_no := g_sr_no+1;

	INSERT into temp_isetup(msg,sr_no)
	VALUES (info,g_sr_no);

	commit;*/

  FND_FILE.PUT_LINE(FND_FILE.LOG, info);

END;

END EAM_SetName_PUB;

/
