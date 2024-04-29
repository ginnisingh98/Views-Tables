--------------------------------------------------------
--  DDL for Package Body ICX_RELATED_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_RELATED_TEMPLATES_PUB" AS
/* $Header: ICXPTMPB.pls 115.1 99/07/17 03:21:03 porting ship $ */


PROCEDURE Insert_Relation
( p_api_version_number 	IN	NUMBER			    		,
  p_init_msg_list	IN  	VARCHAR2 := FND_API.G_FALSE		,
  p_simulate		IN	VARCHAR2 := FND_API.G_FALSE 		,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE 		,
  p_validation_level	IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
  p_return_status	OUT 	VARCHAR2				,
  p_msg_count		OUT	NUMBER					,
  p_msg_data		OUT 	VARCHAR2	    			,
  p_template		IN	VARCHAR2 DEFAULT NULL			,
  p_related_template	IN	VARCHAR2 DEFAULT NULL			,
  p_relationship_type	IN 	VARCHAR2				,
  p_created_by		IN      NUMBER
) IS


l_api_version_number    CONSTANT    NUMBER  :=  1.0;
l_validation_error	BOOLEAN		    := FALSE;
l_title       		varchar2(80);
l_prompts     		icx_util.g_prompts_table;
l_count			NUMBER;

BEGIN

    --  Standard Start of API savepoint

    SAVEPOINT Insert_Relation_PUB;


    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call(l_api_version_number,
        p_api_version_number,
	'Insert_Relation',
	G_PKG_NAME)
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --  Initialize message list if p_init_msg_list is set to TRUE

    IF FND_API.to_Boolean(p_init_msg_list) THEN
 	FND_MSG_PUB.initialize;
    END IF;


    --  Initialize p_return_status
    p_return_status := FND_API.G_RET_STS_SUCCESS;


    --  Get prompts table for translation of messages
    icx_util.getPrompts(601,'ICX_RELATED_TEMPLATES_R',l_title,l_prompts);


    --  Perform manditory validation

	-- check that necessary in parameters are present
	if (p_template is null or
	    p_related_template is null) then

	    if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		-- add message: Required API parameters are missing
		FND_MESSAGE.SET_NAME('ICX','ICX_API_MISS_PARAM');
		FND_MSG_PUB.Add;
	    end if;
	    RAISE FND_API.G_EXC_ERROR;
	end if;




    --	Perform validation
    IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN

	-- check template
	    select count(*) into l_count
   	    from   po_reqexpress_headers
	    where  express_name = p_template;

	    if l_count <> 1 then
	        if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Category Set ID is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(1));
		    FND_MSG_PUB.Add;
		end if;
		l_validation_error := TRUE;
            end if;  -- check template


	-- check related template
	    select count(*) into l_count
   	    from   po_reqexpress_headers
	    where  express_name = p_related_template;

	    if l_count <> 1 then
	        if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Category ID is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(2));
		    FND_MSG_PUB.Add;
		end if;
		l_validation_error := TRUE;
	    end if;  -- check related template


	-- check that template and related template are not the same
	if (p_relationship_type <> 'TOP' and
            p_template = p_related_template) then
	    if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		-- add message: Related Template may not be the same as
		--              its parent template
	        FND_MESSAGE.SET_NAME('ICX','ICX_TMP_PARENT');
		FND_MSG_PUB.Add;
	    end if;
	    l_validation_error := TRUE;
	end if;


	-- check that top relationship does not already exist if needed
	if p_relationship_type = 'TOP' then
	    select count(*) into l_count
	    from   po_related_templates
	    where  express_name = p_template
 	    and    related_express_name = p_related_template;

	    if l_count > 0 then
	        if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: TEMPLATE is already a top template
		    FND_MESSAGE.SET_NAME('ICX','ICX_TMP_TOP');
		    FND_MESSAGE.SET_TOKEN('TEMPLATE',p_template);
		    FND_MSG_PUB.Add;
	        end if;
	        l_validation_error := TRUE;
	    end if;
	end if;


	-- check that relationship does not already exist
	if p_template <> p_related_template then
	    select count(*) into l_count
	    from   po_related_templates
	    where  express_name = p_template
	    and    related_express_name = p_related_template;

	    if l_count > 0 then
	        if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: This template relationship already exists
		    FND_MESSAGE.SET_NAME('ICX','ICX_TMP_DUP_RELATION');
		    FND_MSG_PUB.Add;
	        end if;
	        l_validation_error := TRUE;
	    end if;
	end if;


	-- check that relationship type is valid
	select count(*) into l_count
	from   fnd_lookups
	where  lookup_type = 'ICX_RELATIONS'
	and    enabled_flag = 'Y'
	and    lookup_code = p_relationship_type;

	if l_count <> 1 then
	    if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		-- add message: Relation is not valid
		FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(3));
		FND_MSG_PUB.Add;
	    end if;
	    l_validation_error := TRUE;
	end if;

    END IF;  --  Validation


    -- If any validation failed, raise error
    IF l_validation_error THEN
	RAISE FND_API.G_EXC_ERROR;
    END IF;



    -- API body

    insert into po_related_templates
       (express_name,
	related_express_name,
	relationship_type,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date)
    values
       (p_template,
	p_related_template,
	p_relationship_type,
	p_created_by,
	sysdate,
	p_created_by,
	sysdate);


    -- End of API body


    -- Standard check of p_simulate and p_commit parameter

    IF FND_API.To_Boolean(p_simulate) THEN

	ROLLBACK TO Insert_Relation_PUB;

    ELSIF FND_API.To_Boolean(p_commit) THEN

	COMMIT WORK;

    END IF;


    -- Get message count and if 1, return message data

    FND_MSG_PUB.Count_And_Get
        (p_count => p_msg_count,
         p_data  => p_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    	p_return_status := FND_API.G_RET_STS_ERROR;

        -- Get message count and if 1, return message data

        FND_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- Get message count and if 1, return message data

        FND_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );

    WHEN OTHERS THEN

    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    FND_MSG_PUB.Build_Exc_Msg
    	    (   G_PKG_NAME  	    ,
    	        'Insert_Relation'
	    );
   	END IF;

        -- Get message count and if 1, return message data

        FND_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );


END; -- Insert_Relation




PROCEDURE Delete_Relation
( p_api_version_number 	IN	NUMBER			    		,
  p_init_msg_list	IN  	VARCHAR2 := FND_API.G_FALSE		,
  p_simulate		IN	VARCHAR2 := FND_API.G_FALSE 		,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE 		,
  p_validation_level	IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
  p_return_status	OUT 	VARCHAR2				,
  p_msg_count		OUT	NUMBER					,
  p_msg_data		OUT 	VARCHAR2	    			,
  p_template		IN	VARCHAR2 DEFAULT NULL			,
  p_related_template	IN	VARCHAR2 DEFAULT NULL
) IS


l_api_version_number    CONSTANT    NUMBER  :=  1.0;
l_validation_error	BOOLEAN		    := FALSE;
l_id_resolve_error	BOOLEAN		    := FALSE;
l_title       		varchar2(80);
l_prompts     		icx_util.g_prompts_table;
l_count			NUMBER;

BEGIN

    --  Standard Start of API savepoint

    SAVEPOINT Delete_Relation_PUB;


    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call(l_api_version_number,
        p_api_version_number,
	'Delete Relation',
	G_PKG_NAME)
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --  Initialize message list if p_init_msg_list is set to TRUE

    IF FND_API.to_Boolean(p_init_msg_list) THEN
 	FND_MSG_PUB.initialize;
    END IF;


    --  Initialize p_return_status

    p_return_status := FND_API.G_RET_STS_SUCCESS;


    --  Get prompts table for translation of messages

    icx_util.getPrompts(601,'ICX_RELATED_TEMPLATES_R',l_title,l_prompts);


    --	Perform manditory validation

	-- check that necessary in parameters are present
	if (p_template is null or
	    p_related_template is null) then

	    if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		-- add message: Required API parameters are missing
		FND_MESSAGE.SET_NAME('ICX','ICX_API_MISS_PARAM');
		FND_MSG_PUB.Add;
	    end if;
	    RAISE FND_API.G_EXC_ERROR;
	end if;




    -- API body

    delete from po_related_templates
    where  express_name = p_template
    and    related_express_name = p_related_template;

    -- End of API body



    -- Standard check of p_simulate and p_commit parameter

    IF FND_API.To_Boolean(p_simulate) THEN

	ROLLBACK TO Insert_Relation_PUB;

    ELSIF FND_API.To_Boolean(p_commit) THEN

	COMMIT WORK;

    END IF;


    -- Get message count and if 1, return message data

    FND_MSG_PUB.Count_And_Get
        (p_count => p_msg_count,
         p_data  => p_msg_data
    );


EXCEPTION

    WHEN NO_DATA_FOUND THEN

	p_return_status := FND_API.G_RET_STS_ERROR;

	if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
	    -- add message: Relation to delete does not exist
	    FND_MESSAGE.SET_NAME('ICX','ICX_CAT_DELETE');
	    FND_MSG_PUB.Add;
	end if;

        -- Get message count and if 1, return message data

        FND_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );

    WHEN FND_API.G_EXC_ERROR THEN

    	p_return_status := FND_API.G_RET_STS_ERROR;

        -- Get message count and if 1, return message data

        FND_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- Get message count and if 1, return message data

        FND_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );

    WHEN OTHERS THEN

    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    FND_MSG_PUB.Build_Exc_Msg
    	    (   G_PKG_NAME  	    ,
    	        'Delete_Relation'
	    );
    	END IF;

        -- Get message count and if 1, return message data

        FND_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );


END; -- Delete_Relation



END ICX_Related_Templates_PUB;

/
