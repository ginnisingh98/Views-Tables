--------------------------------------------------------
--  DDL for Package Body ICX_RELATED_CATEGORIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_RELATED_CATEGORIES_PUB" AS
/* $Header: ICXPCATB.pls 115.1 99/07/17 03:20:00 porting ship $ */


PROCEDURE Insert_Relation
( p_api_version_number 	IN	NUMBER			    		,
  p_init_msg_list	IN  	VARCHAR2 := FND_API.G_FALSE		,
  p_simulate		IN	VARCHAR2 := FND_API.G_FALSE 		,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE 		,
  p_validation_level	IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
  p_return_status	OUT 	VARCHAR2				,
  p_msg_count		OUT	NUMBER					,
  p_msg_data		OUT 	VARCHAR2	    			,
  p_category_set_id	IN	NUMBER	 DEFAULT NULL			,
  p_category_set	IN 	VARCHAR2 DEFAULT NULL			,
  p_category_id		IN 	NUMBER	 DEFAULT NULL			,
  p_category		IN	VARCHAR2 DEFAULT NULL			,
  p_related_category_id	IN	NUMBER 	 DEFAULT NULL			,
  p_related_category	IN	VARCHAR2 DEFAULT NULL			,
  p_relationship_type	IN 	VARCHAR2				,
  p_created_by		IN      NUMBER
) IS

cursor l_category_set_csr is
select category_set_id
from   mtl_category_sets
where  category_set_name = p_category_set;

cursor l_category_csr(l_cat_name in varchar2,
                      l_cat_set_id in number) is
select mck.category_id
from   mtl_categories_kfv mck,
       mtl_category_sets mcs
where  (mcs.validate_flag = 'Y' and
	mck.category_id in (
            select mcsv.category_id
            from   mtl_category_set_valid_cats mcsv
            where  mcsv.category_set_id = l_cat_set_id) and
	mck.concatenated_segments = l_cat_name)
or     (mcs.validate_flag <> 'Y' and
	mcs.structure_id = mck.structure_id and
	mck.concatenated_segments = l_cat_name);


l_api_version_number    CONSTANT    NUMBER  :=  1.0;
l_validation_error	BOOLEAN		    := FALSE;
l_id_resolve_error	BOOLEAN		    := FALSE;
l_category_set_id	NUMBER;
l_category_id		NUMBER;
l_related_category_id	NUMBER;
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
    icx_util.getPrompts(601,'ICX_RELATED_CATEGORIES_R',l_title,l_prompts);


    --  Perform manditory validation

	-- check that necessary in parameters are present
	if (p_category_set_id is null and
	    p_category_set is null) or
	   (p_category_id is null and
	    p_category is null) or
	   (p_related_category_id is null and
	    p_related_category is null) then

	    if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		-- add message: Required API parameters are missing
		FND_MESSAGE.SET_NAME('ICX','ICX_API_MISS_PARAM');
		FND_MSG_PUB.Add;
	    end if;
	    RAISE FND_API.G_EXC_ERROR;
	end if;



    --  Resolve id's from names if id's are absent

	-- Resolve category set id
	if p_category_set_id is not null then
	    l_category_set_id := p_category_set_id;
	else
	    open l_category_set_csr;
	    l_count := 0;
	    loop
		fetch l_category_set_csr into l_category_set_id;
		exit when l_category_set_csr%NOTFOUND;
		l_count := l_count + 1;
	    end loop;
	    close l_category_set_csr;
	    if l_count <> 1 then
		if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Category Set is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(2));
		    FND_MSG_PUB.Add;
		end if;
		l_id_resolve_error := TRUE;
	    end if;
	end if;  -- resolve category set id


    	-- Resolve category_id
	if p_category_id is not null then
	    l_category_id := p_category_id;
	else
	    open l_category_csr(p_category,l_category_set_id);
	    l_count := 0;
	    loop
		fetch l_category_csr into l_category_id;
		exit when l_category_csr%NOTFOUND;
		l_count := l_count + 1;
	    end loop;
	    close l_category_csr;
	    if l_count = 0 then
		if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Category is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(4));
		    FND_MSG_PUB.Add;
		end if;
		l_id_resolve_error := TRUE;
	    end if;
	end if;  -- resolve category id


    	-- Resolve related category_id
	if p_related_category_id is not null then
	    l_related_category_id := p_related_category_id;
	else
	    open l_category_csr(p_related_category,l_category_set_id);
	    l_count := 0;
	    loop
		fetch l_category_csr into l_related_category_id;
		exit when l_category_csr%NOTFOUND;
		l_count := l_count + 1;
	    end loop;
	    close l_category_csr;
	    if l_count = 0 then
		if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Related Category is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(7));
		    FND_MSG_PUB.Add;
		end if;
		l_id_resolve_error := TRUE;
	    end if;
	end if;  -- resolve related category id


    -- If any id resolution failed, raise error
    IF l_id_resolve_error THEN
	RAISE FND_API.G_EXC_ERROR;
    END IF;



    --	Perform validation
    IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN

	-- check category set id if it was not looked up previously
	if p_category_set_id is not null then
	    select count(*) into l_count
   	    from   mtl_category_sets
	    where  category_set_id = l_category_set_id;

	    if l_count <> 1 then
	        if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Category Set ID is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(1));
		    FND_MSG_PUB.Add;
		end if;
		l_validation_error := TRUE;
	    end if;
	end if;  -- check category set id


	-- check category id if it was not looked up previously
	if p_category_id is not null then
	    select count(*) into l_count
   	    from   mtl_categories_kfv mck,
       		   mtl_category_sets mcs
	    where  (mcs.validate_flag = 'Y' and
	            mck.category_id in (
            	        select mcsv.category_id
            		from   mtl_category_set_valid_cats mcsv
            		where  mcsv.category_set_id = l_category_set_id) and
		    mck.category_id = l_category_id)
	    or     (mcs.validate_flag <> 'Y' and
	            mcs.structure_id = mck.structure_id and
	            mck.category_id = l_category_id);

	    if l_count = 0 then
	        if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Category ID is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(3));
		    FND_MSG_PUB.Add;
		end if;
		l_validation_error := TRUE;
	    end if;
	end if;  -- check category id


	-- check related category id if it was not looked up previously
	if p_related_category_id is not null then
	    select count(*) into l_count
   	    from   mtl_categories_kfv mck,
       		   mtl_category_sets mcs
	    where  (mcs.validate_flag = 'Y' and
	            mck.category_id in (
            	        select mcsv.category_id
            		from   mtl_category_set_valid_cats mcsv
            		where  mcsv.category_set_id = l_category_set_id) and
		    mck.category_id = l_related_category_id)
	    or     (mcs.validate_flag <> 'Y' and
	            mcs.structure_id = mck.structure_id and
	            mck.category_id = l_related_category_id);

	    if l_count = 0 then
	        if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Related Category ID is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(6));
		    FND_MSG_PUB.Add;
		end if;
		l_validation_error := TRUE;
	    end if;
	end if;  -- check related category id


	-- check that category id and related category id are not the same
	if (p_relationship_type <> 'TOP' and
            l_category_id = l_related_category_id) then
	    if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		-- add message: Related Category may not be the same as
		--              its parent category
	        FND_MESSAGE.SET_NAME('ICX','ICX_CAT_PARENT');
		FND_MSG_PUB.Add;
	    end if;
	    l_validation_error := TRUE;
	end if;


	-- check that top relationship does not already exist if needed
	if p_relationship_type = 'TOP' then
	    select count(*) into l_count
	    from   icx_related_categories
	    where  category_set_id = l_category_set_id
	    and    category_id = l_category_id
	    and    related_category_id = l_category_id;

	    if l_count > 0 then
	        if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: CATEGORY is already a top category
		    FND_MESSAGE.SET_NAME('ICX','ICX_CAT_TOP');
		    if p_category is not null then
		      FND_MESSAGE.SET_TOKEN('CATEGORY',p_category);
		    else
		      FND_MESSAGE.SET_TOKEN('CATEGORY',l_category_id);
		    end if;
		    FND_MSG_PUB.Add;
	        end if;
	        l_validation_error := TRUE;
	    end if;
	end if;


	-- check that relationship does not already exist
	if l_category_id <> l_related_category_id then
	    select count(*) into l_count
	    from   icx_related_categories
	    where  category_set_id = l_category_set_id
	    and    category_id = l_category_id
	    and    related_category_id = l_related_category_id;

	    if l_count > 0 then
	        if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: This category relationship already exists
		    FND_MESSAGE.SET_NAME('ICX','ICX_CAT_DUP_RELATION');
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
		FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(5));
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

    insert into icx_related_categories
       (category_set_id,
	category_id,
	related_category_id,
	relationship_type,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date)
    values
       (l_category_set_id,
	l_category_id,
	l_related_category_id,
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
  p_category_set_id	IN	NUMBER	 DEFAULT NULL			,
  p_category_set	IN 	VARCHAR2 DEFAULT NULL			,
  p_category_id		IN 	NUMBER	 DEFAULT NULL			,
  p_category		IN	VARCHAR2 DEFAULT NULL			,
  p_related_category_id	IN	NUMBER 	 DEFAULT NULL			,
  p_related_category	IN	VARCHAR2 DEFAULT NULL
) IS

cursor l_category_set_csr is
select category_set_id
from   mtl_category_sets
where  category_set_name = p_category_set;

cursor l_category_csr(l_cat_name in varchar2,
                      l_cat_set_id in number) is
select mck.category_id
from   mtl_categories_kfv mck,
       mtl_category_sets mcs
where  (mcs.validate_flag = 'Y' and
	mck.category_id in (
            select mcsv.category_id
            from   mtl_category_set_valid_cats mcsv
            where  mcsv.category_set_id = l_cat_set_id) and
	mck.concatenated_segments = l_cat_name)
or     (mcs.validate_flag <> 'Y' and
	mcs.structure_id = mck.structure_id and
	mck.concatenated_segments = l_cat_name);

l_api_version_number    CONSTANT    NUMBER  :=  1.0;
l_validation_error	BOOLEAN		    := FALSE;
l_id_resolve_error	BOOLEAN		    := FALSE;
l_category_set_id	NUMBER;
l_category_id		NUMBER;
l_related_category_id	NUMBER;
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

    icx_util.getPrompts(601,'ICX_RELATED_CATEGORIES_R',l_title,l_prompts);


    --	Perform manditory validation

	-- check that necessary in parameters are present
	if (p_category_set_id is null and
	    p_category_set is null) or
	   (p_category_id is null and
	    p_category is null) or
	   (p_related_category_id is null and
	    p_related_category is null) then

	    if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		-- add message: Required API parameters are missing
		FND_MESSAGE.SET_NAME('ICX','ICX_API_MISS_PARAM');
		FND_MSG_PUB.Add;
	    end if;
	    RAISE FND_API.G_EXC_ERROR;
	end if;



    --  Resolve id's from names if id's are absent

	-- Resolve category set id
	if p_category_set_id is not null then
	    l_category_set_id := p_category_set_id;
	else
	    open l_category_set_csr;
	    l_count := 0;
	    loop
		fetch l_category_set_csr into l_category_set_id;
		exit when l_category_set_csr%NOTFOUND;
		l_count := l_count + 1;
	    end loop;
	    close l_category_set_csr;
	    if l_count <> 1 then
		if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Category Set is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(2));
		    FND_MSG_PUB.Add;
		end if;
		l_id_resolve_error := TRUE;
	    end if;
	end if;  -- resolve category set id


    	-- Resolve category_id
	if p_category_id is not null then
	    l_category_id := p_category_id;
	else
	    open l_category_csr(p_category,l_category_set_id);
	    l_count := 0;
	    loop
		fetch l_category_csr into l_category_id;
		exit when l_category_csr%NOTFOUND;
		l_count := l_count + 1;
	    end loop;
	    close l_category_csr;
	    if l_count <> 1 then
		if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Category is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(4));
		    FND_MSG_PUB.Add;
		end if;
		l_id_resolve_error := TRUE;
	    end if;
	end if;  -- resolve category id


    	-- Resolve related category_id
	if p_related_category_id is not null then
	    l_related_category_id := p_related_category_id;
	else
	    open l_category_csr(p_related_category,l_category_set_id);
	    l_count := 0;
	    loop
		fetch l_category_csr into l_related_category_id;
		exit when l_category_csr%NOTFOUND;
		l_count := l_count + 1;
	    end loop;
	    close l_category_csr;
	    if l_count <> 1 then
		if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) then
		    -- add message: Related Category is invalid
		    FND_MESSAGE.SET_NAME('ICX','ICX_INVALID_ENTRY');
		    FND_MESSAGE.SET_TOKEN('INVALID_TOKEN',l_prompts(7));
		    FND_MSG_PUB.Add;
		end if;
		l_id_resolve_error := TRUE;
	    end if;
	end if;  -- resolve related category id


    -- If any id resolution failed, raise error
    IF l_id_resolve_error THEN
	RAISE FND_API.G_EXC_ERROR;
    END IF;



    -- API body

    delete from icx_related_categories
    where  category_set_id = l_category_set_id
    and    category_id = l_category_id
    and    related_category_id = l_related_category_id;

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



END ICX_Related_Categories_PUB;

/
