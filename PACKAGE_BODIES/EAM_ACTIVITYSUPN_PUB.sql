--------------------------------------------------------
--  DDL for Package Body EAM_ACTIVITYSUPN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ACTIVITYSUPN_PUB" AS
/* $Header: EAMPASRB.pls 120.2 2005/11/25 10:01:56 sshahid noship $ */

/*
--      API name        : EAM_ActivitySupn_PUB
--      Type            : Public
--      Function        : Insert, update and validation of the activity suppression
--      Pre-reqs        : None.
*/

/* for de-bugging */
/* g_sr_no		number ; */


/*
This procedure inserts a record in the eam_suppression_relations table
     Parameters      :
     IN              :          P_API_VERSION	IN	NUMBER			,
				P_INIT_MSG_LIST	IN	VARCHAR2 := FND_API.G_FALSE	,
				P_COMMIT	IN  	VARCHAR2 := FND_API.G_FALSE	,
				P_VALIDATION_LEVEL	IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
				P_PARENT_ASSOCIATION_ID IN	NUMBER    ,
				P_CHILD_ASSOCIATION_ID  IN	NUMBER    ,
				P_TMPL_FLAG		IN	VARCHAR2 DEFAULT NULL,
				P_DESCRIPTION		IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE_CATEGORY    IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE1            IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE2            IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE3            IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE4            IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE5            IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE6            IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE7            IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE8            IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE9            IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE10           IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE11           IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE12           IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE13           IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE14           IN	VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE15           IN	VARCHAR2 DEFAULT NULL,

		OUT         :	x_return_status    OUT NOCOPY    VARCHAR2(1)
				x_msg_count        OUT NOCOPY    NUMBER
                                x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
		Version :       Current version: 1.0
				Initial version: 1.0
*/

PROCEDURE Insert_ActivitySupn
(
	p_api_version		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2	,
	x_msg_count		OUT	NOCOPY NUMBER	,
	x_msg_data		OUT	NOCOPY VARCHAR2	,
	p_parent_association_id IN	NUMBER    ,
	p_child_association_id  IN	NUMBER    ,
	p_tmpl_flag		IN	VARCHAR2 DEFAULT NULL,
	p_description		IN	VARCHAR2 DEFAULT NULL,
	p_attribute_category    IN	VARCHAR2 DEFAULT NULL,
	p_attribute1            IN	VARCHAR2 DEFAULT NULL,
	p_attribute2            IN	VARCHAR2 DEFAULT NULL,
	p_attribute3            IN	VARCHAR2 DEFAULT NULL,
	p_attribute4            IN	VARCHAR2 DEFAULT NULL,
	p_attribute5            IN	VARCHAR2 DEFAULT NULL,
	p_attribute6            IN	VARCHAR2 DEFAULT NULL,
	p_attribute7            IN	VARCHAR2 DEFAULT NULL,
	p_attribute8            IN	VARCHAR2 DEFAULT NULL,
	p_attribute9            IN	VARCHAR2 DEFAULT NULL,
	p_attribute10           IN	VARCHAR2 DEFAULT NULL,
	p_attribute11           IN	VARCHAR2 DEFAULT NULL,
	p_attribute12           IN	VARCHAR2 DEFAULT NULL,
	p_attribute13           IN	VARCHAR2 DEFAULT NULL,
	p_attribute14           IN	VARCHAR2 DEFAULT NULL,
	p_attribute15           IN	VARCHAR2 DEFAULT NULL
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:='insert activity suppression';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_validated			boolean;
x_error_segments        NUMBER;
x_error_message         VARCHAR2(5000);
BEGIN

	/* Standard Start of API savepoint */
	SAVEPOINT Insert_ActivitySupn_PUB;

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

	l_validated := Validate_AssociationId (p_parent_association_id);
	if (not l_validated) then
		--raise_error('Parent association is NOT valid');
		raise_error('EAM_INVALID_PARENT_ASSOC_ID');
        end if;

	l_validated := Validate_AssociationId (p_child_association_id);
	if (not l_validated) then
		--raise_error('Child association is NOT valid');
		raise_error('EAM_INVALID_CHILD_ASSOC_ID');
        end if;

	/* Validate the tmpl_falg value */
	l_validated := EAM_COMMON_UTILITIES_PVT.validate_boolean_flag(p_tmpl_flag);
	IF (not l_validated) THEN
		raise_error ('EAM_INVALID_TMPL_FLAG');
	END IF;

	l_validated := Validate_MaintainedObjUnique (p_parent_association_id,
							p_child_association_id,
							p_tmpl_flag);
	if (not l_validated) then
		--raise_error('Asset NOT Unique');
		raise_error('EAM_DUPLICATE_ASSET');
        end if;

	/* l_validated := Validate_ParentChildAssets (p_parent_association_id,
							p_child_association_id);
	*/

	l_validated := eam_pm_suppressions.check_no_loop (p_parent_association_id,
							p_child_association_id);
	if (not l_validated) then
		--raise_error('Child activity cannot suppress its Parent activity');
		raise_error('EAM_INVALID_SUPPRESSION');
        end if;

	/* Validating the DFF */

	l_validated := EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field (
			p_app_short_name	=>	'EAM',
			p_desc_flex_name	=>	'EAM_SUPPRESSIONS',
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

	/* Validate the parent and childs asset-activity combination does not exists */

	l_validated := Validate_SuppressionRecord (p_parent_association_id,
						p_child_association_id );
	IF l_validated THEN
		raise_error ('EAM_DUPLICATE_SUPPRESSION');
	END IF;


	/* End validation calls */


		INSERT INTO eam_suppression_relations
		(
			parent_association_id   ,
			child_association_id	,
/*	(ignored)	day_tolerance		,
	(ignored)	runtime_tolerance	,
*/
			tmpl_flag	,
			description     ,
			created_by      ,
			creation_date   ,
			last_update_login     ,
			last_update_date      ,
			last_updated_by       ,
			attribute_category    ,
			attribute1	,
			attribute2	,
			attribute3	,
			attribute4	,
			attribute5	,
			attribute6	,
			attribute7	,
			attribute8	,
			attribute9	,
			attribute10	,
			attribute11	,
			attribute12	,
			attribute13	,
			attribute14	,
			attribute15
		)
		VALUES
		(
			p_parent_association_id	,
			p_child_association_id  ,
			p_tmpl_flag		,
			p_description		,
			FND_GLOBAL.USER_ID	,
			SYSDATE			,
			FND_GLOBAL.LOGIN_ID	,
			SYSDATE			,
			FND_GLOBAL.USER_ID	,
			p_attribute_category    ,
			p_attribute1            ,
			p_attribute2            ,
			p_attribute3            ,
			p_attribute4            ,
			p_attribute5            ,
			p_attribute6            ,
			p_attribute7            ,
			p_attribute8            ,
			p_attribute9            ,
			p_attribute10           ,
			p_attribute11           ,
			p_attribute12           ,
			p_attribute13           ,
			p_attribute14           ,
			p_attribute15
		);

	/* Standard check of p_commit. */
	IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Insert_ActivitySupn_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Insert_ActivitySupn_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		ROLLBACK TO Insert_ActivitySupn_PUB;
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

END Insert_ActivitySupn;


/*
This procedure updates a record in the eam_asset_meters table
      Parameters      :
      IN              :         P_API_VERSION           IN	NUMBER			,
				P_INIT_MSG_LIST	    IN	VARCHAR2 := FND_API.G_FALSE	,
				P_COMMIT	    	    IN  	VARCHAR2 := FND_API.G_FALSE	,
				P_VALIDATION_LEVEL	    IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
				X_RETURN_STATUS	    OUT	NOCOPY VARCHAR2	 ,
				X_MSG_COUNT	    OUT	NOCOPY NUMBER	 ,
				X_MSG_DATA	    	    OUT	NOCOPY VARCHAR2  ,
				P_PARENT_ASSOCIATION_ID IN    NUMBER    ,
				P_CHILD_ASSOCIATION_ID  IN    NUMBER    ,
				P_TMPL_FLAG	    IN	VARCHAR2 DEFAULT NULL,
				P_DESCRIPTION	    IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE_CATEGORY   IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE1           IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE2           IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE3           IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE4           IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE5           IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE6           IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE7           IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE8           IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE9           IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE10          IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE11          IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE12          IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE13          IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE14          IN    VARCHAR2 DEFAULT NULL,
				P_ATTRIBUTE15          IN    VARCHAR2 DEFAULT NULL


      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
                              x_msg_count        OUT NOCOPY    NUMBER
                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
      Version :       Current version: 1.0
                      Initial version: 1.0
*/
PROCEDURE Update_ActivitySupn
(
	p_api_version		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY  VARCHAR2 ,
	x_msg_count		OUT	NOCOPY  NUMBER	  ,
	x_msg_data		OUT	NOCOPY  VARCHAR2 ,
	p_parent_association_id IN	NUMBER    ,
	p_child_association_id  IN	NUMBER    ,
	p_tmpl_flag		IN	VARCHAR2 DEFAULT NULL,
	p_description		IN	VARCHAR2 DEFAULT NULL,
	p_attribute_category	IN	VARCHAR2 DEFAULT NULL,
	p_attribute1		IN	VARCHAR2 DEFAULT NULL,
	p_attribute2		IN	VARCHAR2 DEFAULT NULL,
	p_attribute3		IN	VARCHAR2 DEFAULT NULL,
	p_attribute4		IN	VARCHAR2 DEFAULT NULL,
	p_attribute5		IN	VARCHAR2 DEFAULT NULL,
	p_attribute6		IN	VARCHAR2 DEFAULT NULL,
	p_attribute7		IN	VARCHAR2 DEFAULT NULL,
	p_attribute8		IN	VARCHAR2 DEFAULT NULL,
	p_attribute9		IN	VARCHAR2 DEFAULT NULL,
	p_attribute10		IN	VARCHAR2 DEFAULT NULL,
	p_attribute11		IN	VARCHAR2 DEFAULT NULL,
	p_attribute12		IN	VARCHAR2 DEFAULT NULL,
	p_attribute13		IN	VARCHAR2 DEFAULT NULL,
	p_attribute14		IN	VARCHAR2 DEFAULT NULL,
	p_attribute15		IN	VARCHAR2 DEFAULT NULL
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:='update activity suppression';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_validated			boolean;
x_error_segments        NUMBER;
x_error_message         VARCHAR2(5000);
BEGIN

	/* Standard Start of API savepoint */
	SAVEPOINT Update_ActivitySupn_PUB;
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
	/* validation calls */
	l_validated := Validate_SuppressionRecord (p_parent_association_id,
						   p_child_association_id);
	if (not l_validated) then
		--raise_error('NO_RECORD FOR UPDATE');
		raise_error('EAM_RECORD_DOES_NOT_EXIST');
        end if;

	/* Validating the DFF */

	l_validated := EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field (
			p_app_short_name	=>	'EAM',
			p_desc_flex_name	=>	'EAM_SUPPRESSIONS',
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
		IF (not l_validated) THEN
		  FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_DESC_FLEX');
		  FND_MESSAGE.SET_TOKEN('ERROR_MSG', x_error_message);
		  FND_MSG_PUB.Add;
		  RAISE FND_API.G_EXC_ERROR;
		END IF;
        END IF;

	l_validated := eam_pm_suppressions.check_no_loop (p_parent_association_id,
							p_child_association_id);
	if (not l_validated) then
		--raise_error('Child activity cannot suppress its Parent activity');
		raise_error('EAM_INVALID_SUPPRESSION');
        end if;

	/* validation calls finish */


		UPDATE
			eam_suppression_relations
		SET
			description		= p_description	,
			attribute_category	= p_attribute_category	,
			attribute1		= p_attribute1	,
			attribute2		= p_attribute2	,
			attribute3		= p_attribute3	,
			attribute4		= p_attribute4	,
			attribute5		= p_attribute5	,
			attribute6		= p_attribute6	,
			attribute7		= p_attribute7	,
			attribute8		= p_attribute8	,
			attribute9		= p_attribute9	,
			attribute10		= p_attribute10	,
			attribute11		= p_attribute11	,
			attribute12		= p_attribute12	,
			attribute13		= p_attribute13	,
			attribute14		= p_attribute14	,
			attribute15		= p_attribute15
		WHERE
			parent_association_id = p_parent_association_id
		AND
			child_association_id  = p_child_association_id ;
	/* Standard check of p_commit. */
	IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_ActivitySupn_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_ActivitySupn_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		ROLLBACK TO Update_ActivitySupn_PUB;
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

END Update_ActivitySupn;

/* Functions */
/* validate org eam enabled */
FUNCTION Validate_EamEnabled (p_organization_id NUMBER)
	RETURN boolean
IS
/*	l_status varchar2 (10);*/

	l_boolean NUMBER;
	l_return_status VARCHAR2 (10);
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(5000);
BEGIN

	/*SELECT 'Enabled' INTO l_status
	FROM mtl_parameters
	WHERE organization_id = p_organization_id
	AND NVL(EAM_ENABLED_FLAG, 'N') = 'Y';

	IF (l_status = 'Enabled') THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;*/

	eam_common_utilities_pvt.verify_org (
                      p_resp_id		=> NULL,
                      p_resp_app_id	=> 401,
                      p_org_id		=> p_organization_id,
                      p_init_msg_list	=> FND_API.G_FALSE,
                      x_boolean		=> l_boolean,
                      x_return_status	=> l_return_status,
                      x_msg_count	=> l_msg_count,
                      x_msg_data	=> l_msg_data);
/* x_return_status := fnd_api.g_ret_sts_success; */
	IF (l_return_status = fnd_api.g_ret_sts_success) THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;

END Validate_EamEnabled;

/* CHECK THE SUPPRESSION RECORD EXISTS, FOR UPDATE CASE */
FUNCTION Validate_SuppressionRecord (p_parent_association_id NUMBER,
					p_child_association_id NUMBER)
	RETURN boolean
IS
	l_status varchar2(10);
BEGIN
	SELECT 'Exists' INTO l_status
	FROM eam_suppression_relations
	WHERE parent_association_id = p_parent_association_id
	AND child_association_id = p_child_association_id;

	IF (l_status = 'Exists') THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;
EXCEPTION
WHEN no_data_found THEN
	RETURN false;

END Validate_SuppressionRecord ;

/* CHECK THE PARENT ASSOCIATION ID AND CHILD ASSOCIATION ID SHOULD NOT INTERCHANGE */
FUNCTION Validate_ParentChildAssets (p_parent_association_id NUMBER,
					p_child_association_id NUMBER)
	RETURN boolean
IS
	l_count number;
	l_status varchar2(10);
BEGIN

	SELECT count(*) INTO l_count
	FROM eam_suppression_relations a, eam_suppression_relations b
	WHERE a.parent_association_id = b.child_association_id
	AND a.child_association_id = b.parent_association_id
	AND a.parent_association_id = p_parent_association_id
	AND a.child_association_id  = p_child_association_id;

	IF (l_count = 0) THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;
EXCEPTION
WHEN no_data_found THEN
	RETURN false;
END Validate_ParentChildAssets ;


/* For checking the association_id exists in the mtl_eam_asset_activities table */
FUNCTION Validate_AssociationId (p_association_id NUMBER)
	RETURN boolean
IS
	l_status varchar2(10);
BEGIN

	SELECT 'Exists' INTO l_status
	FROM  mtl_eam_asset_activities
	WHERE ACTIVITY_ASSOCIATION_ID = p_association_id;

	if (l_status = 'Exists') then
		RETURN true;
	else
		RETURN false;
	end if;
EXCEPTION
WHEN no_data_found THEN
	RETURN false;
END Validate_AssociationId ;


/* For checking the asset/item is the same for both parent and child activity association */
FUNCTION Validate_MaintainedObjUnique (p_parent_association_id NUMBER,
					p_child_association_id number,
					p_tmpl_flag varchar2)
	RETURN boolean
IS
	l_parent_assoc number;
	l_child_assoc number;
	l_parent_organization_id number;
	l_child_organization_id number;
	l_parent_ser_num VARCHAR2(30) := null;
	l_child_ser_num VARCHAR2(30) := null;

	l_parent_object_id number;
	l_parent_object_type number;
	l_child_object_id number;
	l_child_object_type number;

	l_status varchar2(10);
	l_tmpl_flag_p char (1);
	l_tmpl_flag_c char (1);

BEGIN
/*

--commented out this section to use Maintenance Object ID and Type

	IF p_tmpl_flag = 'Y' THEN
		SELECT inventory_item_id , organization_id , tmpl_flag
		INTO l_parent_assoc , l_parent_organization_id, l_tmpl_flag_p
		FROM mtl_eam_asset_activities
		WHERE activity_association_id = p_parent_association_id;

		SELECT inventory_item_id , organization_id , tmpl_flag
		INTO l_child_assoc , l_child_organization_id, l_tmpl_flag_c
		FROM mtl_eam_asset_activities
		WHERE activity_association_id = p_child_association_id;
	ELSE
		SELECT inventory_item_id , serial_number , organization_id, tmpl_flag
		INTO l_parent_assoc , l_parent_ser_num , l_parent_organization_id, l_tmpl_flag_p
		FROM mtl_eam_asset_activities
		WHERE activity_association_id = p_parent_association_id;

		SELECT inventory_item_id , serial_number , organization_id, tmpl_flag
		INTO l_child_assoc , l_child_ser_num , l_child_organization_id, l_tmpl_flag_c
		FROM mtl_eam_asset_activities
		WHERE activity_association_id = p_child_association_id;
	END IF;

	IF (l_parent_assoc = l_child_assoc AND
		l_parent_organization_id = l_child_organization_id) THEN
--		IF (NOT p_tmpl_flag = 'Y') THEN
		IF ((l_tmpl_flag_p IS NULL OR l_tmpl_flag_p IN ('N'))
		AND (l_tmpl_flag_c IS NULL OR l_tmpl_flag_c IN ('N'))
		AND  p_tmpl_flag IN ('N') ) THEN

			IF (l_parent_ser_num = l_child_ser_num) THEN
				RETURN true;
			ELSE
				RETURN false;
			END IF;
--		 ELSIF (l_parent_ser_num IS NULL AND l_child_ser_num IS NULL) THEN

		ELSIF (l_tmpl_flag_p in ( 'Y' ) AND l_tmpl_flag_c in ( 'Y' ) AND p_tmpl_flag in ('Y')) THEN
			RETURN true;
                ELSE
		        -- Bug # 3518888
                        RAISE_ERROR('EAM_IAA_INV_TEML_FLAG');
		END IF;

	ELSE
		RETURN false;
	END IF;
*/

	select maintenance_object_id, maintenance_object_type, tmpl_flag
	into l_parent_object_id, l_parent_object_type, l_tmpl_flag_p
	from  mtl_eam_asset_activities
	WHERE activity_association_id = p_parent_association_id;

	select maintenance_object_id, maintenance_object_type, tmpl_flag
	into l_child_object_id, l_child_object_type, l_tmpl_flag_c
	from  mtl_eam_asset_activities
	WHERE activity_association_id = p_child_association_id;


	IF (((l_tmpl_flag_p IS NULL OR l_tmpl_flag_p IN ('N'))
		AND (l_tmpl_flag_c IS NULL OR l_tmpl_flag_c IN ('N'))
		AND  p_tmpl_flag IN ('N')) or

		(l_tmpl_flag_p in ( 'Y' ) AND l_tmpl_flag_c in ( 'Y' ) AND p_tmpl_flag in ('Y'))) then

		IF (l_parent_object_id = l_child_object_id AND
			l_parent_object_type = l_child_object_type) THEN
			RETURN true;
		ELSE
			RETURN false;
		END IF;
	ELSE
		        -- Bug # 3518888
                RAISE_ERROR('EAM_IAA_INV_TEML_FLAG');
	END IF;

EXCEPTION
	WHEN no_data_found THEN
		RETURN false;

END Validate_MaintainedObjUnique ;


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
/*
if (g_sr_no is null or g_sr_no<0) then
		g_sr_no := 0;
	end if;

	g_sr_no := g_sr_no+1;

	INSERT into temp_isetup_api(msg,sr_no)
	VALUES (info,g_sr_no);

	commit;
*/
FND_FILE.PUT_LINE(FND_FILE.LOG, info);

END;

END EAM_ActivitySupn_PUB;

/
