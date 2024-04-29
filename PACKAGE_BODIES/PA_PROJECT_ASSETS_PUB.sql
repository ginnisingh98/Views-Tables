--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_ASSETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_ASSETS_PUB" AS
/*$Header: PAPMPAPB.pls 120.3 2005/12/19 12:07:14 dlanka noship $*/

--Global constants to be used in error messages
G_PKG_NAME  	CONSTANT VARCHAR2(30) := 'PA_PROJECT_ASSETS_PUB';
G_ASSET_CODE	CONSTANT VARCHAR2(5)  := 'ASSET';

--Global constants to be used in inserts and updates
G_USER_ID  		CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID		CONSTANT NUMBER := FND_GLOBAL.login_id;






--JPULTORAK Project Asset Creation


--------------------------------------------------------------------------------
--Name:               add_project_asset
--Type:               Procedure
--Description:        This procedure adds a project asset to an OP project, when this is allowed.
--
--
--
--Called subprograms:
--
--
--
--History:
--    15-JAN-2003    JPULTORAK       Created
--
PROCEDURE add_project_asset
( p_api_version_number		IN	NUMBER
 ,p_commit					IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status		    OUT	 NOCOPY VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_asset_name			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_number			IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_description		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_asset_type		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_location_id				IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_assigned_to_person_id	IN 	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_date_placed_in_service	IN 	DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_asset_category_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_book_type_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_units				IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_estimated_asset_units	IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_estimated_cost			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_depreciate_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_depreciation_expense_ccid IN	NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_amortize_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_estimated_in_service_date IN	DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_asset_key_ccid			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_parent_asset_id		    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_manufacturer_name		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_model_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_serial_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_tag_number				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_ret_target_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_project_id_out		OUT NOCOPY	NUMBER
 ,p_pa_project_number_out	OUT NOCOPY	VARCHAR2
 ,p_pa_project_asset_id_out	OUT NOCOPY	NUMBER
 ,p_pm_asset_reference_out  OUT NOCOPY VARCHAR2) IS



    l_asset_in_rec                   PA_PROJECT_ASSETS_PUB.asset_in_rec_type;


    --Used to get the project number for AMG messages
    CURSOR l_amg_project_csr(x_project_id   NUMBER) IS
    SELECT  segment1
    FROM    pa_projects p
    WHERE   p.project_id = x_project_id;

    l_amg_project_number             pa_projects_all.segment1%TYPE;
    l_amg_pa_asset_name              pa_project_assets_all.asset_name%TYPE;


    --Used to determine if the project is CAPITAL
    CURSOR capital_project_cur(x_project_id   NUMBER) IS
    SELECT  'Project is CAPITAL'
    FROM    pa_projects p,
            pa_project_types t
    WHERE   p.project_id = x_project_id
    AND     p.project_type = t.project_type
    AND     t.project_type_class_code = 'CAPITAL';

    capital_project_rec      capital_project_cur%ROWTYPE;


    --Used to determine if asset ref is unique within project
    CURSOR  unique_ref_cur(x_project_id  NUMBER) IS
    SELECT  'Asset Ref Exists'
    FROM    pa_project_assets_all
    WHERE   project_id = x_project_id
    AND     pm_asset_reference = l_asset_in_rec.pm_asset_reference;

    unique_ref_rec      unique_ref_cur%ROWTYPE;


    --Used to determine if asset name is unique within project
    CURSOR  unique_name_cur(x_project_id  NUMBER) IS
    SELECT  'Asset Name Exists'
    FROM    pa_project_assets_all
    WHERE   project_id = x_project_id
    AND     asset_name = l_asset_in_rec.pa_asset_name;

    unique_name_rec      unique_name_cur%ROWTYPE;


    --Used to determine if asset number is unique
    CURSOR  unique_number_cur IS
    SELECT  'Asset Number Exists'
    FROM    pa_project_assets_all
    WHERE   asset_number = p_asset_number;

    unique_number_rec      unique_number_cur%ROWTYPE;


    --Used to determine if project asset type is valid
    CURSOR  valid_type_cur IS
    SELECT  meaning
    FROM    pa_lookups
    WHERE   lookup_type = 'PROJECT_ASSET_TYPES'
    AND     lookup_code = p_project_asset_type;

    valid_type_rec      valid_type_cur%ROWTYPE;


    --Used to determine if asset location is valid
    CURSOR  asset_location_cur IS
    SELECT  'Asset Location Exists'
    FROM    fa_locations
    WHERE   location_id = p_location_id
    AND     enabled_flag = 'Y';

    asset_location_rec      asset_location_cur%ROWTYPE;


    --Used to determine if assigned to person is valid
    CURSOR  people_cur IS
    SELECT  'Person Exists'
    FROM    per_people_x
    WHERE   person_id = p_assigned_to_person_id
    --CWK changes, added the below condition
    AND     nvl(current_employee_flag, 'N') = 'Y';

    people_rec      people_cur%ROWTYPE;


    --Used to determine if the book type code is valid for the current SOB
    CURSOR  book_type_code_cur IS
    SELECT  'Book Type Code is valid'
    FROM    fa_book_controls fb,
            pa_implementations pi
    WHERE   fb.set_of_books_id = pi.set_of_books_id
    AND     fb.book_type_code = p_book_type_code
    AND     fb.book_class = 'CORPORATE';

    book_type_code_rec      book_type_code_cur%ROWTYPE;


    --Used to identify default book type code, if specified
    CURSOR  default_book_type_code_cur IS
    SELECT  pi.book_type_code
    FROM    pa_implementations pi
    WHERE   pi.book_type_code IS NOT NULL;


    --Used to determine if the asset category is valid
    CURSOR  asset_category_cur IS
    SELECT  'Asset Category is valid'
    FROM    fa_categories
    WHERE   category_id = p_asset_category_id
    AND     enabled_flag = 'Y';

    asset_category_rec      asset_category_cur%ROWTYPE;


    --Used to determine if the category/books combination is valid
    CURSOR  category_books_cur IS
    SELECT  'Category/Books combination is valid'
    FROM    fa_category_books
    WHERE   category_id = p_asset_category_id
    AND     book_type_code = l_asset_in_rec.book_type_code;

    category_books_rec      category_books_cur%ROWTYPE;


    --Used to default the depreciate_flag from category book defaults
    CURSOR  depreciate_flag_cur IS
    SELECT  SUBSTR(depreciate_flag,1,1)
    FROM    fa_category_book_defaults
    WHERE   category_id = p_asset_category_id
    AND     book_type_code = l_asset_in_rec.book_type_code
    AND     NVL(p_date_placed_in_service,NVL(p_estimated_in_service_date,TRUNC(SYSDATE)))
        BETWEEN start_dpis AND NVL(end_dpis,NVL(p_date_placed_in_service,NVL(p_estimated_in_service_date,TRUNC(SYSDATE))));



    --Used to determine if the Depreciation Expense CCID is valid for the current COA
    CURSOR  deprn_expense_cur IS
    SELECT  'Deprn Expense Acct code combination is valid'
    FROM    gl_code_combinations gcc,
            gl_sets_of_books gsob,
            pa_implementations pi
    WHERE   gcc.code_combination_id = l_asset_in_rec.depreciation_expense_ccid
    AND     gcc.chart_of_accounts_id = gsob.chart_of_accounts_id
    AND     gsob.set_of_books_id = pi.set_of_books_id
    AND     gcc.account_type = 'E';

    deprn_expense_rec      deprn_expense_cur%ROWTYPE;


    --Used to determine if the asset key is valid
    CURSOR  asset_key_cur IS
    SELECT  'Asset Key is valid'
    FROM    fa_asset_keywords
    WHERE   code_combination_id = p_asset_key_ccid
    AND     enabled_flag = 'Y';

    asset_key_rec      asset_key_cur%ROWTYPE;


    --Used to determine if Tag Number is unique in Oracle Assets
    CURSOR  unique_tag_number_fa_cur IS
    SELECT  'Tag Number Exists'
    FROM    fa_additions
    WHERE   tag_number = p_tag_number;

    unique_tag_number_fa_rec      unique_tag_number_fa_cur%ROWTYPE;


    --Used to determine if Tag Number is unique in Oracle Projects
    CURSOR  unique_tag_number_pa_cur IS
    SELECT  'Tag Number Exists'
    FROM    pa_project_assets_all
    WHERE   tag_number = p_tag_number;

    unique_tag_number_pa_rec      unique_tag_number_pa_cur%ROWTYPE;


    --Used to determine if Parent Asset ID is valid in Oracle Assets
    CURSOR  parent_asset_cur IS
    SELECT  'Parent Asset Number Exists'
    FROM    fa_additions
    WHERE   asset_id = p_parent_asset_id
    AND     asset_type <> 'GROUP';

    parent_asset_rec      parent_asset_cur%ROWTYPE;


    --Used to determine if Parent Asset ID is valid for Book specified
    CURSOR  parent_asset_book_cur IS
    SELECT  'Parent Asset Number Exists in Book'
    FROM    fa_additions fa,
            fa_books fb
    WHERE   fa.asset_id = p_parent_asset_id
    AND     fa.asset_type <> 'GROUP'
    AND     fa.asset_id = fb.asset_id
    AND     fb.book_type_code = l_asset_in_rec.book_type_code
    AND     fb.date_ineffective IS NULL;

    parent_asset_book_rec      parent_asset_book_cur%ROWTYPE;


    --Used to determine if the Ret Target Asset ID is a valid GROUP asset in the book
    CURSOR  ret_target_cur IS
    SELECT  fa.asset_category_id
    FROM    fa_books fb,
            fa_additions fa
    WHERE   fa.asset_id = p_ret_target_asset_id
    AND     fa.asset_type = 'GROUP'
    AND     fa.asset_id = fb.asset_id
    AND     fb.book_type_code = l_asset_in_rec.book_type_code
    AND     fb.date_ineffective IS NULL;

    ret_target_rec      ret_target_cur%ROWTYPE;


    l_api_name			   CONSTANT	 VARCHAR2(30) 		:= 'add_project_asset';
    l_return_status				     VARCHAR2(1);
    l_project_id					 pa_projects.project_id%TYPE;
    l_task_id					     pa_tasks.task_id%TYPE;
    l_msg_count					     NUMBER ;
    l_msg_data					     VARCHAR2(2000);
    l_function_allowed				 VARCHAR2(1);
    l_resp_id					     NUMBER := 0;
    l_user_id		                 NUMBER := 0;
    l_module_name                    VARCHAR2(80);
    v_intf_complete_asset_flag       VARCHAR2(1);
    v_asset_key_required             VARCHAR2(1);
    v_depreciation_expense_ccid      NUMBER;

    --Variable used for validation of required Asset KFF segments
    fftype          FND_FLEX_KEY_API.FLEXFIELD_TYPE;
    numstruct       NUMBER;
    structnum       NUMBER;
    liststruct      FND_FLEX_KEY_API.STRUCTURE_LIST;
    thestruct       FND_FLEX_KEY_API.STRUCTURE_TYPE;
    numsegs         NUMBER;
    listsegs        FND_FLEX_KEY_API.SEGMENT_LIST;
    segtype         FND_FLEX_KEY_API.SEGMENT_TYPE;
    segname         FND_ID_FLEX_SEGMENTS.SEGMENT_NAME%TYPE;

 BEGIN

    --  Standard begin of API savepoint
    SAVEPOINT add_project_asset_pub;


    --	Initialize the message table if requested.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
    END IF;


    --  Set API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;



    --  Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    THEN

	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  pm_product_code is mandatory
    IF p_pm_product_code IS NULL OR p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
	    END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --Initialize variables
    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_module_name := 'PA_PM_ADD_PROJECT_ASSET';



    -- Get the project ID
    PA_PROJECT_PVT.Convert_pm_projref_to_id
        (        p_pm_project_reference =>      p_pm_project_reference
                 ,  p_pa_project_id     =>      p_pa_project_id
                 ,  p_out_project_id    =>      l_project_id
                 ,  p_return_status     =>      l_return_status
        );


    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;


    -- Get project number for AMG messages
    OPEN l_amg_project_csr( l_project_id );
    FETCH l_amg_project_csr INTO l_amg_project_number;
    CLOSE l_amg_project_csr;


    --Validate that the project is CAPITAL project type class
    OPEN capital_project_cur(l_project_id);
    FETCH capital_project_cur INTO capital_project_rec;
	IF capital_project_cur%NOTFOUND THEN

        CLOSE capital_project_cur;
        -- The project must be CAPITAL. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PR_NOT_CAPITAL'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE capital_project_cur;



    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to update the project
    -- need to call the pa_security package

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    -- Function security procedure check whether user have the
    -- privilege to add project asset or not

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;

    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_ADD_PROJECT_ASSET',
       p_msg_count	        => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
	       p_return_status := FND_API.G_RET_STS_ERROR;
	       RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Now verify whether project security allows the user to update the project
    IF pa_security.allow_query (x_project_id => l_project_id ) = 'N' THEN

        -- The user does not have query privileges on this project
        -- Hence, cannot update the project.Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
    ELSE
        -- If the user has query privileges, then check whether
        -- update privileges are also available
        IF pa_security.allow_update (x_project_id => l_project_id ) = 'N' THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error

            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'Y'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

	        p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;


    --Bind local asset_in_rec variables to parameter values
    l_asset_in_rec.pm_asset_reference           := p_pm_asset_reference;
    l_asset_in_rec.pa_project_asset_id          := NULL;
    l_asset_in_rec.asset_number	                := p_asset_number;
    --Default asset name to pm_asset_reference if NULL
    IF p_pa_asset_name IS NULL OR p_pa_asset_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_asset_in_rec.pa_asset_name	        := p_pm_asset_reference;
        l_amg_pa_asset_name                     := p_pm_asset_reference;
    ELSE
        l_asset_in_rec.pa_asset_name	        := p_pa_asset_name;
        l_amg_pa_asset_name                     := p_pa_asset_name;
    END IF;
    l_asset_in_rec.asset_description	        := p_asset_description;
    l_asset_in_rec.project_asset_type		    := p_project_asset_type;
    l_asset_in_rec.location_id				    := p_location_id;
    l_asset_in_rec.assigned_to_person_id	    := p_assigned_to_person_id;
    l_asset_in_rec.date_placed_in_service	    := p_date_placed_in_service;
    l_asset_in_rec.asset_category_id		    := p_asset_category_id;
    l_asset_in_rec.book_type_code               := p_book_type_code;
    l_asset_in_rec.asset_units                  := p_asset_units;
    l_asset_in_rec.estimated_asset_units        := p_estimated_asset_units;
    l_asset_in_rec.estimated_cost	            := p_estimated_cost;
    l_asset_in_rec.depreciate_flag              := p_depreciate_flag;
    l_asset_in_rec.depreciation_expense_ccid    := p_depreciation_expense_ccid;
    l_asset_in_rec.amortize_flag                := p_amortize_flag;
    l_asset_in_rec.estimated_in_service_date    := p_estimated_in_service_date;
    l_asset_in_rec.asset_key_ccid               := p_asset_key_ccid;
    l_asset_in_rec.attribute_category           := p_attribute_category;
    l_asset_in_rec.attribute1                   := p_attribute1;
    l_asset_in_rec.attribute2                   := p_attribute2;
    l_asset_in_rec.attribute3                   := p_attribute3;
    l_asset_in_rec.attribute4                   := p_attribute4;
    l_asset_in_rec.attribute5                   := p_attribute5;
    l_asset_in_rec.attribute6                   := p_attribute6;
    l_asset_in_rec.attribute7                   := p_attribute7;
    l_asset_in_rec.attribute8                   := p_attribute8;
    l_asset_in_rec.attribute9                   := p_attribute9;
    l_asset_in_rec.attribute10                  := p_attribute10;
    l_asset_in_rec.attribute11                  := p_attribute11;
    l_asset_in_rec.attribute12                  := p_attribute12;
    l_asset_in_rec.attribute13                  := p_attribute13;
    l_asset_in_rec.attribute14                  := p_attribute14;
    l_asset_in_rec.attribute15                  := p_attribute15;
    l_asset_in_rec.parent_asset_id              := p_parent_asset_id;
    l_asset_in_rec.manufacturer_name            := p_manufacturer_name;
    l_asset_in_rec.model_number	                := p_model_number;
    l_asset_in_rec.serial_number                := p_serial_number;
    l_asset_in_rec.tag_number                   := p_tag_number;
    l_asset_in_rec.ret_target_asset_id          := p_ret_target_asset_id;



    --Begin logic of validating Project Asset

    --Validate that the new Asset Reference is NOT NULL
    IF p_pm_asset_reference IS NULL OR p_pm_asset_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

        -- The Asset Reference must be specified. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_ASSET_REF_IS_MISSING'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --Validate that the new Asset reference is unique in the project
    OPEN unique_ref_cur(l_project_id);
    FETCH unique_ref_cur INTO unique_ref_rec;
	IF unique_ref_cur%FOUND THEN

        CLOSE unique_ref_cur;
        -- The Asset Reference must be unique in the project. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_ASSET_REF_NOT_UNIQUE_AS'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'ASSET'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => l_amg_pa_asset_name
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE unique_ref_cur;


    --Validate that the new Asset Name is NOT NULL
    IF l_asset_in_rec.pa_asset_name IS NULL OR l_asset_in_rec.pa_asset_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

        -- The Asset Name must be specified. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_ASSET_NAME_IS_MISSING'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --Validate that the new Asset Name is unique in the project
    OPEN unique_name_cur(l_project_id);
    FETCH unique_name_cur INTO unique_name_rec;
	IF unique_name_cur%FOUND THEN

        CLOSE unique_name_cur;
        -- The Asset Name must be unique in the project. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_ASSET_NAME_NOT_UNIQ_AS'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'ASSET'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => l_amg_pa_asset_name
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE unique_name_cur;


    --Validate that the new Asset Description is NOT NULL
    IF p_asset_description IS NULL OR p_asset_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

        -- The Asset Description is required. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_ASSET_DESC_MISSING_AS'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'ASSET'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => l_amg_pa_asset_name
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --Validate that the new Project Asset Type is NOT NULL
    IF p_project_asset_type IS NULL OR p_project_asset_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

         -- The Project Asset Type is required. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_ASSET_TYPE_MISSING_AS'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'ASSET'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => l_amg_pa_asset_name
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --Validate that the new Project Asset Type is ESTIMATED, AS-BUILT or RETIREMENT_ADJUSTMENT
    OPEN valid_type_cur;
    FETCH valid_type_cur INTO valid_type_rec;
	IF valid_type_cur%NOTFOUND THEN

        CLOSE valid_type_cur;
        -- The Project Asset Type is invalid. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_ASSET_TYPE_INVALID_AS'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'ASSET'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => l_amg_pa_asset_name
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE valid_type_cur;


    --Validate that the new Asset DPIS and Asset Units are NOT NULL if type is AS-BUILT
    IF p_project_asset_type = 'AS-BUILT' THEN
        IF p_date_placed_in_service IS NULL OR p_date_placed_in_service = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN

            -- The Actual DPIS is required for 'AS-BUILT' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_DPIS_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_asset_units IS NULL OR p_asset_units = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

            -- The Asset Units are required for 'AS-BUILT' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_UNITS_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;



    --Validate that the new Asset DPIS and Asset Units are NULL if type is ESTIMATED
    IF p_project_asset_type = 'ESTIMATED' THEN
        IF p_date_placed_in_service IS NOT NULL AND p_date_placed_in_service <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN

            -- The Actual DPIS must be NULL for 'ESTIMATED' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_DPIS_MB_NULL_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;


    --If Asset Number is specified, it must not exist on other project assets
    IF p_asset_number IS NOT NULL AND p_asset_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        OPEN unique_number_cur;
        FETCH unique_number_cur INTO unique_number_rec;
	    IF unique_number_cur%FOUND THEN

            CLOSE unique_number_cur;
            -- The Asset Number must be unique. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_NUM_NOT_UNIQUE_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE unique_number_cur;
    END IF;


    --If Tag Number is specified, it must not exist on other project assets or in Oracle Assets
    IF p_tag_number IS NOT NULL AND p_tag_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

        --Test for uniqueness in Oracle Assets
        OPEN unique_tag_number_fa_cur;
        FETCH unique_tag_number_fa_cur INTO unique_tag_number_fa_rec;
	    IF unique_tag_number_fa_cur%FOUND THEN

            CLOSE unique_tag_number_fa_cur;
            -- The Tag Number must be unique. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_TAG_NUM_FA_NOT_UNIQ_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE unique_tag_number_fa_cur;

        --Test for uniqueness in Oracle Projects
        OPEN unique_tag_number_pa_cur;
        FETCH unique_tag_number_pa_cur INTO unique_tag_number_pa_rec;
	    IF unique_tag_number_pa_cur%FOUND THEN

            CLOSE unique_tag_number_pa_cur;
            -- The Tag Number must be unique. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_TAG_NUM_PA_NOT_UNIQ_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE unique_tag_number_pa_cur;
    END IF;



    --If Asset Location is specified, it must be valid in Oracle Assets
    IF p_location_id IS NOT NULL AND p_location_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
        OPEN asset_location_cur;
        FETCH asset_location_cur INTO asset_location_rec;
	    IF asset_location_cur%NOTFOUND THEN

            CLOSE asset_location_cur;
            -- The Asset Location is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_LOC_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE asset_location_cur;
    END IF;


    --If Assigned to Person is specified, it must be valid Person ID
    IF p_assigned_to_person_id IS NOT NULL AND p_assigned_to_person_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
        OPEN people_cur;
        FETCH people_cur INTO people_rec;
	    IF people_cur%NOTFOUND THEN

            CLOSE people_cur;
            -- The Assign to Person is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSGN_TO_PER_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE people_cur;
    END IF;


    --If Book Type Code is specified, it must be valid for the current Set of Books
    IF p_book_type_code IS NOT NULL AND p_book_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        OPEN book_type_code_cur;
        FETCH book_type_code_cur INTO book_type_code_rec;
	    IF book_type_code_cur%NOTFOUND THEN

            CLOSE book_type_code_cur;
            -- The book_type_code is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_BOOK_TYPE_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        ELSE
            l_asset_in_rec.book_type_code := p_book_type_code;
	    END IF;
	    CLOSE book_type_code_cur;
    ELSE
        --Determine if default book_type_code exists in PA_IMPLEMENTATIONS
        OPEN default_book_type_code_cur;
        FETCH default_book_type_code_cur INTO l_asset_in_rec.book_type_code;
	    IF default_book_type_code_cur%NOTFOUND THEN

            -- No default book_type_code exists.  Set l_asset_in_rec.book_type_code to NULL;
            l_asset_in_rec.book_type_code := NULL;
        END IF;
	    CLOSE default_book_type_code_cur;

    END IF;


    --Book Type Code must have a value for assets of type 'RETIREMENT_ADJUSTMENT'
    IF l_asset_in_rec.book_type_code IS NULL AND p_project_asset_type = 'RETIREMENT_ADJUSTMENT' THEN

        -- The book_type_code must be specified for this type of asset. Raise error
        pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_BOOK_TYPE_IS_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --If l_asset_in_rec.book_type_code has a value, then the Parent Asset ID must be valid for the book
    IF l_asset_in_rec.book_type_code IS NOT NULL AND p_parent_asset_id IS NOT NULL
        AND p_parent_asset_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

        OPEN parent_asset_book_cur;
        FETCH parent_asset_book_cur INTO parent_asset_book_rec;
	    IF parent_asset_book_cur%NOTFOUND THEN

            CLOSE parent_asset_book_cur;
            -- The parent_asset_id must be valid for the book_type_code. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PARENT_BOOK_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE parent_asset_book_cur;

    ELSIF l_asset_in_rec.book_type_code IS NULL AND p_parent_asset_id IS NOT NULL
        AND p_parent_asset_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

        --Parent Asset ID must be a valid asset
        OPEN parent_asset_cur;
        FETCH parent_asset_cur INTO parent_asset_rec;
	    IF parent_asset_cur%NOTFOUND THEN

            CLOSE parent_asset_cur;
            -- The parent_asset_id must be valid in Oracle Assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PARENT_ASSET_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE parent_asset_cur;

    END IF;


    --If Asset Category is specified, it must be valid in FA_CATEGORIES
    IF p_asset_category_id IS NOT NULL AND p_asset_category_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
        OPEN asset_category_cur;
        FETCH asset_category_cur INTO asset_category_rec;
	    IF asset_category_cur%NOTFOUND THEN

            CLOSE asset_category_cur;
            -- The asset_category is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_CATEGORY_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE asset_category_cur;


        --If l_asset_in_rec.book_type_code has a value, then the Category/Book combination must be valid
        IF l_asset_in_rec.book_type_code IS NOT NULL THEN
            OPEN category_books_cur;
            FETCH category_books_cur INTO category_books_rec;
	        IF category_books_cur%NOTFOUND THEN

                CLOSE category_books_cur;
                -- The category/books combination is not valid. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_CAT_BOOKS_INVALID_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
	        END IF;
	        CLOSE category_books_cur;


            --Default depreciate_flag from category book defaults if not specified
            IF p_depreciate_flag IS NULL OR p_depreciate_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                OPEN depreciate_flag_cur;
                FETCH depreciate_flag_cur INTO l_asset_in_rec.depreciate_flag;
	            IF depreciate_flag_cur%NOTFOUND THEN
                    l_asset_in_rec.depreciate_flag := NULL;
	            END IF;
	            CLOSE depreciate_flag_cur;

            END IF; --Depreciate Flag not specified


            --Default amortize_flag to 'N' if not specified
            IF p_amortize_flag IS NULL OR p_amortize_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

                l_asset_in_rec.amortize_flag := 'N';

            END IF; --Amortize Flag not specified

        END IF; --l_asset_in_rec.book_type_code NOT NULL

    END IF;


    --If amortize_flag has a value, it must be Y or N
    IF p_amortize_flag IS NOT NULL AND p_amortize_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        IF p_amortize_flag NOT IN ('Y','N') THEN
            -- The amortize_flag is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_AMORT_FLAG_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        ELSE
            l_asset_in_rec.amortize_flag := p_amortize_flag;
        END IF;

    END IF; --Amortize Flag specified


    --If depreciate_flag has a value, it must be Y or N
    IF p_depreciate_flag IS NOT NULL AND p_depreciate_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        IF p_depreciate_flag NOT IN ('Y','N') THEN
            -- The depreciate_flag is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_DEPR_FLAG_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        ELSE
            l_asset_in_rec.depreciate_flag := p_depreciate_flag;
        END IF;

    END IF; --Depreciate Flag specified



    --Call the Depreciation Expense CCID Override client extension for AS-BUILT assets
    IF p_project_asset_type = 'AS-BUILT' THEN

        IF p_asset_category_id IS NOT NULL AND p_asset_category_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
            AND l_asset_in_rec.book_type_code IS NOT NULL AND l_asset_in_rec.book_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
            AND p_date_placed_in_service IS NOT NULL AND p_date_placed_in_service <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN

               --Determine value of parameter to be sent for current Deprn Expense CCID
               IF l_asset_in_rec.depreciation_expense_ccid = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                   v_depreciation_expense_ccid := NULL;
               ELSE
                   v_depreciation_expense_ccid := l_asset_in_rec.depreciation_expense_ccid;
               END IF;


               l_asset_in_rec.depreciation_expense_ccid := PA_CLIENT_EXTN_DEPRN_EXP_OVR.DEPRN_EXPENSE_ACCT_OVERRIDE
                                        (p_project_asset_id        => NULL,
                                         p_book_type_code          => l_asset_in_rec.book_type_code,
			                             p_asset_category_id       => p_asset_category_id,
                                         p_date_placed_in_service  => p_date_placed_in_service,
                                         p_deprn_expense_acct_ccid => v_depreciation_expense_ccid);

        END IF;
    END IF;



    --If Depreciation Expense CCID is specified, it must be a valid Code Combination
    IF l_asset_in_rec.depreciation_expense_ccid IS NOT NULL AND l_asset_in_rec.depreciation_expense_ccid <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
        OPEN deprn_expense_cur;
        FETCH deprn_expense_cur INTO deprn_expense_rec;
	    IF deprn_expense_cur%NOTFOUND THEN

            CLOSE deprn_expense_cur;
            -- The depreciation_expense_ccid is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_DEPRN_EXP_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE deprn_expense_cur;

    END IF;



    --If Asset Key CCID is specified, it must be a valid FA Keywords combination
    IF p_asset_key_ccid IS NOT NULL AND p_asset_key_ccid <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
        OPEN asset_key_cur;
        FETCH asset_key_cur INTO asset_key_rec;
	    IF asset_key_cur%NOTFOUND THEN

            CLOSE asset_key_cur;
            -- The asset_key_ccid is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_KEY_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE asset_key_cur;
    END IF;



    --If project_asset_type is 'RETIREMENT_ADJUSTMENT', the Ret Target Asset ID must be specified
    IF p_project_asset_type = 'RETIREMENT_ADJUSTMENT' THEN
        IF p_ret_target_asset_id IS NOT NULL AND p_ret_target_asset_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

            --Ret Target Asset ID must be a valid Group Asset for the Book
            OPEN ret_target_cur;
            FETCH ret_target_cur INTO ret_target_rec;
	        IF ret_target_cur%NOTFOUND THEN

                CLOSE ret_target_cur;
                -- The Ret Target Asset ID is not valid. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_RET_ASSET_ID_INVALID_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
	       END IF;
	       CLOSE ret_target_cur;

           --If Asset Category ID is NULL, default it to the Category of the Ret Target Asset
           IF p_asset_category_id IS NULL OR p_asset_category_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
               l_asset_in_rec.asset_category_id := ret_target_rec.asset_category_id;
           END IF;
        ELSE
            --Ret Target Asset ID must be specified for RETIREMENT_ADJUSTMENT assets
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_RET_ASSET_ID_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        --Ret Target Asset ID must not be specified
        IF p_ret_target_asset_id IS NOT NULL AND p_ret_target_asset_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

            --Ret Target Asset ID must be not specified for ESTIMATED or AS-BUILT assets
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_RET_ASSET_ID_MB_NULL_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;



    --Validate that the Asset Category, Book Type Code, Location, Asset Key, Depreciate Flag and Deprn Expense CCID
    --are NOT NULL if the Project Asset Type is AS-BUILT and Complete Asset Definition is required

    SELECT  NVL(pt.interface_complete_asset_flag,'N')
    INTO    v_intf_complete_asset_flag
    FROM    pa_project_types pt,
            pa_projects p
    WHERE   p.project_type = pt.project_type
    AND     p.project_id = l_project_id;


    IF p_project_asset_type = 'AS-BUILT' AND v_intf_complete_asset_flag = 'Y' THEN

        IF p_asset_category_id IS NULL OR p_asset_category_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

            -- The Asset Category is required for 'AS-BUILT' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_CATEGORY_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF p_location_id IS NULL OR p_location_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

            -- The Asset Location is required for 'AS-BUILT' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_LOC_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF l_asset_in_rec.book_type_code IS NULL OR l_asset_in_rec.book_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

            -- The Book Type Code is required for 'AS-BUILT' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_BOOK_TYPE_IS_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF l_asset_in_rec.depreciation_expense_ccid IS NULL OR l_asset_in_rec.depreciation_expense_ccid = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

            -- The Depreciation Expense CCID is required for 'AS-BUILT' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_DEPRN_EXP_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF p_asset_key_ccid IS NULL OR p_asset_key_ccid = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

            --Asset Key CCID must be specified if any of the segments are specified
            BEGIN
                SELECT  asset_key_flex_structure
                INTO    structnum
                FROM    fa_system_controls;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;

            IF structnum IS NOT NULL THEN

                FND_FLEX_KEY_API.SET_SESSION_MODE('seed_data');

                fftype := FND_FLEX_KEY_API.FIND_FLEXFIELD
                                (appl_short_name =>'OFA',
                                flex_code =>'KEY#');

                thestruct := FND_FLEX_KEY_API.FIND_STRUCTURE(fftype,structnum);

                FND_FLEX_KEY_API.GET_SEGMENTS(fftype,thestruct,TRUE,numsegs,listsegs);

                v_asset_key_required := 'N';

                FOR i IN 1 .. numsegs LOOP
                    segtype := FND_FLEX_KEY_API.FIND_SEGMENT(fftype,thestruct,listsegs(i));

                    IF (segtype.required_flag = 'Y' and segtype.enabled_flag = 'Y') THEN
                        v_asset_key_required := 'Y';
                    END IF;
                END LOOP;


                IF v_asset_key_required = 'Y' THEN

                    -- The Asset Key CCID is required. Raise error
                    pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_ASSET_KEY_MISSING_AS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'ASSET'
                        ,p_attribute1       => l_amg_project_number
                        ,p_attribute2       => l_amg_pa_asset_name
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');

                    p_return_status := FND_API.G_RET_STS_ERROR;

                    RAISE FND_API.G_EXC_ERROR;
                END IF; --Asset Key is required
            END IF; --Structnum was determined
        END IF; --Asset Key was not specified
    END IF; --AS-BUILT asset with Complete Asset Info required



    --Validations are complete.  Begin INSERT logic for new PA_PROJECT_ASSETS_ALL row.


    --NULL out any unspecified fields
	IF l_asset_in_rec.pa_asset_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.pa_asset_name := NULL;
	END IF;

   	IF l_asset_in_rec.pm_asset_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.pm_asset_reference := NULL;
	END IF;

	IF l_asset_in_rec.asset_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.asset_number := NULL;
	END IF;

   	IF l_asset_in_rec.asset_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.asset_description := NULL;
	END IF;

   	IF l_asset_in_rec.project_asset_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.project_asset_type := NULL;
	END IF;

   	IF l_asset_in_rec.location_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		l_asset_in_rec.location_id := NULL;
	END IF;

   	IF l_asset_in_rec.assigned_to_person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		l_asset_in_rec.assigned_to_person_id := NULL;
	END IF;

   	IF l_asset_in_rec.date_placed_in_service = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
		l_asset_in_rec.date_placed_in_service := NULL;
	END IF;

   	IF l_asset_in_rec.asset_category_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		l_asset_in_rec.asset_category_id := NULL;
	END IF;

    IF l_asset_in_rec.book_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.book_type_code := NULL;
	END IF;

    IF l_asset_in_rec.asset_units = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		l_asset_in_rec.asset_units := NULL;
	END IF;

    IF l_asset_in_rec.estimated_asset_units = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		l_asset_in_rec.estimated_asset_units := NULL;
	END IF;

    IF l_asset_in_rec.estimated_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		l_asset_in_rec.estimated_cost := NULL;
	END IF;

    IF l_asset_in_rec.depreciate_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.depreciate_flag := NULL;
	END IF;

    IF l_asset_in_rec.depreciation_expense_ccid = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		l_asset_in_rec.depreciation_expense_ccid := NULL;
	END IF;

    IF l_asset_in_rec.amortize_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.amortize_flag := NULL;
	END IF;

   	IF l_asset_in_rec.estimated_in_service_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
		l_asset_in_rec.estimated_in_service_date := NULL;
	END IF;

    IF l_asset_in_rec.asset_key_ccid = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		l_asset_in_rec.asset_key_ccid := NULL;
	END IF;

    IF l_asset_in_rec.attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute_category := NULL;
	END IF;

    IF l_asset_in_rec.attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute1 := NULL;
	END IF;

    IF l_asset_in_rec.attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute2 := NULL;
	END IF;

    IF l_asset_in_rec.attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute3 := NULL;
	END IF;

    IF l_asset_in_rec.attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute4 := NULL;
	END IF;

    IF l_asset_in_rec.attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute5 := NULL;
	END IF;

    IF l_asset_in_rec.attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute6 := NULL;
	END IF;

    IF l_asset_in_rec.attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute7 := NULL;
	END IF;

    IF l_asset_in_rec.attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute8 := NULL;
	END IF;

    IF l_asset_in_rec.attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute9 := NULL;
	END IF;

    IF l_asset_in_rec.attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute10 := NULL;
	END IF;

    IF l_asset_in_rec.attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute11 := NULL;
	END IF;

    IF l_asset_in_rec.attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute12 := NULL;
	END IF;

    IF l_asset_in_rec.attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute13 := NULL;
	END IF;

    IF l_asset_in_rec.attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute14 := NULL;
	END IF;

    IF l_asset_in_rec.attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.attribute15 := NULL;
	END IF;

    IF l_asset_in_rec.manufacturer_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.manufacturer_name := NULL;
	END IF;

    IF l_asset_in_rec.model_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.model_number	 := NULL;
	END IF;

    IF l_asset_in_rec.serial_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.serial_number := NULL;
	END IF;

    IF l_asset_in_rec.tag_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		l_asset_in_rec.tag_number := NULL;
	END IF;

    IF l_asset_in_rec.ret_target_asset_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		l_asset_in_rec.ret_target_asset_id := NULL;
	END IF;

    IF l_asset_in_rec.parent_asset_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		l_asset_in_rec.parent_asset_id := NULL;
	END IF;


    --Get next project_asset_id sequence value
    SELECT  pa_project_assets_s.NEXTVAL
    INTO    l_asset_in_rec.pa_project_asset_id
    FROM    SYS.DUAL;


    --Insert new project asset, since all validations have passed
    INSERT INTO pa_project_assets_all(
        project_asset_id,
        project_id,
        asset_number,
        asset_name,
        asset_description,
        pm_product_code,
        pm_asset_reference,
        location_id,
        assigned_to_person_id,
        date_placed_in_service,
        asset_category_id,
        book_type_code,
        asset_units,
        depreciate_flag,
        depreciation_expense_ccid,
        amortize_flag,
        capitalized_flag,
        reverse_flag,
        capital_hold_flag,
        estimated_in_service_date,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        last_update_login,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        org_id,
        asset_key_ccid,
        project_asset_type,
        estimated_cost,
        estimated_asset_units,
        manufacturer_name,
        model_number,
        tag_number,
        serial_number,
        ret_target_asset_id,
        parent_asset_id
        )
    VALUES (
        l_asset_in_rec.pa_project_asset_id,
        l_project_id,
        l_asset_in_rec.asset_number,
        l_asset_in_rec.pa_asset_name,
        RTRIM(SUBSTR(l_asset_in_rec.asset_description,1,80)),
        p_pm_product_code,
        l_asset_in_rec.pm_asset_reference,
        l_asset_in_rec.location_id,
        l_asset_in_rec.assigned_to_person_id,
        l_asset_in_rec.date_placed_in_service,
        l_asset_in_rec.asset_category_id,
        l_asset_in_rec.book_type_code,
        --l_asset_in_rec.asset_units,
        --Adding TRUNC until Oracle Assets allows fractional Units
        GREATEST(TRUNC(l_asset_in_rec.asset_units),1),
        NVL(l_asset_in_rec.depreciate_flag,'Y'),
        l_asset_in_rec.depreciation_expense_ccid,
        NVL(l_asset_in_rec.amortize_flag,'N'),
        'N', --capitalized_flag
        'N', --reverse_flag
        'N', --capital_hold_flag
        l_asset_in_rec.estimated_in_service_date,
        SYSDATE, --last_update_date
        FND_GLOBAL.user_id, --last_updated_by
        FND_GLOBAL.user_id, --created_by
        SYSDATE, --creation_date
        FND_GLOBAL.login_id, --last_update_login
        l_asset_in_rec.attribute_category,
        l_asset_in_rec.attribute1,
        l_asset_in_rec.attribute2,
        l_asset_in_rec.attribute3,
        l_asset_in_rec.attribute4,
        l_asset_in_rec.attribute5,
        l_asset_in_rec.attribute6,
        l_asset_in_rec.attribute7,
        l_asset_in_rec.attribute8,
        l_asset_in_rec.attribute9,
        l_asset_in_rec.attribute10,
        l_asset_in_rec.attribute11,
        l_asset_in_rec.attribute12,
        l_asset_in_rec.attribute13,
        l_asset_in_rec.attribute14,
        l_asset_in_rec.attribute15,
        mo_global.get_current_org_id ,
        l_asset_in_rec.asset_key_ccid,
        l_asset_in_rec.project_asset_type,
        l_asset_in_rec.estimated_cost,
        --l_asset_in_rec.estimated_asset_units,
        --Adding TRUNC until Oracle Assets allows fractional Units
        GREATEST(TRUNC(l_asset_in_rec.estimated_asset_units),1),
        l_asset_in_rec.manufacturer_name,
        l_asset_in_rec.model_number,
        l_asset_in_rec.tag_number,
        l_asset_in_rec.serial_number,
        l_asset_in_rec.ret_target_asset_id,
        l_asset_in_rec.parent_asset_id
        );


    --Set sucessful output variables
    p_pa_project_id_out		   := l_project_id;
    p_pa_project_number_out	   := l_amg_project_number;
    p_pa_project_asset_id_out  := l_asset_in_rec.pa_project_asset_id;
    p_pm_asset_reference_out   := l_asset_in_rec.pm_asset_reference;


    --Issue commit if indicated
    IF FND_API.to_boolean( p_commit ) THEN
	   COMMIT;
    END IF;


 EXCEPTION
 	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO add_project_asset_pub;

		p_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
	   ROLLBACK TO add_project_asset_pub;

	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

 	WHEN OTHERS	THEN
	   ROLLBACK TO add_project_asset_pub;

	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		  FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

	   END IF;

	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

 END add_project_asset;



--------------------------------------------------------------------------------
--Name:               add_asset_assignment
--Type:               Procedure
--Description:        This procedure adds an asset assignment to an OP project, when this is allowed.
--
--
--
--Called subprograms:
--
--
--
--History:
--    15-JAN-2003    JPULTORAK       Created
--
PROCEDURE add_asset_assignment
( p_api_version_number		IN	NUMBER
 ,p_commit					IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status		    OUT NOCOPY	VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference	    IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id			    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id_out		    OUT NOCOPY	NUMBER
 ,p_pa_project_asset_id_out	OUT NOCOPY	NUMBER ) IS


    --Used to get the project number for AMG messages
    CURSOR l_amg_project_csr(x_project_id   NUMBER) IS
    SELECT  segment1
    FROM    pa_projects p
    WHERE   p.project_id = x_project_id;

    l_amg_project_number             pa_projects_all.segment1%TYPE;


    --Used to get the asset number for AMG messages
    CURSOR l_amg_asset_csr(x_project_asset_id   NUMBER) IS
    SELECT  asset_name
    FROM    pa_project_assets p
    WHERE   p.project_asset_id = x_project_asset_id;

    l_amg_pa_asset_name              pa_project_assets_all.asset_name%TYPE;


    --Used to determine if the project is CAPITAL
    CURSOR capital_project_cur(x_project_id   NUMBER) IS
    SELECT  'Project is CAPITAL'
    FROM    pa_projects p,
            pa_project_types t
    WHERE   p.project_id = x_project_id
    AND     p.project_type = t.project_type
    AND     t.project_type_class_code = 'CAPITAL';

    capital_project_rec      capital_project_cur%ROWTYPE;


    l_project_id                     NUMBER;


    --Used to determine if Task assignments exist
    CURSOR task_assign_cur IS
    SELECT  'Task Assignments Exist'
    FROM    pa_project_asset_assignments
    WHERE   project_id = l_project_id
    AND     task_id <> 0;

    task_assign_rec      task_assign_cur%ROWTYPE;


    --Used to determine if Project assignments exist
    CURSOR proj_assign_cur IS
    SELECT  'Project Assignments Exist'
    FROM    pa_project_asset_assignments
    WHERE   project_id = l_project_id
    AND     task_id = 0;

    proj_assign_rec      proj_assign_cur%ROWTYPE;


    --Used to determine if Project-level Specific Asset assignments exist
    CURSOR specific_assign_cur IS
    SELECT  'Project Specific Assignments Exist'
    FROM    pa_project_asset_assignments
    WHERE   project_id = l_project_id
    AND     task_id = 0
    AND     project_asset_id <> 0;

    specific_assign_rec      specific_assign_cur%ROWTYPE;


    --Used to determine if Project-level Common assignments exist
    CURSOR common_assign_cur IS
    SELECT  'Project Common Assignments Exist'
    FROM    pa_project_asset_assignments
    WHERE   project_id = l_project_id
    AND     task_id = 0
    AND     project_asset_id = 0;

    common_assign_rec      common_assign_cur%ROWTYPE;


    --Used to determine if Task-level Specific Asset assignments exist
    CURSOR task_specific_assign_cur(x_task_id  NUMBER) IS
    SELECT  'Project Specific Assignments Exist'
    FROM    pa_project_asset_assignments
    WHERE   project_id = l_project_id
    AND     task_id = x_task_id
    AND     project_asset_id <> 0;

    task_specific_assign_rec      task_specific_assign_cur%ROWTYPE;


    --Used to determine if Task-level Common assignments exist
    CURSOR task_common_assign_cur(x_task_id  NUMBER) IS
    SELECT  'Project Common Assignments Exist'
    FROM    pa_project_asset_assignments
    WHERE   project_id = l_project_id
    AND     task_id = x_task_id
    AND     project_asset_id = 0;

    task_common_assign_rec      task_common_assign_cur%ROWTYPE;


    --Used to determine the Top Task ID for a given Task
    CURSOR top_task_cur(x_task_id  NUMBER) IS
    SELECT  top_task_id
    FROM    pa_tasks
    WHERE   task_id = x_task_id;

    top_task_rec      top_task_cur%ROWTYPE;


    --Used to determine if the current Task has any children
    CURSOR child_task_cur(x_task_id  NUMBER) IS
    SELECT  'Child Tasks Exist'
    FROM    pa_tasks
    WHERE   parent_task_id = x_task_id;

    child_task_rec      child_task_cur%ROWTYPE;


    --Used to determine if Lowest-Task assignments exist below a given Top Task
    CURSOR child_assign_cur(x_task_id  NUMBER) IS
    SELECT  'Lowest Task Assignments Exist'
    FROM    pa_project_asset_assignments p,
            pa_tasks t
    WHERE   p.project_id = l_project_id
    AND     p.task_id = t.task_id
    AND     t.top_task_id = x_task_id
    AND     t.top_task_id <> t.task_id; --We don't care if other assignments exist for the top task itself

    child_assign_rec      child_assign_cur%ROWTYPE;


    --Used to determine if Top-Task assignments exist above a given Lowest Task
    CURSOR top_assign_cur(x_task_id  NUMBER) IS
    SELECT  'Top Task Assignments Exist'
    FROM    pa_project_asset_assignments p,
            pa_tasks t
    WHERE   p.project_id = l_project_id
    AND     p.task_id = t.top_task_id
    AND     t.task_id = x_task_id
    AND     p.task_id <> x_task_id; --We don't care if other assignments exist for the lowest task itself

    top_assign_rec      top_assign_cur%ROWTYPE;


    --Used to determine if the new assignment already exists
    CURSOR existing_assignment_cur (x_project_id        NUMBER,
                                    x_task_id           NUMBER,
                                    x_project_asset_id  NUMBER) IS
    SELECT  'Assignment Already Exists'
    FROM    pa_project_asset_assignments
    WHERE   project_id = x_project_id
    AND     task_id = x_task_id
    AND     project_asset_id = x_project_asset_id;

    existing_assignment_rec      existing_assignment_cur%ROWTYPE;



    l_api_name			   CONSTANT	 VARCHAR2(30) 		:= 'add_asset_assignment';
    l_return_status                  VARCHAR2(1);
    l_function_allowed				 VARCHAR2(1);
    l_resp_id					     NUMBER := 0;
    l_user_id		                 NUMBER := 0;
    l_module_name                    VARCHAR2(80);
    l_msg_count					     NUMBER ;
    l_msg_data					     VARCHAR2(2000);
    l_task_id                        NUMBER;
    l_project_asset_id               NUMBER;
    l_attribute_category             PA_PROJECT_ASSET_ASSIGNMENTS.attribute_category%TYPE;
    l_attribute1                     PA_PROJECT_ASSET_ASSIGNMENTS.attribute1%TYPE;
    l_attribute2                     PA_PROJECT_ASSET_ASSIGNMENTS.attribute2%TYPE;
    l_attribute3                     PA_PROJECT_ASSET_ASSIGNMENTS.attribute3%TYPE;
    l_attribute4                     PA_PROJECT_ASSET_ASSIGNMENTS.attribute4%TYPE;
    l_attribute5                     PA_PROJECT_ASSET_ASSIGNMENTS.attribute5%TYPE;
    l_attribute6                     PA_PROJECT_ASSET_ASSIGNMENTS.attribute6%TYPE;
    l_attribute7                     PA_PROJECT_ASSET_ASSIGNMENTS.attribute7%TYPE;
    l_attribute8                     PA_PROJECT_ASSET_ASSIGNMENTS.attribute8%TYPE;
    l_attribute9                     PA_PROJECT_ASSET_ASSIGNMENTS.attribute9%TYPE;
    l_attribute10                    PA_PROJECT_ASSET_ASSIGNMENTS.attribute10%TYPE;
    l_attribute11                    PA_PROJECT_ASSET_ASSIGNMENTS.attribute11%TYPE;
    l_attribute12                    PA_PROJECT_ASSET_ASSIGNMENTS.attribute12%TYPE;
    l_attribute13                    PA_PROJECT_ASSET_ASSIGNMENTS.attribute13%TYPE;
    l_attribute14                    PA_PROJECT_ASSET_ASSIGNMENTS.attribute14%TYPE;
    l_attribute15                    PA_PROJECT_ASSET_ASSIGNMENTS.attribute15%TYPE;


 BEGIN

    --  Standard begin of API savepoint
    SAVEPOINT add_asset_assignment_pub;


    --  Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --	Initialize the message table if requested.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --  Set API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;


    --  pm_product_code is mandatory
    IF p_pm_product_code IS NULL OR p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
	    END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --Initialize variables
    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_module_name := 'PA_PM_ADD_ASSET_ASSIGNMENT';



    --Get Project ID from Project Reference
    PA_PROJECT_PVT.Convert_pm_projref_to_id
        (        p_pm_project_reference =>      p_pm_project_reference
                 ,  p_pa_project_id     =>      p_pa_project_id
                 ,  p_out_project_id    =>      l_project_id
                 ,  p_return_status     =>      l_return_status
        );

    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;


    -- Get project number for AMG messages
    OPEN l_amg_project_csr( l_project_id );
    FETCH l_amg_project_csr INTO l_amg_project_number;
    CLOSE l_amg_project_csr;


    --Validate that the project is CAPITAL project type class
    OPEN capital_project_cur(l_project_id);
    FETCH capital_project_cur INTO capital_project_rec;
	IF capital_project_cur%NOTFOUND THEN

        CLOSE capital_project_cur;
        -- The project must be CAPITAL. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PR_NOT_CAPITAL'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE capital_project_cur;



    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to update the project
    -- need to call the pa_security package

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    -- Function security procedure check whether user have the
    -- privilege to add asset assignment or not

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;

    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_ADD_ASSET_ASSIGNMENT',
       p_msg_count	        => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
	       p_return_status := FND_API.G_RET_STS_ERROR;
	       RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Now verify whether project security allows the user to update the project
    IF pa_security.allow_query (x_project_id => l_project_id ) = 'N' THEN

        -- The user does not have query privileges on this project
        -- Hence, cannot update the project.Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
    ELSE
        -- If the user has query privileges, then check whether
        -- update privileges are also available
        IF pa_security.allow_update (x_project_id => l_project_id ) = 'N' THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error

            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'Y'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

	        p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;


    --Check for a Project-level assignment (Task ID = 0 or both task references are NULL)
    IF p_pa_task_id = 0 OR
        ((p_pa_task_id IS NULL OR p_pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
        AND (p_pm_task_reference IS NULL OR p_pm_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) THEN

        l_task_id := 0;

    ELSE
        --Get task id, if both task references are not NULL and p_pa_task_id <> 0
        Pa_project_pvt.Convert_pm_taskref_to_id (
            p_pa_project_id       => l_project_id,
            p_pa_task_id          => p_pa_task_id,
            p_pm_task_reference   => p_pm_task_reference,
            p_out_task_id         => l_task_id,
            p_return_status       => l_return_status );

        IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

    END IF;


    --Check for a "Common" assignment (Project Asset ID = 0 or both asset references are NULL)
    IF p_pa_project_asset_id = 0 OR
        ((p_pa_project_asset_id IS NULL OR p_pa_project_asset_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
        AND (p_pm_asset_reference IS NULL OR p_pm_asset_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) THEN

        l_project_asset_id := 0;

    ELSE
        --Get project asset id based on PM Asset Reference
        PA_PROJECT_ASSETS_PUB.convert_pm_assetref_to_id (
            p_pa_project_id        => l_project_id,
            p_pa_project_asset_id  => p_pa_project_asset_id,
            p_pm_asset_reference   => p_pm_asset_reference,
            p_out_project_asset_id => l_project_asset_id,
            p_return_status        => l_return_status );

        IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

    END IF;



    --If new assignment is Project-level, verify that no Task-level assignments exist for project
    IF l_task_id = 0 THEN
        OPEN task_assign_cur;
        FETCH task_assign_cur INTO task_assign_rec;
        IF task_assign_cur%FOUND THEN

            CLOSE task_assign_cur;
            --Task-level assignments already exist.  Raise error.
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_TASK_ASSIGNMENTS_EXIST'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'PROJ'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

	        p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE task_assign_cur;
    END IF;


    --If new assignment is Project-level and Common, verify that no Specific Asset assignments exist
    IF l_task_id = 0 AND l_project_asset_id = 0 THEN
        OPEN specific_assign_cur;
        FETCH specific_assign_cur INTO specific_assign_rec;
        IF specific_assign_cur%FOUND THEN

            CLOSE specific_assign_cur;
            --Specific asset assignments already exist.  Raise error.
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_ASSIGNMENTS_EXIST'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'PROJ'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

	        p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE specific_assign_cur;
    END IF;


    --If new assignment is Project-level and Specific, verify that no Common Asset assignments exist
    IF l_task_id = 0 AND l_project_asset_id <> 0 THEN
        OPEN common_assign_cur;
        FETCH common_assign_cur INTO common_assign_rec;
        IF common_assign_cur%FOUND THEN

            CLOSE common_assign_cur;
            --Common asset assignments already exist.  Raise error.
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_COMMON_ASSIGN_EXISTS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'PROJ'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

	        p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE common_assign_cur;
    END IF;



    --If new assignment is Task-level, perform task-level validations
    IF l_task_id <> 0 THEN

        --Verify that no Project-level assignments exist
        OPEN proj_assign_cur;
        FETCH proj_assign_cur INTO proj_assign_rec;
        IF proj_assign_cur%FOUND THEN

            CLOSE proj_assign_cur;
            --Project-level assignments already exist.  Raise error.
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PROJ_ASSIGNMENTS_EXIST'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'PROJ'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

	        p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE proj_assign_cur;


        --Determine if Task is either Top or Lowest Task, and error if neither
        OPEN top_task_cur(l_task_id);
        FETCH top_task_cur INTO top_task_rec;
        CLOSE top_task_cur;

        IF top_task_rec.top_task_id = l_task_id THEN --Task is a Top Task

            --If new assignment is Top Task-level, verify that no Lowest Task-level assignments exist beneath Top Task
            OPEN child_assign_cur(l_task_id);
            FETCH child_assign_cur INTO child_assign_rec;
            IF child_assign_cur%FOUND THEN

                CLOSE child_assign_cur;
                --Assignments exist below this Top Task. Raise error.
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_LOW_TASK_ASSIGN_EXIST'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'PROJ'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => ''
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

	            p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;

            END IF;
            CLOSE child_assign_cur;


        ELSE
            OPEN child_task_cur(l_task_id);
            FETCH child_task_cur INTO child_task_rec;
            IF child_task_cur%FOUND THEN

                CLOSE child_task_cur;
                --Task is neither top nor lowest task. Raise error.
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_ASSIGNMENTS_EXIST'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'PROJ'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => ''
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

	            p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;

            END IF;
            CLOSE child_task_cur;

            --Task is lowest task

            --If new assignment is Lowest Task-level, verify that no Top Task-level assignments exist above Lowest Task
            OPEN top_assign_cur(l_task_id);
            FETCH top_assign_cur INTO top_assign_rec;
            IF top_assign_cur%FOUND THEN

                CLOSE top_assign_cur;
                --Assignments exist above this Lowest Task. Raise error.
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_TOP_TASK_ASSIGN_EXIST'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'PROJ'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => ''
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

	            p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;

            END IF;
            CLOSE top_assign_cur;

        END IF;



        --If new assignment is Task-level and Common, verify that no Specific Asset assignments exist for the task
        IF l_project_asset_id = 0 THEN

            OPEN task_specific_assign_cur(l_task_id);
            FETCH task_specific_assign_cur INTO task_specific_assign_rec;
            IF task_specific_assign_cur%FOUND THEN

                CLOSE task_specific_assign_cur;
                --Specific asset assignments already exist.  Raise error.
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_ASSIGNMENTS_EXIST'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'PROJ'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => ''
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

	            p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE task_specific_assign_cur;
        END IF;


        --If new assignment is Task-level and Specific, verify that no Common assignment exists for the task
        IF l_project_asset_id <> 0 THEN

            OPEN task_common_assign_cur(l_task_id);
            FETCH task_common_assign_cur INTO task_common_assign_rec;
            IF task_common_assign_cur%FOUND THEN

                CLOSE task_common_assign_cur;
                --Common asset assignments already exist.  Raise error.
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_COMMON_ASSIGN_EXISTS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'PROJ'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => ''
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

	            p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE task_common_assign_cur;
        END IF;

    END IF; --Task-Level Validations


    --Populate attributes for insert
    l_attribute_category := p_attribute_category;
    l_attribute1 := p_attribute1;
    l_attribute2 := p_attribute2;
    l_attribute3 := p_attribute3;
    l_attribute4 := p_attribute4;
    l_attribute5 := p_attribute5;
    l_attribute6 := p_attribute6;
    l_attribute7 := p_attribute7;
    l_attribute8 := p_attribute8;
    l_attribute9 := p_attribute9;
    l_attribute10 := p_attribute10;
    l_attribute11 := p_attribute11;
    l_attribute12 := p_attribute12;
    l_attribute13 := p_attribute13;
    l_attribute14 := p_attribute14;
    l_attribute15 := p_attribute15;


    --Set any unspecified values to NULL
    IF p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute_category := NULL;
    END IF;

    IF p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute1 := NULL;
    END IF;

    IF p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute2 := NULL;
    END IF;

    IF p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute3 := NULL;
    END IF;

    IF p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute4 := NULL;
    END IF;

    IF p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute5 := NULL;
    END IF;

    IF p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute6 := NULL;
    END IF;

    IF p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute7 := NULL;
    END IF;

    IF p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute8 := NULL;
    END IF;

    IF p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute9 := NULL;
    END IF;

    IF p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute10 := NULL;
    END IF;

    IF p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute11 := NULL;
    END IF;

    IF p_attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute12 := NULL;
    END IF;

    IF p_attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute13 := NULL;
    END IF;

    IF p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute14 := NULL;
    END IF;

    IF p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute15 := NULL;
    END IF;



    --Before inserting, check if an assignment exists which matches the current assignment exactly
    OPEN existing_assignment_cur(l_project_id, l_task_id, l_project_asset_id);
    FETCH existing_assignment_cur INTO existing_assignment_rec;
    IF existing_assignment_cur%NOTFOUND THEN

        --Insert new assignment
        INSERT INTO pa_project_asset_assignments
            (project_asset_id,
            task_id,
            project_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15
            )
        VALUES
            (l_project_asset_id,
            l_task_id,
            l_project_id,
            SYSDATE, --last_update_date
            FND_GLOBAL.user_id, --last_updated_by
            SYSDATE, --creation_date
            FND_GLOBAL.user_id, --created_by
            FND_GLOBAL.login_id, --last_update_login
            l_attribute_category,
            l_attribute1,
            l_attribute2,
            l_attribute3,
            l_attribute4,
            l_attribute5,
            l_attribute6,
            l_attribute7,
            l_attribute8,
            l_attribute9,
            l_attribute10,
            l_attribute11,
            l_attribute12,
            l_attribute13,
            l_attribute14,
            l_attribute15
            );
    END IF; --No matching assignment currently exists
    CLOSE existing_assignment_cur;


    --Populate OUT parameters
    p_pa_task_id_out := l_task_id;
    p_pa_project_asset_id_out := l_project_asset_id;


    --Perform commit if indicated
    IF FND_API.to_boolean( p_commit ) THEN
	    COMMIT;
    END IF;



 EXCEPTION
  	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO add_asset_assignment_pub;

		p_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
	   ROLLBACK TO add_asset_assignment_pub;

	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

 	WHEN OTHERS	THEN
	   ROLLBACK TO add_asset_assignment_pub;

	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		  FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

	   END IF;

	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

 END add_asset_assignment;



--------------------------------------------------------------------------------
--Name:               update_project_asset
--Type:               Procedure
--Description:        This procedure updates a project asset to an OP project, when this is allowed.
--
--
--
--Called subprograms:
--
--
--
--History:
--    15-JAN-2003    JPULTORAK       Created
--    15-Mar-2005    ANIGAM          Bug 4228421: Added an if condition to handle the case when the following attributes are null:
--                                   ASSET NUMBER, ASSET UNITS, MANUFACTURER_NAME,MODEL_NUMBER,SERIAL_NUMBER, attribute_category,
--				     attribute1, attribute2, attribute3, attribute4, attribute5, attribute6, attribute7, attribute8,
--				     attribute9, attribute10, attribute11, attribute12, attribute13, attribute14, attribute15,
--				     while performing validations and checks to see if fields have been changed.
--
PROCEDURE update_project_asset
( p_api_version_number		IN	NUMBER
 ,p_commit					IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status		    OUT	 NOCOPY VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_asset_id	    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_asset_name			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_number			IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_description		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_asset_type		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_location_id				IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_assigned_to_person_id	IN 	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_date_placed_in_service	IN 	DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_asset_category_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_book_type_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_units				IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_estimated_asset_units	IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_estimated_cost			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_depreciate_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_depreciation_expense_ccid IN	NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_amortize_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_estimated_in_service_date IN	DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_asset_key_ccid			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_parent_asset_id		    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_manufacturer_name		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_model_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_serial_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_tag_number				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_ret_target_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_project_id_out		OUT NOCOPY	NUMBER
 ,p_pa_project_number_out	OUT NOCOPY	VARCHAR2
 ,p_pa_project_asset_id_out	OUT	NOCOPY NUMBER
 ,p_pm_asset_reference_out  OUT NOCOPY VARCHAR2) IS


     --Used to get the project number for AMG messages
    CURSOR l_amg_project_csr(x_project_id   NUMBER) IS
    SELECT  segment1
    FROM    pa_projects p
    WHERE   p.project_id = x_project_id;

    l_amg_project_number             pa_projects_all.segment1%TYPE;


    --Used to get the asset number for AMG messages
    CURSOR l_amg_asset_csr(x_project_asset_id   NUMBER) IS
    SELECT  asset_name
    FROM    pa_project_assets p
    WHERE   p.project_asset_id = x_project_asset_id;

    l_amg_pa_asset_name              pa_project_assets_all.asset_name%TYPE;


    --Used to determine if the project is CAPITAL
    CURSOR capital_project_cur(x_project_id   NUMBER) IS
    SELECT  'Project is CAPITAL'
    FROM    pa_projects p,
            pa_project_types t
    WHERE   p.project_id = x_project_id
    AND     p.project_type = t.project_type
    AND     t.project_type_class_code = 'CAPITAL';

    capital_project_rec      capital_project_cur%ROWTYPE;


    CURSOR l_lock_rows_csr( x_project_asset_id NUMBER) IS
    SELECT  'x'
    FROM	pa_project_assets_all
    WHERE   project_asset_id = x_project_asset_id
    FOR UPDATE NOWAIT;


    CURSOR  l_asset_cur (x_project_id NUMBER, x_project_asset_id NUMBER) IS
    SELECT  *
    FROM    pa_project_assets_all
    WHERE   project_id = x_project_id
    AND     project_asset_id = x_project_asset_id;

    l_asset_rec         l_asset_cur%ROWTYPE;


    --USed to determine if Project Asset Type is valid
    CURSOR  valid_type_cur IS
    SELECT  meaning
    FROM    pa_lookups
    WHERE   lookup_type = 'PROJECT_ASSET_TYPES'
    AND     lookup_code = p_project_asset_type;

    valid_type_rec      valid_type_cur%ROWTYPE;

    --Used to determine if asset ref is unique within project
    CURSOR  unique_ref_cur(x_project_id  NUMBER) IS
    SELECT  'Asset Ref Exists'
    FROM    pa_project_assets_all
    WHERE   project_id = x_project_id
    AND     pm_asset_reference = p_pm_asset_reference;

    unique_ref_rec      unique_ref_cur%ROWTYPE;


    --Used to determine if asset name is unique within project
    CURSOR  unique_name_cur(x_project_id  NUMBER) IS
    SELECT  'Asset Name Exists'
    FROM    pa_project_assets_all
    WHERE   project_id = x_project_id
    AND     asset_name = p_pa_asset_name;

    unique_name_rec      unique_name_cur%ROWTYPE;


    --Used to determine if asset number is unique
    CURSOR  unique_number_cur IS
    SELECT  'Asset Number Exists'
    FROM    pa_project_assets_all
    WHERE   asset_number = p_asset_number;

    unique_number_rec      unique_number_cur%ROWTYPE;


    --Used to determine if Tag Number is unique in Oracle Assets
    CURSOR  unique_tag_number_fa_cur IS
    SELECT  'Tag Number Exists'
    FROM    fa_additions
    WHERE   tag_number = p_tag_number;

    unique_tag_number_fa_rec      unique_tag_number_fa_cur%ROWTYPE;


    --Used to determine if Tag Number is unique in Oracle Projects
    CURSOR  unique_tag_number_pa_cur IS
    SELECT  'Tag Number Exists'
    FROM    pa_project_assets_all
    WHERE   tag_number = p_tag_number;

    unique_tag_number_pa_rec      unique_tag_number_pa_cur%ROWTYPE;


    --Used to determine if asset location is valid
    CURSOR  asset_location_cur IS
    SELECT  'Asset Location Exists'
    FROM    fa_locations
    WHERE   location_id = p_location_id
    AND     enabled_flag = 'Y';

    asset_location_rec      asset_location_cur%ROWTYPE;


    --Used to determine if assigned to person is valid
    CURSOR  people_cur IS
    SELECT  'Person Exists'
    FROM    per_people_x
    WHERE   person_id = p_assigned_to_person_id
    --CWK changes, added the below condition
    AND     nvl(current_employee_flag, 'N') = 'Y';

    people_rec      people_cur%ROWTYPE;


    --Used to determine if the book type code is valid for the current SOB
    CURSOR  book_type_code_cur IS
    SELECT  'Book Type Code is valid'
    FROM    fa_book_controls fb,
            pa_implementations pi
    WHERE   fb.set_of_books_id = pi.set_of_books_id
    AND     fb.book_type_code = p_book_type_code
    AND     fb.book_class = 'CORPORATE';

    book_type_code_rec      book_type_code_cur%ROWTYPE;


    --Used to identify default book type code, if specified
    CURSOR  default_book_type_code_cur IS
    SELECT  pi.book_type_code
    FROM    pa_implementations pi
    WHERE   pi.book_type_code IS NOT NULL;


    --Used to determine if the asset category is valid
    CURSOR  asset_category_cur IS
    SELECT  'Asset Category is valid'
    FROM    fa_categories
    WHERE   category_id = p_asset_category_id
    AND     enabled_flag = 'Y';

    asset_category_rec      asset_category_cur%ROWTYPE;


    l_book_type_code                 FA_BOOK_CONTROLS.book_type_code%TYPE;
    l_date_placed_in_service         DATE;
    l_estimated_in_service_date      DATE;
    l_depreciate_flag                FA_CATEGORY_BOOK_DEFAULTS.depreciate_flag%TYPE := NULL;
    l_amortize_flag                  FA_BOOK_CONTROLS.amortize_flag%TYPE := NULL;


    --Used to determine if Parent Asset ID is valid in Oracle Assets
    CURSOR  parent_asset_cur IS
    SELECT  'Parent Asset Number Exists'
    FROM    fa_additions
    WHERE   asset_id = p_parent_asset_id
    AND     asset_type <> 'GROUP';

    parent_asset_rec      parent_asset_cur%ROWTYPE;


    --Used to determine if Parent Asset ID is valid for Book specified
    CURSOR  parent_asset_book_cur(x_parent_asset_id  NUMBER) IS
    SELECT  'Parent Asset Number Exists in Book'
    FROM    fa_additions fa,
            fa_books fb
    WHERE   fa.asset_id = x_parent_asset_id
    AND     fa.asset_type <> 'GROUP'
    AND     fa.asset_id = fb.asset_id
    AND     fb.book_type_code = l_book_type_code
    AND     fb.date_ineffective IS NULL;

    parent_asset_book_rec      parent_asset_book_cur%ROWTYPE;


    --Used to determine if the category/books combination is valid
    CURSOR  category_books_cur(x_asset_category_id  NUMBER) IS
    SELECT  'Category/Books combination is valid'
    FROM    fa_category_books
    WHERE   category_id = x_asset_category_id
    AND     book_type_code = l_book_type_code;

    category_books_rec      category_books_cur%ROWTYPE;


    --Used to default the depreciate_flag from category book defaults
    CURSOR  depreciate_flag_cur IS
    SELECT  SUBSTR(depreciate_flag,1,1)
    FROM    fa_category_book_defaults
    WHERE   category_id = p_asset_category_id
    AND     book_type_code = l_book_type_code
    AND     NVL(l_date_placed_in_service,NVL(l_estimated_in_service_date,TRUNC(SYSDATE)))
        BETWEEN start_dpis AND NVL(end_dpis,NVL(l_date_placed_in_service,NVL(l_estimated_in_service_date,TRUNC(SYSDATE))));


    l_depreciation_expense_ccid      NUMBER;

    --Used to determine if the Depreciation Expense CCID is valid for the current COA
    CURSOR  deprn_expense_cur IS
    SELECT  'Deprn Expense Acct code combination is valid'
    FROM    gl_code_combinations gcc,
            gl_sets_of_books gsob,
            pa_implementations pi
    WHERE   gcc.code_combination_id = l_depreciation_expense_ccid
    AND     gcc.chart_of_accounts_id = gsob.chart_of_accounts_id
    AND     gsob.set_of_books_id = pi.set_of_books_id
    AND     gcc.account_type = 'E';

    deprn_expense_rec      deprn_expense_cur%ROWTYPE;


    --Used to determine if the asset key is valid
    CURSOR  asset_key_cur IS
    SELECT  'Asset Key is valid'
    FROM    fa_asset_keywords
    WHERE   code_combination_id = p_asset_key_ccid
    AND     enabled_flag = 'Y';

    asset_key_rec      asset_key_cur%ROWTYPE;


    --Used to determine if the Ret Target Asset ID is a valid GROUP asset in the book
    CURSOR  ret_target_cur IS
    SELECT  fa.asset_category_id
    FROM    fa_books fb,
            fa_additions fa
    WHERE   fa.asset_id = p_ret_target_asset_id
    AND     fa.asset_type = 'GROUP'
    AND     fa.asset_id = fb.asset_id
    AND     fb.book_type_code = l_book_type_code
    AND     fb.date_ineffective IS NULL;

    ret_target_rec      ret_target_cur%ROWTYPE;




    l_api_name			   CONSTANT	 VARCHAR2(30) 		:= 'update_project_asset';
    l_update_yes_flag                VARCHAR2(1) := 'N';
    l_updated_dpis                   VARCHAR2(1) := 'N';
    l_updated_category_id            VARCHAR2(1) := 'N';
    l_updated_book_type_code         VARCHAR2(1) := 'N';
    l_updated_proj_asset_type        VARCHAR2(1) := 'N';
    l_updated_deprn_expense_ccid     VARCHAR2(1) := 'N';
    l_updated_location_id            VARCHAR2(1) := 'N';
    l_updated_asset_key_ccid         VARCHAR2(1) := 'N';
    l_statement                      VARCHAR2(2000);
    l_cursor                         INTEGER;
    l_rows                           INTEGER;
    l_project_asset_id               NUMBER := 0;
    l_pm_asset_reference             PA_PROJECT_ASSETS_ALL.pm_asset_reference%TYPE;
    l_project_id                     NUMBER;
    l_return_status                  VARCHAR2(1);
    l_function_allowed				 VARCHAR2(1);
    l_resp_id					     NUMBER := 0;
    l_user_id		                 NUMBER := 0;
    l_module_name                    VARCHAR2(80);
    l_msg_count					     NUMBER ;
    l_msg_data					     VARCHAR2(2000);
    v_intf_complete_asset_flag       VARCHAR2(1);
    v_asset_key_required             VARCHAR2(1);
    v_depreciation_expense_ccid      NUMBER;
    l_ovr_deprn_expense_ccid         NUMBER;
    l_asset_category_id              NUMBER;
    l_dpis                           DATE;

    --Variables used for validation of required Asset KFF segments
    fftype          FND_FLEX_KEY_API.FLEXFIELD_TYPE;
    numstruct       NUMBER;
    structnum       NUMBER;
    liststruct      FND_FLEX_KEY_API.STRUCTURE_LIST;
    thestruct       FND_FLEX_KEY_API.STRUCTURE_TYPE;
    numsegs         NUMBER;
    listsegs        FND_FLEX_KEY_API.SEGMENT_LIST;
    segtype         FND_FLEX_KEY_API.SEGMENT_TYPE;
    segname         FND_ID_FLEX_SEGMENTS.SEGMENT_NAME%TYPE;

    --Variables used as Bind Parameters for the Dynamic SQL Construct
    b_pm_asset_reference            PA_PROJECT_ASSETS_ALL.pm_asset_reference%TYPE;
    b_pa_asset_name                 PA_PROJECT_ASSETS_ALL.asset_name%TYPE;
    b_asset_description             PA_PROJECT_ASSETS_ALL.asset_description%TYPE;
    b_date_placed_in_service        PA_PROJECT_ASSETS_ALL.date_placed_in_service%TYPE;
    b_project_asset_type            PA_PROJECT_ASSETS_ALL.project_asset_type%TYPE;
    b_asset_number                  PA_PROJECT_ASSETS_ALL.asset_number%TYPE;
    b_location_id                   PA_PROJECT_ASSETS_ALL.location_id%TYPE;
    b_assigned_to_person_id         PA_PROJECT_ASSETS_ALL.assigned_to_person_id%TYPE;
    b_book_type_code                PA_PROJECT_ASSETS_ALL.book_type_code%TYPE;
    b_parent_asset_id               PA_PROJECT_ASSETS_ALL.parent_asset_id%TYPE;
    b_asset_category_id             PA_PROJECT_ASSETS_ALL.asset_category_id%TYPE;
    b_amortize_flag                 PA_PROJECT_ASSETS_ALL.amortize_flag%TYPE;
    b_depreciate_flag               PA_PROJECT_ASSETS_ALL.depreciate_flag%TYPE;
    b_depreciation_expense_ccid     PA_PROJECT_ASSETS_ALL.depreciation_expense_ccid%TYPE;
    b_asset_key_ccid                PA_PROJECT_ASSETS_ALL.asset_key_ccid%TYPE;
    b_ret_target_asset_id           PA_PROJECT_ASSETS_ALL.ret_target_asset_id%TYPE;
    b_asset_units                   PA_PROJECT_ASSETS_ALL.asset_units%TYPE;
    b_estimated_asset_units         PA_PROJECT_ASSETS_ALL.estimated_asset_units%TYPE;
    b_estimated_cost                PA_PROJECT_ASSETS_ALL.estimated_cost%TYPE;
    b_estimated_in_service_date     PA_PROJECT_ASSETS_ALL.estimated_in_service_date%TYPE; --Added for bug 4744574
    b_manufacturer_name             PA_PROJECT_ASSETS_ALL.manufacturer_name%TYPE;
    b_model_number                  PA_PROJECT_ASSETS_ALL.model_number%TYPE;
    b_tag_number                    PA_PROJECT_ASSETS_ALL.tag_number%TYPE;
    b_serial_number                 PA_PROJECT_ASSETS_ALL.serial_number%TYPE;
    b_attribute_category            PA_PROJECT_ASSETS_ALL.attribute_category%TYPE;
    b_attribute1                    PA_PROJECT_ASSETS_ALL.attribute1%TYPE;
    b_attribute2                    PA_PROJECT_ASSETS_ALL.attribute2%TYPE;
    b_attribute3                    PA_PROJECT_ASSETS_ALL.attribute3%TYPE;
    b_attribute4                    PA_PROJECT_ASSETS_ALL.attribute4%TYPE;
    b_attribute5                    PA_PROJECT_ASSETS_ALL.attribute5%TYPE;
    b_attribute6                    PA_PROJECT_ASSETS_ALL.attribute6%TYPE;
    b_attribute7                    PA_PROJECT_ASSETS_ALL.attribute7%TYPE;
    b_attribute8                    PA_PROJECT_ASSETS_ALL.attribute8%TYPE;
    b_attribute9                    PA_PROJECT_ASSETS_ALL.attribute9%TYPE;
    b_attribute10                   PA_PROJECT_ASSETS_ALL.attribute10%TYPE;
    b_attribute11                   PA_PROJECT_ASSETS_ALL.attribute11%TYPE;
    b_attribute12                   PA_PROJECT_ASSETS_ALL.attribute12%TYPE;
    b_attribute13                   PA_PROJECT_ASSETS_ALL.attribute13%TYPE;
    b_attribute14                   PA_PROJECT_ASSETS_ALL.attribute14%TYPE;
    b_attribute15                   PA_PROJECT_ASSETS_ALL.attribute15%TYPE;


 BEGIN

    --  Standard begin of API savepoint
    SAVEPOINT update_project_asset_pub;


    --  Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --	Initialize the message table if requested.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --  Set API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;


    --  pm_product_code is mandatory
    IF p_pm_product_code IS NULL OR p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
	    END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --Initialize variables
    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_module_name := 'PA_PM_UPDATE_PROJECT_ASSET';


    --Get Project ID from Project Reference
    PA_PROJECT_PVT.Convert_pm_projref_to_id
        (        p_pm_project_reference =>      p_pm_project_reference
                 ,  p_pa_project_id     =>      p_pa_project_id
                 ,  p_out_project_id    =>      l_project_id
                 ,  p_return_status     =>      l_return_status
        );

    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;


    -- Get project number for AMG messages
    OPEN l_amg_project_csr( l_project_id );
    FETCH l_amg_project_csr INTO l_amg_project_number;
    CLOSE l_amg_project_csr;


    --Validate that the project is CAPITAL project type class
    OPEN capital_project_cur(l_project_id);
    FETCH capital_project_cur INTO capital_project_rec;
	IF capital_project_cur%NOTFOUND THEN

        CLOSE capital_project_cur;
        -- The project must be CAPITAL. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PR_NOT_CAPITAL'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE capital_project_cur;



    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to update the project
    -- need to call the pa_security package

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    -- Function security procedure check whether user have the
    -- privilege to update project asset or not

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;

    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_UPDATE_PROJECT_ASSET',
       p_msg_count	        => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
	       p_return_status := FND_API.G_RET_STS_ERROR;
	       RAISE FND_API.G_EXC_ERROR;
    END IF;



    -- Now verify whether project security allows the user to update the project
    IF pa_security.allow_query (x_project_id => l_project_id ) = 'N' THEN

        -- The user does not have query privileges on this project
        -- Hence, cannot update the project.Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
    ELSE
        -- If the user has query privileges, then check whether
        -- update privileges are also available
        IF pa_security.allow_update (x_project_id => l_project_id ) = 'N' THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error

            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'Y'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

	        p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;


    --Get project asset id based on PM Asset Reference
    PA_PROJECT_ASSETS_PUB.convert_pm_assetref_to_id (
        p_pa_project_id        => l_project_id,
        p_pa_project_asset_id  => p_pa_project_asset_id,
        p_pm_asset_reference   => p_pm_asset_reference,
        p_out_project_asset_id => l_project_asset_id,
        p_return_status        => l_return_status );

    IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;


    --Get asset name for AMG messages
    IF p_pa_asset_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_pa_asset_name IS NULL THEN
        OPEN l_amg_asset_csr(l_project_asset_id);
        FETCH l_amg_asset_csr into l_amg_pa_asset_name;
        CLOSE l_amg_asset_csr;
    ELSE
        l_amg_pa_asset_name := p_pa_asset_name;
    END IF;


    --Lock the asset for update
	OPEN l_lock_rows_csr( l_project_asset_id );


    --Get the current data of this project asset
    OPEN l_asset_cur (l_project_id,l_project_asset_id );
    FETCH l_asset_cur INTO l_asset_rec;
    CLOSE l_asset_cur;


    --Initialize update variables
    l_update_yes_flag := 'N';
    l_statement := 'UPDATE PA_PROJECT_ASSETS SET ';

    --Set the date variables which are used in processing and cursors
    l_date_placed_in_service := NVL(p_date_placed_in_service, l_asset_rec.date_placed_in_service);
    l_estimated_in_service_date := NVL(p_estimated_in_service_date, l_asset_rec.estimated_in_service_date);



    --Perform validations and checks to see if fields have been changed

    --Fields where the PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR (_NUM, _DATE) is specified are
    --never updated, since this implies the parameter was not passed at all.
    --
    --Standard validation functionality in AMG seems to be inconsistent when a NULL value
    --is passed as a parameter.  In some instances AMG will update the field with a NULL, and
    --in other instances AMG will ignore fields for which NULL has been specified.  This
    --implies that the AMG user can never "NULL out" a field once it has a value using AMG.
    --It does have the benefit that the user can specify only the fields they wish to change,
    --and send NULL for all other fields.  However it would seem to be more "correct" if NULL
    --values sent in were actually updated with NULL, where valid and not required.  The AMG
    --user could then send the PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR (_NUM, _DATE) value when
    --they intend for no update of that field.
    --
    --For now I will follow this standard and not update fields with NULL when NULL is sent in
    --the parameter unless otherwise indicated.  Since no updates with NULLs will be done, I will
    --also not validate NULL values or issue errors when required fields have NULL specified.


    --	ASSET REFERENCE
    IF  p_pm_asset_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        AND  NVL(p_pm_asset_reference,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
		     NVL(l_asset_rec.pm_asset_reference, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
        AND  p_pm_asset_reference IS NOT NULL THEN

            --Verify that the new PM_ASSET_REFERENCE value is unique within the project
            OPEN unique_ref_cur(l_project_id);
            FETCH unique_ref_cur INTO unique_ref_rec;
	        IF unique_ref_cur%FOUND THEN
                CLOSE unique_ref_cur;
                -- The Asset Reference must be unique in the project. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_REF_NOT_UNIQUE_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
	        END IF;
	        CLOSE unique_ref_cur;


            l_statement := l_statement ||
                           ' PM_ASSET_REFERENCE = :b_pm_asset_reference'||',';
            l_update_yes_flag := 'Y';

            b_pm_asset_reference := p_pm_asset_reference;
            l_pm_asset_reference := p_pm_asset_reference;
    ELSE
       	    l_pm_asset_reference := l_asset_rec.pm_asset_reference;
    END IF;


    --	ASSET NAME
    IF  p_pa_asset_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        AND  NVL(p_pa_asset_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
		     NVL(l_asset_rec.asset_name, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
        AND  p_pa_asset_name IS NOT NULL THEN

            --Verify that the new ASSET_NAME value is unique within the project
            OPEN unique_name_cur(l_project_id);
            FETCH unique_name_cur INTO unique_name_rec;
	        IF unique_name_cur%FOUND THEN
                CLOSE unique_name_cur;
                -- The Asset Name must be unique in the project. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_NAME_NOT_UNIQ_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
	        END IF;
	        CLOSE unique_name_cur;


            l_statement := l_statement ||
                           ' ASSET_NAME = :b_pa_asset_name'||',';
            l_update_yes_flag := 'Y';
            b_pa_asset_name := p_pa_asset_name;
    END IF;


    --  ASSET DESCRIPTION
    IF (p_asset_description <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_asset_description IS NOT NULL)
        AND nvl(p_asset_description,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.asset_description,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

            l_statement := l_statement ||
                           ' ASSET_DESCRIPTION = :b_asset_description'||',';
            l_update_yes_flag := 'Y';
            b_asset_description := p_asset_description;
    END IF;


    --  PROJECT ASSET TYPE
    -- When Project Asset Type is being MODIFIED:
    IF (p_project_asset_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_project_asset_type IS NOT NULL)
        AND nvl(p_project_asset_type,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.project_asset_type,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN


        OPEN valid_type_cur;
        FETCH valid_type_cur INTO valid_type_rec;
	    IF valid_type_cur%NOTFOUND THEN

            CLOSE valid_type_cur;
            -- The Project Asset Type is invalid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
               ( p_old_message_code => 'PA_ASSET_TYPE_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE valid_type_cur;


        --Retirement Target Assets may not have their Project Asset Type modified
        IF p_project_asset_type <> 'RETIREMENT_ADJUSTMENT' AND l_asset_rec.project_asset_type = 'RETIREMENT_ADJUSTMENT' THEN

            -- Cannot change from or to RETIREMENT_ADJUSTMENT project type. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_CANNOT_UPDATE_RET_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;

        END IF;

        --Cannot change Estimated or As-Built Assets to Retirement Adjustment Targets
        IF p_project_asset_type = 'RETIREMENT_ADJUSTMENT' AND l_asset_rec.project_asset_type <> 'RETIREMENT_ADJUSTMENT' THEN

            -- Cannot change from or to RETIREMENT_ADJUSTMENT project type. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_CANNOT_UPDATE_RET_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;

        END IF;


        --Estimated Assets must specify an Actual DPIS and Asset Units if changing to 'AS-BUILT'
        IF p_project_asset_type = 'AS-BUILT' AND l_asset_rec.project_asset_type = 'ESTIMATED' THEN

            IF (p_date_placed_in_service IS NULL OR p_date_placed_in_service = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                AND l_asset_rec.date_placed_in_service IS NULL THEN

                -- The Actual DPIS is required for 'AS-BUILT' assets. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_DPIS_MISSING_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (p_asset_units IS NULL OR p_asset_units = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                AND l_asset_rec.asset_units IS NULL THEN

                -- The Asset Units are required for 'AS-BUILT' assets. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_UNITS_MISSING_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
            END IF;


            --Set DPIS to value specified
            l_statement := l_statement ||
                           ' DATE_PLACED_IN_SERVICE = :b_date_placed_in_service'||',';
            l_update_yes_flag := 'Y';
            b_date_placed_in_service := p_date_placed_in_service;
            l_updated_dpis := 'Y';
            l_date_placed_in_service := p_date_placed_in_service;

        END IF;

        --As-Built Assets Assets can only be changed to Estimated if not in an Event and not capitalized
        IF p_project_asset_type = 'ESTIMATED' AND l_asset_rec.project_asset_type = 'AS-BUILT' THEN

            --Capital Event ID must be NULL for the asset
            IF l_asset_rec.capital_event_id IS NOT NULL THEN

                -- The Asset has been processed.  Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_EVENT_NOT_NULL_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;

            END IF;


            --Date Placed in Service must be NULL
            IF (p_date_placed_in_service IS NOT NULL OR p_date_placed_in_service <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                AND l_asset_rec.date_placed_in_service IS NOT NULL THEN

                -- The Actual DPIS must be NULL for 'ESTIMATED' assets. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_DPIS_MB_NULL_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
            END IF;

            --Set DPIS to NULL
            l_statement := l_statement ||
                           ' DATE_PLACED_IN_SERVICE = NULL,';
            l_update_yes_flag := 'Y';
            l_updated_dpis := 'Y';
            l_date_placed_in_service := NULL;

        END IF;


        l_statement := l_statement ||
                           ' PROJECT_ASSET_TYPE = :b_project_asset_type'||',';
        l_update_yes_flag := 'Y';
        b_project_asset_type := p_project_asset_type;
        l_updated_proj_asset_type := 'Y';

    END IF; --Project Asset Type is being modified


    -- When Project Asset Type is NOT being modified
    IF (p_project_asset_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_project_asset_type IS NULL)
        OR nvl(p_project_asset_type,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) =
           nvl(l_asset_rec.project_asset_type,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )THEN


        --AS-BUILT Assets must specify an Actual DPIS and Asset Units
        IF l_asset_rec.project_asset_type = 'AS-BUILT' THEN

            IF (p_date_placed_in_service IS NULL) THEN

                -- The Actual DPIS is required for 'AS-BUILT' assets. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_DPIS_MISSING_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (p_asset_units IS NULL) THEN

                -- The Asset Units are required for 'AS-BUILT' assets. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_UNITS_MISSING_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        --ESTIMATED Assets must have a NULL DPIS
        IF l_asset_rec.project_asset_type = 'ESTIMATED' THEN

            --Date Placed in Service must be NULL
            -- Added and condition for bug 4744574
            IF (p_date_placed_in_service IS NOT NULL and
                 p_date_placed_in_service<>PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN

                -- The Actual DPIS must be NULL for 'ESTIMATED' assets. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_DPIS_MB_NULL_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;  --Validations when Project Asset Type is NOT being modified



    --  DPIS
    IF l_updated_dpis = 'N' --DPIS may have already been processed in the previous validations
        AND (p_date_placed_in_service <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_date_placed_in_service IS NULL)
        AND nvl(p_date_placed_in_service,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
            nvl(l_asset_rec.date_placed_in_service,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) THEN


        l_statement := l_statement ||
                           ' DATE_PLACED_IN_SERVICE = :b_date_placed_in_service'||',';
        l_update_yes_flag := 'Y';
        b_date_placed_in_service := p_date_placed_in_service;
    END IF;


    --  ASSET NUMBER
    IF (p_asset_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_asset_number IS NOT NULL) -- code change for bug 4228421
        AND nvl(p_asset_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.asset_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        --Asset Number must be unique
        OPEN unique_number_cur;
        FETCH unique_number_cur INTO unique_number_rec;
        IF unique_number_cur%FOUND THEN

            CLOSE unique_number_cur;
            -- The Asset Number must be unique. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_NUM_NOT_UNIQUE_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE unique_number_cur;

        l_statement := l_statement ||
                           ' ASSET_NUMBER = :b_asset_number'||',';
        l_update_yes_flag := 'Y';
        b_asset_number := p_asset_number;
-- Start of code addition for bug 4228421
    ELSIF (p_asset_number IS NULL) --Changing value to NULL
        AND nvl(p_asset_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.asset_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' ASSET_NUMBER = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug 4228421
    END IF;


    -- ASSET LOCATION ID
    IF (p_location_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_location_id IS NOT NULL)
        AND nvl(p_location_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.location_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        --Location ID must be valid
        OPEN asset_location_cur;
        FETCH asset_location_cur INTO asset_location_rec;
        IF asset_location_cur%NOTFOUND THEN

            CLOSE asset_location_cur;
            -- The Asset Location is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSET_LOC_INVALID_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE asset_location_cur;


        l_statement := l_statement ||
                           ' LOCATION_ID = :b_location_id'||',';
        l_update_yes_flag := 'Y';
        b_location_id := p_location_id;
        l_updated_location_id := 'Y';

    ELSIF (p_location_id IS NULL) --Changing value to NULL
        AND nvl(p_location_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.location_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' LOCATION_ID = NULL,';
        l_update_yes_flag := 'Y';
        l_updated_location_id := 'Y';

    END IF;


    -- ASSIGNED TO PERSON ID
    IF (p_assigned_to_person_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_assigned_to_person_id IS NOT NULL)
        AND nvl(p_assigned_to_person_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.assigned_to_person_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        --Assigned to Person must be a valid Person
        OPEN people_cur;
        FETCH people_cur INTO people_rec;
        IF people_cur%NOTFOUND THEN

            CLOSE people_cur;
            -- The Assign to Person is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_ASSGN_TO_PER_INVALID_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE people_cur;

        l_statement := l_statement ||
                           ' ASSIGNED_TO_PERSON_ID = :b_assigned_to_person_id'||',';
        l_update_yes_flag := 'Y';
        b_assigned_to_person_id := p_assigned_to_person_id;

    ELSIF (p_assigned_to_person_id IS NULL) --Changing value to NULL
        AND nvl(p_assigned_to_person_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.assigned_to_person_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' ASSIGNED_TO_PERSON_ID = NULL,';
        l_update_yes_flag := 'Y';

    END IF;


    -- BOOK TYPE CODE
    IF (p_book_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_book_type_code IS NOT NULL)
        AND nvl(p_book_type_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.book_type_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        --Book Type Code must be valid for the current SOB
        OPEN book_type_code_cur;
        FETCH book_type_code_cur INTO book_type_code_rec;
	    IF book_type_code_cur%NOTFOUND THEN

            CLOSE book_type_code_cur;
            -- The book_type_code is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_BOOK_TYPE_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        ELSE
            l_book_type_code := p_book_type_code;
	    END IF;
	    CLOSE book_type_code_cur;

        l_statement := l_statement ||
                           ' BOOK_TYPE_CODE = :b_book_type_code'||',';
        l_update_yes_flag := 'Y';
        b_book_type_code := p_book_type_code;
        l_updated_book_type_code := 'Y';

    ELSIF (p_book_type_code IS NULL)
        AND nvl(p_book_type_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.book_type_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' BOOK_TYPE_CODE = NULL,';
        l_update_yes_flag := 'Y';
        l_updated_book_type_code := 'Y';
        l_book_type_code := NULL;

    ELSE
        l_book_type_code := l_asset_rec.book_type_code;
    END IF;



    -- BOOK TYPE CODE Cross-Validations with existing Parent Asset ID
    IF l_updated_book_type_code = 'Y' AND l_book_type_code IS NOT NULL
        AND p_parent_asset_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        AND l_asset_rec.parent_asset_id IS NOT NULL THEN

        OPEN parent_asset_book_cur(l_asset_rec.parent_asset_id);
        FETCH parent_asset_book_cur INTO parent_asset_book_rec;
	    IF parent_asset_book_cur%NOTFOUND THEN

            CLOSE parent_asset_book_cur;
            -- The parent asset/books combination is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_PARENT_BOOK_INVALID_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE parent_asset_book_cur;

    END IF; --Book Type Code Cross-Validation with existing Parent Asset ID



    -- BOOK TYPE CODE Cross-Validations with existing Category
    IF l_updated_book_type_code = 'Y' AND l_book_type_code IS NOT NULL
        AND p_asset_category_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        AND l_asset_rec.asset_category_id IS NOT NULL THEN

        OPEN category_books_cur(l_asset_rec.asset_category_id);
        FETCH category_books_cur INTO category_books_rec;
	    IF category_books_cur%NOTFOUND THEN

            CLOSE category_books_cur;
            -- The category/books combination is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_CAT_BOOKS_INVALID_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE category_books_cur;

    END IF; --Book Type Code Cross-Validation with existing Category


    -- PARENT ASSET ID
    IF (p_parent_asset_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_parent_asset_id IS NOT NULL)
        AND nvl(p_parent_asset_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.parent_asset_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        --Parent Asset must be valid in Oracle Assets
        OPEN parent_asset_cur;
        FETCH parent_asset_cur INTO parent_asset_rec;
	    IF parent_asset_cur%NOTFOUND THEN

            CLOSE parent_asset_cur;
            -- The parent_asset_id is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PARENT_ASSET_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE parent_asset_cur;


        --If l_book_type_code has a value, then the Parent Asset/Book combination must be valid
        IF l_book_type_code IS NOT NULL THEN
            OPEN parent_asset_book_cur(p_parent_asset_id);
            FETCH parent_asset_book_cur INTO parent_asset_book_rec;
	        IF parent_asset_book_cur%NOTFOUND THEN

                CLOSE parent_asset_book_cur;
                -- The parent asset/books combination is not valid. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_PARENT_BOOK_INVALID_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
	        END IF;
	        CLOSE parent_asset_book_cur;
        END IF; --Book Type Code populated


        l_statement := l_statement ||
                           ' PARENT_ASSET_ID = :b_parent_asset_id'||',';
        l_update_yes_flag := 'Y';
        b_parent_asset_id := p_parent_asset_id;

    ELSIF (p_parent_asset_id IS NULL) --Changing value to NULL
        AND nvl(p_parent_asset_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.parent_asset_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' PARENT_ASSET_ID = NULL,';
        l_update_yes_flag := 'Y';

    END IF; --Parent Asset ID is being changed


    -- ASSET CATEGORY ID
    IF (p_asset_category_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_asset_category_id IS NOT NULL)
        AND nvl(p_asset_category_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.asset_category_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        --Asset Category must be a valid Category ID value
        OPEN asset_category_cur;
        FETCH asset_category_cur INTO asset_category_rec;
	    IF asset_category_cur%NOTFOUND THEN

            CLOSE asset_category_cur;
            -- The asset_category is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_CATEGORY_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE asset_category_cur;


        --If l_book_type_code has a value, then the Category/Book combination must be valid
        IF l_book_type_code IS NOT NULL THEN
            OPEN category_books_cur(p_asset_category_id);
            FETCH category_books_cur INTO category_books_rec;
	        IF category_books_cur%NOTFOUND THEN

                CLOSE category_books_cur;
                -- The category/books combination is not valid. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_CAT_BOOKS_INVALID_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
	        END IF;
	        CLOSE category_books_cur;


            --Default depreciate_flag from category book defaults if not specified
            IF p_depreciate_flag IS NULL OR p_depreciate_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                OPEN depreciate_flag_cur;
                FETCH depreciate_flag_cur INTO l_depreciate_flag;
	            IF depreciate_flag_cur%NOTFOUND THEN
                    l_depreciate_flag := NULL;
	            END IF;
	            CLOSE depreciate_flag_cur;

            END IF; --Depreciate Flag not specified


            --Default amortize_flag to 'N' if not specified
            IF p_amortize_flag IS NULL OR p_amortize_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

                l_amortize_flag := 'N';

            END IF; --Amortize Flag not specified

        END IF; --l_book_type_code populated



        l_statement := l_statement ||
                           ' ASSET_CATEGORY_ID = :b_asset_category_id'||',';
        l_update_yes_flag := 'Y';
        b_asset_category_id := p_asset_category_id;
        l_updated_category_id := 'Y';

    ELSIF (p_asset_category_id IS NULL) --Changing value to NULL
        AND nvl(p_asset_category_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.asset_category_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' ASSET_CATEGORY_ID = NULL,';
        l_update_yes_flag := 'Y';
        l_updated_category_id := 'Y';

    END IF; --Asset Category is being changed


    -- AMORTIZE FLAG
    IF l_amortize_flag IS NOT NULL THEN

        l_statement := l_statement ||
                           ' AMORTIZE_FLAG = :b_amortize_flag'||',';
        l_update_yes_flag := 'Y';
        b_amortize_flag := l_amortize_flag;

    ELSIF (p_amortize_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_amortize_flag IS NOT NULL)
        AND nvl(p_amortize_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.amortize_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        --Amortize Flag must be 'Y' or 'N'
        IF p_amortize_flag NOT IN ('Y','N') THEN
            -- The amortize_flag is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_AMORT_FLAG_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;


        l_statement := l_statement ||
                           ' AMORTIZE_FLAG = :b_amortize_flag'||',';
        l_update_yes_flag := 'Y';
        b_amortize_flag := p_amortize_flag;

    END IF;


    -- DEPRECIATE FLAG
    IF l_depreciate_flag IS NOT NULL THEN

        l_statement := l_statement ||
                           ' DEPRECIATE_FLAG = :b_depreciate_flag'||',';
        l_update_yes_flag := 'Y';
        b_depreciate_flag := l_depreciate_flag;

    ELSIF (p_depreciate_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_depreciate_flag IS NOT NULL)
        AND nvl(p_depreciate_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.depreciate_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        --Depreciate Flag must be 'Y' or 'N'
        IF p_depreciate_flag NOT IN ('Y','N') THEN
            -- The depreciate_flag is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_DEPR_FLAG_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_statement := l_statement ||
                           ' DEPRECIATE_FLAG = :b_depreciate_flag'||',';
        l_update_yes_flag := 'Y';
        b_depreciate_flag := p_depreciate_flag;

    END IF;


    -- DEPRECIATION EXPENSE CCID
    l_depreciation_expense_ccid := p_depreciation_expense_ccid;

    -- Call the Depreciation Expense CCID override client extension whenever Book Type Code,
    -- Asset Category, DPIS or Deprn Expense CCID are being modified and the project asset type is 'AS-BUILT'
    IF ((l_updated_proj_asset_type = 'Y' AND p_project_asset_type = 'AS-BUILT')
        OR (l_updated_proj_asset_type = 'N' AND l_asset_rec.project_asset_type = 'AS-BUILT')) THEN

        --Determine parameters for client extension call
        IF l_updated_dpis = 'Y' THEN
            l_dpis := p_date_placed_in_service;
        ELSE
            l_dpis := l_asset_rec.date_placed_in_service;
        END IF;

        IF l_updated_category_id = 'Y' THEN
            l_asset_category_id := p_asset_category_id;
        ELSE
            l_asset_category_id := l_asset_rec.asset_category_id;
        END IF;

        IF p_depreciation_expense_ccid IS NULL THEN
            v_depreciation_expense_ccid := NULL;
        ELSIF p_depreciation_expense_ccid = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
            v_depreciation_expense_ccid := l_asset_rec.depreciation_expense_ccid;
        ELSE
            v_depreciation_expense_ccid := p_depreciation_expense_ccid;
        END IF;



        IF l_asset_category_id IS NOT NULL
            AND l_book_type_code IS NOT NULL
            AND l_date_placed_in_service IS NOT NULL THEN

            l_ovr_deprn_expense_ccid := PA_CLIENT_EXTN_DEPRN_EXP_OVR.DEPRN_EXPENSE_ACCT_OVERRIDE
                                        (p_project_asset_id        => l_project_asset_id,
                                         p_book_type_code          => l_book_type_code,
			                             p_asset_category_id       => l_asset_category_id,
                                         p_date_placed_in_service  => l_dpis,
                                         p_deprn_expense_acct_ccid => v_depreciation_expense_ccid);


            IF NVL(l_ovr_deprn_expense_ccid,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
                NVL(p_depreciation_expense_ccid,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

                l_depreciation_expense_ccid := l_ovr_deprn_expense_ccid;

            END IF;  --Override value must be used during update
        END IF;
    END IF;



    -- DEPRECIATION EXPENSE CCID
    IF (l_depreciation_expense_ccid <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND l_depreciation_expense_ccid IS NOT NULL)
        AND nvl(l_depreciation_expense_ccid,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.depreciation_expense_ccid,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        --Depreciation Expense CCID must be a valid Code Combination
        OPEN deprn_expense_cur;
        FETCH deprn_expense_cur INTO deprn_expense_rec;
	    IF deprn_expense_cur%NOTFOUND THEN

            CLOSE deprn_expense_cur;
            -- The depreciation_expense_ccid is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_DEPRN_EXP_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE deprn_expense_cur;


        l_statement := l_statement ||
                           ' DEPRECIATION_EXPENSE_CCID = :b_depreciation_expense_ccid'||',';
        l_update_yes_flag := 'Y';
        b_depreciation_expense_ccid := l_depreciation_expense_ccid;
        l_updated_deprn_expense_ccid := 'Y';

    ELSIF (l_depreciation_expense_ccid IS NULL) --Changing value to NULL
        AND nvl(p_depreciation_expense_ccid,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.depreciation_expense_ccid,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' DEPRECIATION_EXPENSE_CCID = NULL,';
        l_update_yes_flag := 'Y';
        l_updated_deprn_expense_ccid := 'Y';

    END IF;


    -- ASSET KEY CCID
    IF (p_asset_key_ccid <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_asset_key_ccid IS NOT NULL)
        AND nvl(p_asset_key_ccid,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.asset_key_ccid,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        --Asset Key CCID must be a valid FA Keywords combination
        OPEN asset_key_cur;
        FETCH asset_key_cur INTO asset_key_rec;
	    IF asset_key_cur%NOTFOUND THEN

            CLOSE asset_key_cur;
            -- The asset_key_ccid is not valid. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_KEY_INVALID_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE asset_key_cur;


        l_statement := l_statement ||
                           ' ASSET_KEY_CCID = :b_asset_key_ccid'||',';
        l_update_yes_flag := 'Y';
        b_asset_key_ccid := p_asset_key_ccid;
        l_updated_asset_key_ccid := 'Y';

    ELSIF (p_asset_key_ccid IS NULL) --Changing value to NULL
        AND nvl(p_asset_key_ccid,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.asset_key_ccid,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' ASSET_KEY_CCID = NULL,';
        l_update_yes_flag := 'Y';
        l_updated_asset_key_ccid := 'Y';

    END IF;


    --If current project_asset_type is 'RETIREMENT_ADJUSTMENT', the Ret Target Asset ID must be specified
    IF l_asset_rec.project_asset_type = 'RETIREMENT_ADJUSTMENT' THEN
        IF (p_ret_target_asset_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_ret_target_asset_id IS NOT NULL)
            AND nvl(p_ret_target_asset_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
                nvl(l_asset_rec.ret_target_asset_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

            --Ret Target Asset ID must be a valid Group Asset for the Book
            OPEN ret_target_cur;
            FETCH ret_target_cur INTO ret_target_rec;
	        IF ret_target_cur%NOTFOUND THEN

                CLOSE ret_target_cur;
                -- The Ret Target Asset ID is not valid. Raise error
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_RET_ASSET_ID_INVALID_AS'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'ASSET'
                    ,p_attribute1       => l_amg_project_number
                    ,p_attribute2       => l_amg_pa_asset_name
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;

                RAISE FND_API.G_EXC_ERROR;
	        END IF;
	        CLOSE ret_target_cur;

            --If Asset Category ID is NULL and has not been updated, default it to the Category of the Ret Target Asset
            IF l_updated_category_id = 'N'
                AND (p_asset_category_id IS NULL OR p_asset_category_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

                l_statement := l_statement ||
                           ' ASSET_CATEGORY_ID = :b_asset_category_id'||',';
                l_update_yes_flag := 'Y';
                b_asset_category_id := ret_target_rec.asset_category_id;
            END IF;


            l_statement := l_statement ||
                           ' RET_TARGET_ASSET_ID = :b_ret_target_asset_id'||',';
            l_update_yes_flag := 'Y';
            b_ret_target_asset_id := p_ret_target_asset_id;

        ELSIF (p_ret_target_asset_id IS NULL)
            AND nvl(p_ret_target_asset_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
                nvl(l_asset_rec.ret_target_asset_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

            --Ret Target Asset ID must be specified for RETIREMENT_ADJUSTMENT assets
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_RET_ASSET_ID_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;

        END IF;

    ELSE
        IF (p_ret_target_asset_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_ret_target_asset_id IS NOT NULL) THEN

            --Ret Target Asset ID must be not specified for ESTIMATED or AS-BUILT assets
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_RET_ASSET_ID_MB_NULL_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
         END IF;
    END IF; --Project Asset Type = RETIREMENT_ADJUSTMENT


    -- ASSET UNITS
    IF (p_asset_units <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_asset_units IS NOT NULL)
        AND nvl(p_asset_units,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.asset_units,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' ASSET_UNITS = :b_asset_units'||',';
        l_update_yes_flag := 'Y';
--        b_asset_units := p_asset_units;

-- Adding TRUNC Logic until Oracle Assets Allows fractional asset units
          b_asset_units := GREATEST(TRUNC(p_asset_units),1);
-- Start of code addition for bug 4228421
    ELSIF (p_asset_units IS NULL) --Changing value to NULL
        AND nvl(p_asset_units,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.asset_units,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' ASSET_UNITS = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug 4228421
    END IF;


   --Added for bug 4744574
   IF((p_estimated_in_service_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        OR  p_estimated_in_service_date IS NULL)
       AND
      (nvl(p_estimated_in_service_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
            nvl(l_asset_rec.estimated_in_service_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ))
       ) THEN
        l_statement := l_statement ||
                           ' ESTIMATED_IN_SERVICE_DATE = :b_estimated_in_service_date'||',';
        l_update_yes_flag := 'Y';
        b_estimated_in_service_date := p_estimated_in_service_date;
    END IF;
    --End changes for 4744574

    -- ESTIMATED_ASSET_UNITS
    IF (p_estimated_asset_units <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_estimated_asset_units IS NOT NULL)
        AND nvl(p_estimated_asset_units,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.estimated_asset_units,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' ESTIMATED_ASSET_UNITS = :b_estimated_asset_units'||',';
        l_update_yes_flag := 'Y';
--        b_estimated_asset_units := p_estimated_asset_units;

-- Adding TRUNC Logic until Oracle Assets Allows fractional asset units
          b_estimated_asset_units := GREATEST(TRUNC(p_estimated_asset_units),1);


    ELSIF (p_estimated_asset_units IS NULL) --Changing value to NULL
        AND nvl(p_estimated_asset_units,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.estimated_asset_units,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' ESTIMATED_ASSET_UNITS = NULL,';
        l_update_yes_flag := 'Y';

    END IF;


    -- ESTIMATED COST
    IF (p_estimated_cost <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_estimated_cost IS NOT NULL)
        AND nvl(p_estimated_cost,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.estimated_cost,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' ESTIMATED_COST = :b_estimated_cost'||',';
        l_update_yes_flag := 'Y';
        b_estimated_cost := p_estimated_cost;

    ELSIF (p_estimated_cost IS NULL) --Changing value to NULL
        AND nvl(p_estimated_cost,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
            nvl(l_asset_rec.estimated_cost,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN

        l_statement := l_statement ||
                           ' ESTIMATED_COST = NULL,';
        l_update_yes_flag := 'Y';

    END IF;


    -- MANUFACTURER_NAME

    IF (p_manufacturer_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_manufacturer_name IS NOT NULL) -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_manufacturer_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.manufacturer_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' MANUFACTURER_NAME = :b_manufacturer_name'||',';
        l_update_yes_flag := 'Y';
        b_manufacturer_name := p_manufacturer_name;
-- Added following code for bug 4228421
    ELSIF (p_manufacturer_name IS NULL) --Changing value to NULL
        AND nvl(p_manufacturer_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.manufacturer_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' MANUFACTURER_NAME = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addtion for bug 4228421
    END IF;

    -- MODEL_NUMBER

    IF (p_model_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_model_number IS NOT NULL) -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_model_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.model_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' MODEL_NUMBER = :b_model_number'||',';
        l_update_yes_flag := 'Y';
        b_model_number := p_model_number;
-- Added following code for bug 4228421
    ELSIF (p_model_number IS NULL) --Changing value to NULL
        AND nvl(p_model_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.model_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' MODEL_NUMBER = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addtion for bug 4228421
    END IF;



    -- TAG_NUMBER
    IF (p_tag_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tag_number IS NOT NULL)
        AND nvl(p_tag_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.tag_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN


        --If Tag Number is specified, it must not exist on other project assets or in Oracle Assets

        --Test for uniqueness in Oracle Assets
        OPEN unique_tag_number_fa_cur;
        FETCH unique_tag_number_fa_cur INTO unique_tag_number_fa_rec;
	    IF unique_tag_number_fa_cur%FOUND THEN

            CLOSE unique_tag_number_fa_cur;
            -- The Tag Number must be unique. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_TAG_NUM_FA_NOT_UNIQ_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE unique_tag_number_fa_cur;

        --Test for uniqueness in Oracle Projects
        OPEN unique_tag_number_pa_cur;
        FETCH unique_tag_number_pa_cur INTO unique_tag_number_pa_rec;
	    IF unique_tag_number_pa_cur%FOUND THEN

            CLOSE unique_tag_number_pa_cur;
            -- The Tag Number must be unique. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_TAG_NUM_PA_NOT_UNIQ_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE unique_tag_number_pa_cur;


        l_statement := l_statement ||
                           ' TAG_NUMBER = :b_tag_number'||',';
        l_update_yes_flag := 'Y';
        b_tag_number := p_tag_number;

    ELSIF (p_tag_number IS NULL) --Changing value to NULL
        AND nvl(p_tag_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.tag_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' TAG_NUMBER = NULL,';
        l_update_yes_flag := 'Y';

    END IF;


    -- SERIAL_NUMBER

    IF (p_serial_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_serial_number IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_serial_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.serial_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' SERIAL_NUMBER = :b_serial_number'||',';
        l_update_yes_flag := 'Y';
         b_serial_number := p_serial_number;
-- Added following code for bug 4228421
    ELSIF (p_serial_number IS NULL) --Changing value to NULL
        AND nvl(p_serial_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.serial_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' SERIAL_NUMBER = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

  --  Update the DFF fields
    IF (p_attribute_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute_category IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute_category,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute_category,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE_CATEGORY = :b_attribute_category'||',';
        l_update_yes_flag := 'Y';
         b_attribute_category := p_attribute_category;
-- Added following code for bug 4228421

    ELSIF (p_attribute_category IS NULL) --Changing value to NULL
        AND nvl(p_attribute_category,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute_category,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE_CATEGORY = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute1 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute1 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute1,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute1,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE1 = :b_attribute1'||',';
        l_update_yes_flag := 'Y';
         b_attribute1 := p_attribute1;
-- Added following code for bug 4228421
    ELSIF (p_attribute1 IS NULL) --Changing value to NULL
        AND nvl(p_attribute1,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute1,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE1 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute2 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute2 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute2,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute2,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE2 = :b_attribute2'||',';
        l_update_yes_flag := 'Y';
         b_attribute2 := p_attribute2;
 -- Added following code for bug 4228421
    ELSIF (p_attribute2 IS NULL) --Changing value to NULL
        AND nvl(p_attribute2,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute2,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE2 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute3 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute3 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute3,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute3,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE3 = :b_attribute3'||',';
        l_update_yes_flag := 'Y';
         b_attribute3 := p_attribute3;
-- Added following code for bug 4228421
    ELSIF (p_attribute3 IS NULL) --Changing value to NULL
        AND nvl(p_attribute3,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute3,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE3 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute4 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute4 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute4,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute4,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE4 = :b_attribute4'||',';
        l_update_yes_flag := 'Y';
         b_attribute4 := p_attribute4;
-- Added following code for bug 4228421
    ELSIF (p_attribute4 IS NULL) --Changing value to NULL
        AND nvl(p_attribute4,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute4,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE4 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute5 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute5 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute5,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute5,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE5 = :b_attribute5'||',';
        l_update_yes_flag := 'Y';
         b_attribute5 := p_attribute5;
-- Added following code for bug 4228421
    ELSIF (p_attribute5 IS NULL) --Changing value to NULL
        AND nvl(p_attribute5,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute5,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE5 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute6 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute6 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute6,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute6,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE6 = :b_attribute6'||',';
        l_update_yes_flag := 'Y';
         b_attribute6 := p_attribute6;
-- Added following code for bug 4228421
    ELSIF (p_attribute6 IS NULL) --Changing value to NULL
        AND nvl(p_attribute6,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute6,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE6 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute7 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute7 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute7,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute7,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE7 = :b_attribute7'||',';
        l_update_yes_flag := 'Y';
         b_attribute7 := p_attribute7;
-- Added following code for bug 4228421
    ELSIF (p_attribute7 IS NULL) --Changing value to NULL
        AND nvl(p_attribute7,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute7,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE7 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute8 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute8 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute8,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute8,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE8 = :b_attribute8'||',';
        l_update_yes_flag := 'Y';
         b_attribute8 := p_attribute8;
-- Added following code for bug 4228421
    ELSIF (p_attribute8 IS NULL) --Changing value to NULL
        AND nvl(p_attribute8,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute8,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE8 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute9 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute9 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute9,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute9,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE9 = :b_attribute9'||',';
        l_update_yes_flag := 'Y';
         b_attribute9 := p_attribute9;
-- Added following code for bug 4228421
    ELSIF (p_attribute9 IS NULL) --Changing value to NULL
        AND nvl(p_attribute9,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute9,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE9 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute10 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute10 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute10,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute10,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE10 = :b_attribute10'||',';
        l_update_yes_flag := 'Y';
         b_attribute10 := p_attribute10;
-- Added following code for bug 4228421
    ELSIF (p_attribute10 IS NULL) --Changing value to NULL
        AND nvl(p_attribute10,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute10,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE10 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute11 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute11 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute11,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute11,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE11 = :b_attribute11'||',';
        l_update_yes_flag := 'Y';
         b_attribute11 := p_attribute11;
-- Added following code for bug 4228421
    ELSIF (p_attribute11 IS NULL) --Changing value to NULL
        AND nvl(p_attribute11,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute11,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE11 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute12 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute12 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute12,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute12,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE12 = :b_attribute12'||',';
        l_update_yes_flag := 'Y';
         b_attribute12 := p_attribute12;
-- Added following code for bug 4228421
    ELSIF (p_attribute12 IS NULL) --Changing value to NULL
        AND nvl(p_attribute12,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute12,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE12 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute13 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute13 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute13,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute13,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE13 = :b_attribute13'||',';
        l_update_yes_flag := 'Y';
         b_attribute13 := p_attribute13;
-- Added following code for bug 4228421
    ELSIF (p_attribute13 IS NULL) --Changing value to NULL
        AND nvl(p_attribute13,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute13,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE13 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute14 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute14 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute14,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute14,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE14 = :b_attribute14'||',';
        l_update_yes_flag := 'Y';
         b_attribute14 := p_attribute14;
-- Added following code for bug 4228421
    ELSIF (p_attribute14 IS NULL) --Changing value to NULL
        AND nvl(p_attribute14,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute14,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE14 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;

    IF (p_attribute15 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute15 IS NOT NULL)  -- changed IS NULL condition to IS NOT NULL for bug 4228421
        AND nvl(p_attribute15,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute15,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE15 = :b_attribute15'||',';
        l_update_yes_flag := 'Y';
         b_attribute15 := p_attribute15;
-- Added following code for bug 4228421
    ELSIF (p_attribute15 IS NULL) --Changing value to NULL
        AND nvl(p_attribute15,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_asset_rec.attribute15,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

        l_statement := l_statement ||
                           ' ATTRIBUTE15 = NULL,';
        l_update_yes_flag := 'Y';
-- End of code addition for bug  4228421
    END IF;


    --No attributes may be updated for Capitalized assets or retirement adjustment targets
    IF l_update_yes_flag = 'Y' AND l_asset_rec.project_asset_type IN ('AS-BUILT','RETIREMENT_ADJUSTMENT')
        AND l_asset_rec.capitalized_flag = 'Y' THEN

        -- No asset attributes may be updated after capitalization. Raise error
        pa_interface_utils_pub.map_new_amg_msg
            ( p_old_message_code => 'PA_CANNOT_UPDATE_ASSET_AS'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'ASSET'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => l_amg_pa_asset_name
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;

    END IF;



    --Validate that the Asset Category, Book Type Code, Location, Asset Key, Depreciate Flag and Deprn Expense CCID
    --are NOT NULL if the Project Asset Type is AS-BUILT and Complete Asset Definition is required

    SELECT  NVL(pt.interface_complete_asset_flag,'N')
    INTO    v_intf_complete_asset_flag
    FROM    pa_project_types pt,
            pa_projects p
    WHERE   p.project_type = pt.project_type
    AND     p.project_id = l_project_id;


    IF v_intf_complete_asset_flag = 'Y' AND
        ((l_updated_proj_asset_type = 'Y' AND p_project_asset_type = 'AS-BUILT')
            OR (l_updated_proj_asset_type = 'N' AND l_asset_rec.project_asset_type = 'AS-BUILT')) THEN


        IF (l_updated_category_id = 'Y' AND (p_asset_category_id IS NULL OR p_asset_category_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
            OR (l_updated_category_id = 'N' AND l_asset_rec.asset_category_id IS NULL) THEN

            -- The Asset Category is required for 'AS-BUILT' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_CATEGORY_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;



        IF (l_updated_location_id = 'Y' AND (p_location_id IS NULL OR p_location_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
            OR (l_updated_location_id = 'N' AND l_asset_rec.location_id IS NULL) THEN

            -- The Asset Location is required for 'AS-BUILT' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_ASSET_LOC_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF l_book_type_code IS NULL OR l_book_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

            -- The Book Type Code is required for 'AS-BUILT' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_BOOK_TYPE_IS_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF (l_updated_deprn_expense_ccid = 'Y' AND (l_depreciation_expense_ccid IS NULL OR l_depreciation_expense_ccid = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
            OR (l_updated_deprn_expense_ccid = 'N' AND l_asset_rec.depreciation_expense_ccid IS NULL) THEN

            -- The Depreciation Expense CCID is required for 'AS-BUILT' assets. Raise error
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_DEPRN_EXP_MISSING_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

            p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF (l_updated_asset_key_ccid = 'Y' AND (p_asset_key_ccid IS NULL OR p_asset_key_ccid = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
            OR (l_updated_asset_key_ccid = 'N' AND l_asset_rec.asset_key_ccid IS NULL) THEN


            --Asset Key CCID must be specified if any of the segments are specified
            BEGIN
                SELECT  asset_key_flex_structure
                INTO    structnum
                FROM    fa_system_controls;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;

            IF structnum IS NOT NULL THEN

                FND_FLEX_KEY_API.SET_SESSION_MODE('seed_data');

                fftype := FND_FLEX_KEY_API.FIND_FLEXFIELD
                                (appl_short_name =>'OFA',
                                flex_code =>'KEY#');

                thestruct := FND_FLEX_KEY_API.FIND_STRUCTURE(fftype,structnum);

                FND_FLEX_KEY_API.GET_SEGMENTS(fftype,thestruct,TRUE,numsegs,listsegs);

                v_asset_key_required := 'N';

                FOR i IN 1 .. numsegs LOOP
                    segtype := FND_FLEX_KEY_API.FIND_SEGMENT(fftype,thestruct,listsegs(i));

                    IF (segtype.required_flag = 'Y' and segtype.enabled_flag = 'Y') THEN
                        v_asset_key_required := 'Y';
                    END IF;
                END LOOP;


                IF v_asset_key_required = 'Y' THEN

                    -- The Asset Key CCID is required. Raise error
                    pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_ASSET_KEY_MISSING_AS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'ASSET'
                        ,p_attribute1       => l_amg_project_number
                        ,p_attribute2       => l_amg_pa_asset_name
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');

                    p_return_status := FND_API.G_RET_STS_ERROR;

                    RAISE FND_API.G_EXC_ERROR;
                END IF; --Asset Key is required
            END IF; --Structnum was determined
        END IF; --Asset Key was not specified
    END IF; --AS-BUILT asset with Complete Asset Info required





    --Validations complete.  If any fields have been changed, update is required

    --Perform update if required
    IF l_update_yes_flag = 'Y' THEN

        l_statement := l_statement ||
                            ' LAST_UPDATE_DATE = SYSDATE'||',';

       	l_statement := 	l_statement ||
                           	' LAST_UPDATED_BY = '||FND_GLOBAL.USER_ID||',';

        l_statement := 	l_statement ||
                           	' LAST_UPDATE_LOGIN = '||FND_GLOBAL.LOGIN_ID;

       	l_statement := 	l_statement ||
                			' WHERE PROJECT_ASSET_ID = '|| TO_CHAR(l_project_asset_id);



        --Create and execute UPDATE statement
       	l_cursor := dbms_sql.open_cursor;
       	dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);

        --Populate Bind Variables if used
        IF b_pm_asset_reference IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_pm_asset_reference', RTRIM(b_pm_asset_reference));
        END IF;

        IF b_pa_asset_name IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_pa_asset_name', RTRIM(b_pa_asset_name));
        END IF;

        IF b_asset_description IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_asset_description', RTRIM(b_asset_description));
        END IF;

        IF b_date_placed_in_service IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_date_placed_in_service', b_date_placed_in_service);
        END IF;

        IF b_project_asset_type IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_project_asset_type', RTRIM(b_project_asset_type));
        END IF;

        IF b_asset_number IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_asset_number', RTRIM(b_asset_number));
        END IF;

        IF b_location_id IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_location_id', b_location_id);
        END IF;

        IF b_assigned_to_person_id IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_assigned_to_person_id', b_assigned_to_person_id);
        END IF;

        IF b_book_type_code IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_book_type_code', RTRIM(b_book_type_code));
        END IF;

        IF b_parent_asset_id IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_parent_asset_id', b_parent_asset_id);
        END IF;

        IF b_asset_category_id IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_asset_category_id', b_asset_category_id);
        END IF;

        IF b_amortize_flag IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_amortize_flag', RTRIM(b_amortize_flag));
        END IF;

        IF b_depreciate_flag IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_depreciate_flag', RTRIM(b_depreciate_flag));
        END IF;

        IF b_depreciation_expense_ccid IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_depreciation_expense_ccid', b_depreciation_expense_ccid);
        END IF;

        IF b_asset_key_ccid IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_asset_key_ccid', b_asset_key_ccid);
        END IF;

        IF b_ret_target_asset_id IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_ret_target_asset_id', b_ret_target_asset_id);
        END IF;

        IF b_asset_units IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_asset_units', b_asset_units);
        END IF;
         --Added for bug 4744574
        IF b_estimated_in_service_date IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_estimated_in_service_date', b_estimated_in_service_date);
        END IF;
         --End changes for 4744574

        IF b_estimated_asset_units IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_estimated_asset_units', b_estimated_asset_units);
        END IF;

        IF b_estimated_cost IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_estimated_cost', b_estimated_cost);
        END IF;

        IF b_manufacturer_name IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_manufacturer_name', RTRIM(b_manufacturer_name));
        END IF;

        IF b_model_number IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_model_number', RTRIM(b_model_number));
        END IF;

        IF b_tag_number IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_tag_number', RTRIM(b_tag_number));
        END IF;

        IF b_serial_number IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_serial_number', RTRIM(b_serial_number));
        END IF;

        IF b_attribute_category IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute_category', RTRIM(b_attribute_category));
        END IF;

        IF b_attribute1 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute1', RTRIM(b_attribute1));
        END IF;

        IF b_attribute2 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute2', RTRIM(b_attribute2));
        END IF;

        IF b_attribute3 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute3', RTRIM(b_attribute3));
        END IF;

        IF b_attribute4 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute4', RTRIM(b_attribute4));
        END IF;

        IF b_attribute5 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute5', RTRIM(b_attribute5));
        END IF;

        IF b_attribute6 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute6', RTRIM(b_attribute6));
        END IF;

        IF b_attribute7 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute7', RTRIM(b_attribute7));
        END IF;

        IF b_attribute8 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute8', RTRIM(b_attribute8));
        END IF;

        IF b_attribute9 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute9', RTRIM(b_attribute9));
        END IF;

        IF b_attribute10 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute10', RTRIM(b_attribute10));
        END IF;

        IF b_attribute11 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute11', RTRIM(b_attribute11));
        END IF;

        IF b_attribute12 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute12', RTRIM(b_attribute12));
        END IF;

        IF b_attribute13 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute13', RTRIM(b_attribute13));
        END IF;

        IF b_attribute14 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute14', RTRIM(b_attribute14));
        END IF;

        IF b_attribute15 IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':b_attribute15', RTRIM(b_attribute15));
        END IF;

        --Execute SQL Statement
       	l_rows   := dbms_sql.execute(l_cursor);

       	IF dbms_sql.is_open (l_cursor) THEN
       		dbms_sql.close_cursor (l_cursor);
       	END IF;
    END IF; --update flag = yes


    --Set output parameters
    p_pa_project_id_out := l_project_id;
    p_pa_project_number_out := l_amg_project_number;
    p_pa_project_asset_id_out := l_project_asset_id;
    p_pm_asset_reference_out := l_pm_asset_reference;


    CLOSE l_lock_rows_csr;  --FYI: doesn't remove locks

    IF FND_API.to_boolean( p_commit ) THEN
	    COMMIT;
    END IF;


 EXCEPTION
  	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO update_project_asset_pub;

		p_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
	    ROLLBACK TO update_project_asset_pub;

  	    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	    FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


    WHEN ROW_ALREADY_LOCKED THEN
	   ROLLBACK TO update_project_asset_pub;

	   p_return_status := FND_API.G_RET_STS_ERROR;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_AS_AMG');
           FND_MESSAGE.SET_TOKEN('PROJECT', l_amg_project_number);
           FND_MESSAGE.SET_TOKEN('ASSET',    l_amg_pa_asset_name);
           FND_MESSAGE.SET_TOKEN('ENTITY', G_ASSET_CODE);
           FND_MSG_PUB.ADD;
	   END IF;

	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


 	WHEN OTHERS	THEN
	    ROLLBACK TO update_project_asset_pub;

	    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		    FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

	    END IF;

	    FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

 END update_project_asset;





--====================================================================================
--Name:               convert_pm_assetref_to_id
--Type:               Procedure
--Description:        This procedure can be used to convert an incoming
--                    asset reference to a project asset ID.
--
--Called subprograms: none
--
--
--
--History:
--	20-JAN-2003	JPultorak    	Created
--
--Put this in PA_PROJECT_PVT if desired

PROCEDURE convert_pm_assetref_to_id (
 p_pa_project_id        IN NUMBER,
 p_pa_project_asset_id  IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_pm_asset_reference   IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_out_project_asset_id OUT NOCOPY NUMBER,
 p_return_status        OUT NOCOPY VARCHAR2 ) IS

CURSOR 	l_project_id_csr
IS
SELECT 	'X'
FROM	pa_projects
where   project_id = p_pa_project_id;


CURSOR 	l_project_asset_id_csr
IS
SELECT 	'X'
FROM	pa_project_assets
WHERE   project_asset_id = p_pa_project_asset_id
AND 	project_id = p_pa_project_id;


CURSOR  l_asset_csr IS
SELECT  project_asset_id
FROM    pa_project_assets_all
WHERE   project_id           = p_pa_project_id
AND     pm_asset_reference   = p_pm_asset_reference;

l_asset_rec      l_asset_csr%ROWTYPE;



l_api_name	CONSTANT	VARCHAR2(30) := 'Convert_pm_assetref_to_id';
l_dummy				    VARCHAR2(1);


   --Used to get the field values associated to a AMG message
   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   l_amg_segment1       VARCHAR2(25);

BEGIN

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    IF p_pa_project_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        AND p_pa_project_id IS NOT NULL THEN

      	OPEN l_project_id_csr;
      	FETCH l_project_id_csr INTO l_dummy;

      	IF l_project_id_csr%NOTFOUND THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_INVALID_PROJECT_ID'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'GENERAL'
                    ,p_attribute1       => ''
                    ,p_attribute2       => ''
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');
            END IF;

            CLOSE l_project_id_csr;
	        RAISE FND_API.G_EXC_ERROR;
      	END IF;

      	CLOSE l_project_id_csr;
    ELSE --p_pa_project_id has not been specified
      	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

            pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PROJECT_ID_MISSING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF; --p_pa_project_id has a value


    IF p_pa_project_asset_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       AND p_pa_project_asset_id IS NOT NULL THEN

        -- Get segment1 for AMG messages
        OPEN l_amg_project_csr( p_pa_project_id );
        FETCH l_amg_project_csr INTO l_amg_segment1;
        CLOSE l_amg_project_csr;

        OPEN l_project_asset_id_csr;
        FETCH l_project_asset_id_csr INTO l_dummy;

        IF l_project_asset_id_csr%NOTFOUND THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_PROJ_ASSET_ID_INVALID'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'PROJ'
                    ,p_attribute1       => l_amg_segment1
                    ,p_attribute2       => ''
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');
            END IF;

    		CLOSE l_project_asset_id_csr;
	       	RAISE FND_API.G_EXC_ERROR;
   	    END IF;

   	    CLOSE l_project_asset_id_csr;

        p_out_project_asset_id := p_pa_project_asset_id;

    ELSIF p_pm_asset_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        AND p_pm_asset_reference IS NOT NULL THEN

        OPEN l_asset_csr;
        FETCH l_asset_csr INTO l_asset_rec;
        IF l_asset_csr%NOTFOUND THEN
            CLOSE l_asset_csr;

            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- bug 2257612
                FND_MESSAGE.SET_TOKEN('ATTR_NAME','Pm Asset Reference');
                FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_pm_asset_reference);
                FND_MSG_PUB.add;

		        RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            p_out_project_asset_id := l_asset_rec.project_asset_id;
            CLOSE l_asset_csr;
        END IF;

    ELSE --Neither Project Asset ID nor PM Asset Reference Specified
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_ASSET_REF_ID_MISSING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'PROJ'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
     	END IF;

   		RAISE FND_API.G_EXC_ERROR;

    END IF; -- Project Asset ID or PM Asset Reference Specified


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
        /* dbms_output.put_line('handling an G_EXC_ERROR exception'); */

	    p_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
        /* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */

	    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS THEN
        /* dbms_output.put_line('handling an OTHERS exception'); */

	    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		    FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

	    END IF;

END Convert_pm_assetref_to_id;



--====================================================================================
--
--Name:               fetch_project_asset_id
--Type:               Function
--Description:        This function will return the Project Asset ID based on the
--                    asset reference.  If not found, it will return NULL.
--
--
--Called subprograms: none
--
--
--
--History:
--    01-MAR-2003     J. Pultorak    Created
--
--Put this in PA_PROJECT_PVT if desired
--

FUNCTION fetch_project_asset_id
( p_pa_project_id        IN NUMBER
 ,p_pm_asset_reference   IN VARCHAR2 ) RETURN NUMBER

IS

CURSOR c_asset_csr IS
SELECT  project_asset_id
FROM    pa_project_assets
WHERE   project_id = p_pa_project_id
AND     pm_asset_reference = p_pm_asset_reference;

l_asset_rec      c_asset_csr%ROWTYPE;

BEGIN

      OPEN c_asset_csr;
      FETCH  c_asset_csr INTO l_asset_rec.project_asset_id;
      IF c_asset_csr%NOTFOUND THEN
         CLOSE c_asset_csr;
         RETURN NULL;
      ELSE
         CLOSE c_asset_csr;
         RETURN l_asset_rec.project_asset_id;
      END IF;

END fetch_project_asset_id;




--------------------------------------------------------------------------------
--Name:               load_asset_assignment
--Type:               Procedure
--Description:        This procedure can be used to move a project asset assignment
-- 		              from the client side to a PL/SQL table on the server side,
--                    where it will be used by a LOAD/EXECUTE/FETCH cycle.
--
--Called subprograms:
--
--
--
--History:
--    01-MAR-2003    J. Pultorak    Created
--

PROCEDURE load_asset_assignment
 ( p_api_version_number		IN	NUMBER
  ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
  ,p_return_status		    OUT	NOCOPY VARCHAR2
  ,p_pm_task_reference	    IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_task_id			    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_project_asset_id	IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_attribute_category		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute1				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute2				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute3				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute4				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute5				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute6				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute7				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute8				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute9				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute10			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute11			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute12			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute13			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute14			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute15			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )

  IS

   l_api_name			CONSTANT	VARCHAR2(30) 		:= 'load_asset_assignment';
   i						NUMBER;


BEGIN

    --  Standard begin of API savepoint
    SAVEPOINT load_asset_assignment_pub;


    --  Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    ) THEN

    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --  Initialize the message table if requested.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --  Set API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;


    -- assign a value to the global counter for this table
    G_asset_assignments_tbl_count	:= G_asset_assignments_tbl_count + 1;


    -- assign incoming parameters to the global table fields
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).pa_task_id              := p_pa_task_id;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).pm_task_reference       := p_pm_task_reference;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).pa_project_asset_id     := p_pa_project_asset_id;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).pm_asset_reference      := p_pm_asset_reference;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute_category      := p_attribute_category;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute1              := p_attribute1;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute2              := p_attribute2;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute3              := p_attribute3;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute4              := p_attribute4;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute5              := p_attribute5;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute6              := p_attribute6;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute7              := p_attribute7;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute8              := p_attribute8;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute9              := p_attribute9;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute10             := p_attribute10;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute11             := p_attribute11;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute12             := p_attribute12;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute13             := p_attribute13;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute14             := p_attribute14;
    G_asset_assignments_in_tbl(G_asset_assignments_tbl_count).attribute15             := p_attribute15;



EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO load_asset_assignment_pub;
        p_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
        ROLLBACK TO load_asset_assignment_pub;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


	WHEN OTHERS THEN
        ROLLBACK TO load_asset_assignment_pub;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
    	END IF;

END load_asset_assignment;






--------------------------------------------------------------------------------
--Name:               load_project_asset
--Type:               Procedure
--Description:        This procedure can be used to move a project asset
-- 		              from the client side to a PL/SQL table on the server side,
--                    where it will be used by a LOAD/EXECUTE/FETCH cycle.
--
--Called subprograms:
--
--
--
--History:
--    01-MAR-2003    J. Pultorak    Created
--

PROCEDURE load_project_asset
( p_api_version_number	    IN	NUMBER
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_return_status		    OUT	NOCOPY VARCHAR2
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_asset_name			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_number			IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_description		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_asset_type		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_location_id				IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_assigned_to_person_id	IN 	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_date_placed_in_service	IN 	DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_asset_category_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_book_type_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_units				IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_estimated_asset_units	IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_estimated_cost			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_depreciate_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_depreciation_expense_ccid IN	NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_amortize_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_estimated_in_service_date IN	DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_asset_key_ccid			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_parent_asset_id		    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_manufacturer_name		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_model_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_serial_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_tag_number				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_ret_target_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  )

IS

   l_api_name			CONSTANT	VARCHAR2(30) 		:= 'load_project_asset';
   i						NUMBER;


BEGIN

    --  Standard begin of API savepoint
    SAVEPOINT load_project_asset_pub;


    --  Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    ) THEN

    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --  Initialize the message table if requested.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --  Set API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;


    -- assign a value to the global counter for this table
    G_assets_tbl_count	:= G_assets_tbl_count + 1;

    -- assign incoming parameters to the global table fields
    G_assets_in_tbl(G_assets_tbl_count).pm_asset_reference      := p_pm_asset_reference;
    G_assets_in_tbl(G_assets_tbl_count).pa_asset_name           := p_pa_asset_name;
    G_assets_in_tbl(G_assets_tbl_count).asset_number            := p_asset_number;
    G_assets_in_tbl(G_assets_tbl_count).asset_description       := p_asset_description;
    G_assets_in_tbl(G_assets_tbl_count).project_asset_type      := p_project_asset_type;
    G_assets_in_tbl(G_assets_tbl_count).location_id	            := p_location_id;
    G_assets_in_tbl(G_assets_tbl_count).assigned_to_person_id   := p_assigned_to_person_id;
    G_assets_in_tbl(G_assets_tbl_count).date_placed_in_service  := p_date_placed_in_service;
    G_assets_in_tbl(G_assets_tbl_count).asset_category_id       := p_asset_category_id;
    G_assets_in_tbl(G_assets_tbl_count).book_type_code          := p_book_type_code;
    G_assets_in_tbl(G_assets_tbl_count).asset_units             := p_asset_units;
    G_assets_in_tbl(G_assets_tbl_count).estimated_asset_units   := p_estimated_asset_units;
    G_assets_in_tbl(G_assets_tbl_count).estimated_cost          := p_estimated_cost;
    G_assets_in_tbl(G_assets_tbl_count).depreciate_flag         := p_depreciate_flag;
    G_assets_in_tbl(G_assets_tbl_count).depreciation_expense_ccid := p_depreciation_expense_ccid;
    G_assets_in_tbl(G_assets_tbl_count).amortize_flag           := p_amortize_flag;
    G_assets_in_tbl(G_assets_tbl_count).estimated_in_service_date := p_estimated_in_service_date;
    G_assets_in_tbl(G_assets_tbl_count).asset_key_ccid          := p_asset_key_ccid;
    G_assets_in_tbl(G_assets_tbl_count).attribute_category      := p_attribute_category;
    G_assets_in_tbl(G_assets_tbl_count).attribute1              := p_attribute1;
    G_assets_in_tbl(G_assets_tbl_count).attribute2              := p_attribute2;
    G_assets_in_tbl(G_assets_tbl_count).attribute3              := p_attribute3;
    G_assets_in_tbl(G_assets_tbl_count).attribute4              := p_attribute4;
    G_assets_in_tbl(G_assets_tbl_count).attribute5              := p_attribute5;
    G_assets_in_tbl(G_assets_tbl_count).attribute6              := p_attribute6;
    G_assets_in_tbl(G_assets_tbl_count).attribute7              := p_attribute7;
    G_assets_in_tbl(G_assets_tbl_count).attribute8              := p_attribute8;
    G_assets_in_tbl(G_assets_tbl_count).attribute9              := p_attribute9;
    G_assets_in_tbl(G_assets_tbl_count).attribute10             := p_attribute10;
    G_assets_in_tbl(G_assets_tbl_count).attribute11             := p_attribute11;
    G_assets_in_tbl(G_assets_tbl_count).attribute12             := p_attribute12;
    G_assets_in_tbl(G_assets_tbl_count).attribute13             := p_attribute13;
    G_assets_in_tbl(G_assets_tbl_count).attribute14             := p_attribute14;
    G_assets_in_tbl(G_assets_tbl_count).attribute15             := p_attribute15;
    G_assets_in_tbl(G_assets_tbl_count).parent_asset_id	        := p_parent_asset_id;
    G_assets_in_tbl(G_assets_tbl_count).manufacturer_name       := p_manufacturer_name;
    G_assets_in_tbl(G_assets_tbl_count).model_number            := p_model_number;
    G_assets_in_tbl(G_assets_tbl_count).serial_number           := p_serial_number;
    G_assets_in_tbl(G_assets_tbl_count).tag_number              := p_tag_number;
    G_assets_in_tbl(G_assets_tbl_count).ret_target_asset_id     := p_ret_target_asset_id;



EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO load_project_asset_pub;
        p_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
        ROLLBACK TO load_project_asset_pub;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


	WHEN OTHERS THEN
        ROLLBACK TO load_project_asset_pub;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
    	END IF;

END load_project_asset;




--------------------------------------------------------------------------------
--Name:               execute_add_project_asset
--Type:               Procedure
--Description:        This procedure can be used to create or update project
--                    assets for a project using global PL/SQL tables.  Asset
--                    assignments for a project can also be created here.
--
--Called subprograms:
--                    add_project_asset
--                    update_project_asset
--                    add_asset_assignment
--
--History:
--    	01-MAR-2003   J. Pultorak    Created

--

PROCEDURE execute_add_project_asset
( p_api_version_number		IN	NUMBER
 ,p_commit				    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status			OUT NOCOPY	VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_assets_in               IN  asset_in_tbl_type
 ,p_assets_out              OUT NOCOPY asset_out_tbl_type
 ,p_asset_assignments_in    IN  asset_assignment_in_tbl_type
 ,p_asset_assignments_out   OUT NOCOPY asset_assignment_out_tbl_type )

IS



   --Used to get the project number for AMG messages
   CURSOR l_amg_project_csr(x_project_id   NUMBER) IS
   SELECT  segment1
   FROM    pa_projects p
   WHERE   p.project_id = x_project_id;

   l_amg_project_number             pa_projects_all.segment1%TYPE;


   --Used to get the asset number for output parameter
   CURSOR l_amg_asset_csr(x_project_asset_id   NUMBER,
                          x_project_id         NUMBER) IS
   SELECT  asset_name
   FROM    pa_project_assets p
   WHERE   p.project_asset_id = x_project_asset_id
   AND     p.project_id = x_project_id;

   l_amg_pa_asset_name              pa_project_assets_all.asset_name%TYPE;


   --Used to get the Task number for output parameter
   CURSOR l_amg_task_csr (l_project_id NUMBER ,l_task_id NUMBER) IS
   SELECT  task_number
   FROM    pa_tasks
   WHERE   project_id = l_project_id
   AND     task_id    = l_task_id;

   l_amg_pa_task_number              pa_tasks.task_number%TYPE;


   l_api_name				CONSTANT	VARCHAR2(30) 		:= 'execute_add_project_asset';

   i						NUMBER;
   l_return_status			VARCHAR2(1);
   l_err_stage				VARCHAR2(120);

   l_project_asset_id       NUMBER;
   l_project_id             NUMBER;
   l_task_id                NUMBER;
   l_pm_asset_reference     PA_PROJECT_ASSETS_ALL.pm_asset_reference%TYPE;
   l_project_number         PA_PROJECTS_ALL.segment1%TYPE;
   l_msg_data               VARCHAR2(2000);
   v_assignment_count       NUMBER := 0;


BEGIN

    --  Standard begin of API savepoint
    SAVEPOINT execute_add_project_asset_pub;


    --  Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	) THEN

    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --  Initialize the message table if requested.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
    END IF;


    --  Set API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Get the Project ID
    PA_PROJECT_PVT.Convert_pm_projref_to_id
        (p_pm_project_reference =>      p_pm_project_reference
        ,p_pa_project_id        =>      p_pa_project_id
        ,p_out_project_id       =>      l_project_id
        ,p_return_status        =>      l_return_status
        );


    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;


    -- Get project number for AMG messages
    OPEN l_amg_project_csr( l_project_id );
    FETCH l_amg_project_csr INTO l_amg_project_number;
    CLOSE l_amg_project_csr;



    --Process Project Assets first, then Asset Assignments

    --Loop through all assets in the IN table
    i := p_assets_in.FIRST;

    WHILE i IS NOT NULL LOOP

        --Initialize local variables
        l_project_asset_id := NULL;


        --Format output record
        p_assets_out(i).pm_asset_reference  := p_assets_in(i).pm_asset_reference;
        p_assets_out(i).pa_project_asset_id := p_assets_in(i).pa_project_asset_id;
        p_assets_out(i).return_status       := FND_API.G_RET_STS_SUCCESS;


        --Determine if the Project Asset already exists, and if so perform Update,
        --otherwise Add Project Asset

        --If the project asset id is not specified, determine
        --the project asset id based on the pm_asset_reference

        IF p_assets_in(i).pa_project_asset_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
            OR p_assets_in(i).pa_project_asset_id IS NULL THEN

            --Get project asset id based on PM Asset Reference
            l_project_asset_id := fetch_project_asset_id
                                  (p_pa_project_id        => l_project_id,
                                   p_pm_asset_reference   => p_assets_in(i).pm_asset_reference);

        ELSE
            l_project_asset_id := p_assets_in(i).pa_project_asset_id;
        END IF;


        --Get asset name for AMG messages and validate that specified project_asset_id is valid for project
        IF l_project_asset_id IS NULL THEN
            l_amg_pa_asset_name := NVL(p_assets_in(i).pa_asset_name,p_assets_in(i).pm_asset_reference);
        ELSE

            OPEN l_amg_asset_csr(l_project_asset_id, l_project_id);
            FETCH l_amg_asset_csr into l_amg_pa_asset_name;
            IF l_amg_asset_csr%NOTFOUND THEN

                CLOSE l_amg_asset_csr;
                --Project Asset ID specified is not valid for Project
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_PROJ_ASSET_ID_INVALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_project_number
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                END IF;

                p_assets_out(i).return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE l_amg_asset_csr;
        END IF;


        IF l_project_asset_id IS NULL THEN

            add_project_asset
                (p_api_version_number		=>   p_api_version_number
                ,p_commit					=>   p_commit
                ,p_init_msg_list		    =>   p_init_msg_list
                ,p_msg_count				=>   p_msg_count
                ,p_msg_data				    =>   l_msg_data
                ,p_return_status		    =>   l_return_status
                ,p_pm_product_code			=>   p_pm_product_code
                ,p_pm_project_reference	    =>   p_pm_project_reference
                ,p_pa_project_id			=>   l_project_id
                ,p_pm_asset_reference		=>   p_assets_in(i).pm_asset_reference
                ,p_pa_asset_name			=>   p_assets_in(i).pa_asset_name
                ,p_asset_number			    =>   p_assets_in(i).asset_number
                ,p_asset_description		=>   p_assets_in(i).asset_description
                ,p_project_asset_type		=>   p_assets_in(i).project_asset_type
                ,p_location_id				=>   p_assets_in(i).location_id
                ,p_assigned_to_person_id	=>   p_assets_in(i).assigned_to_person_id
                ,p_date_placed_in_service	=>   p_assets_in(i).date_placed_in_service
                ,p_asset_category_id		=>   p_assets_in(i).asset_category_id
                ,p_book_type_code			=>   p_assets_in(i).book_type_code
                ,p_asset_units				=>   p_assets_in(i).asset_units
                ,p_estimated_asset_units	=>   p_assets_in(i).estimated_asset_units
                ,p_estimated_cost			=>   p_assets_in(i).estimated_cost
                ,p_depreciate_flag			=>   p_assets_in(i).depreciate_flag
                ,p_depreciation_expense_ccid =>  p_assets_in(i).depreciation_expense_ccid
                ,p_amortize_flag			=>   p_assets_in(i).amortize_flag
                ,p_estimated_in_service_date =>  p_assets_in(i).estimated_in_service_date
                ,p_asset_key_ccid			=>   p_assets_in(i).asset_key_ccid
                ,p_attribute_category		=>   p_assets_in(i).attribute_category
                ,p_attribute1				=>   p_assets_in(i).attribute1
                ,p_attribute2				=>   p_assets_in(i).attribute2
                ,p_attribute3				=>   p_assets_in(i).attribute3
                ,p_attribute4				=>   p_assets_in(i).attribute4
                ,p_attribute5				=>   p_assets_in(i).attribute5
                ,p_attribute6				=>   p_assets_in(i).attribute6
                ,p_attribute7				=>   p_assets_in(i).attribute7
                ,p_attribute8				=>   p_assets_in(i).attribute8
                ,p_attribute9				=>   p_assets_in(i).attribute9
                ,p_attribute10				=>   p_assets_in(i).attribute10
                ,p_attribute11				=>   p_assets_in(i).attribute11
                ,p_attribute12				=>   p_assets_in(i).attribute12
                ,p_attribute13				=>   p_assets_in(i).attribute13
                ,p_attribute14				=>   p_assets_in(i).attribute14
                ,p_attribute15				=>   p_assets_in(i).attribute15
                ,p_parent_asset_id		    =>   p_assets_in(i).parent_asset_id
                ,p_manufacturer_name		=>   p_assets_in(i).manufacturer_name
                ,p_model_number			    =>   p_assets_in(i).model_number
                ,p_serial_number			=>   p_assets_in(i).serial_number
                ,p_tag_number				=>   p_assets_in(i).tag_number
                ,p_ret_target_asset_id		=>   p_assets_in(i).ret_target_asset_id
                ,p_pa_project_id_out		=>   l_project_id
                ,p_pa_project_number_out	=>   l_project_number
                ,p_pa_project_asset_id_out	=>   l_project_asset_id
                ,p_pm_asset_reference_out   =>   l_pm_asset_reference );


   	        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           	ELSIF l_return_status = FND_API.G_RET_STS_ERROR	THEN
        		p_assets_out(i).return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
           	ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                p_assets_out(i).pa_project_asset_id := l_project_asset_id;
                p_assets_out(i).pm_asset_reference := l_pm_asset_reference;
           	END IF;
        ELSE

            update_project_asset
                (p_api_version_number		=>   p_api_version_number
                ,p_commit					=>   p_commit
                ,p_init_msg_list		    =>   p_init_msg_list
                ,p_msg_count				=>   p_msg_count
                ,p_msg_data				    =>   l_msg_data
                ,p_return_status		    =>   l_return_status
                ,p_pm_product_code			=>   p_pm_product_code
                ,p_pm_project_reference	    =>   p_pm_project_reference
                ,p_pa_project_id			=>   l_project_id
                ,p_pm_asset_reference		=>   p_assets_in(i).pm_asset_reference
                ,p_pa_project_asset_id      =>   p_assets_in(i).pa_project_asset_id
                ,p_pa_asset_name			=>   p_assets_in(i).pa_asset_name
                ,p_asset_number			    =>   p_assets_in(i).asset_number
                ,p_asset_description		=>   p_assets_in(i).asset_description
                ,p_project_asset_type		=>   p_assets_in(i).project_asset_type
                ,p_location_id				=>   p_assets_in(i).location_id
                ,p_assigned_to_person_id	=>   p_assets_in(i).assigned_to_person_id
                ,p_date_placed_in_service	=>   p_assets_in(i).date_placed_in_service
                ,p_asset_category_id		=>   p_assets_in(i).asset_category_id
                ,p_book_type_code			=>   p_assets_in(i).book_type_code
                ,p_asset_units				=>   p_assets_in(i).asset_units
                ,p_estimated_asset_units	=>   p_assets_in(i).estimated_asset_units
                ,p_estimated_cost			=>   p_assets_in(i).estimated_cost
                ,p_depreciate_flag			=>   p_assets_in(i).depreciate_flag
                ,p_depreciation_expense_ccid =>  p_assets_in(i).depreciation_expense_ccid
                ,p_amortize_flag			=>   p_assets_in(i).amortize_flag
                ,p_estimated_in_service_date =>  p_assets_in(i).estimated_in_service_date
                ,p_asset_key_ccid			=>   p_assets_in(i).asset_key_ccid
                ,p_attribute_category		=>   p_assets_in(i).attribute_category
                ,p_attribute1				=>   p_assets_in(i).attribute1
                ,p_attribute2				=>   p_assets_in(i).attribute2
                ,p_attribute3				=>   p_assets_in(i).attribute3
                ,p_attribute4				=>   p_assets_in(i).attribute4
                ,p_attribute5				=>   p_assets_in(i).attribute5
                ,p_attribute6				=>   p_assets_in(i).attribute6
                ,p_attribute7				=>   p_assets_in(i).attribute7
                ,p_attribute8				=>   p_assets_in(i).attribute8
                ,p_attribute9				=>   p_assets_in(i).attribute9
                ,p_attribute10				=>   p_assets_in(i).attribute10
                ,p_attribute11				=>   p_assets_in(i).attribute11
                ,p_attribute12				=>   p_assets_in(i).attribute12
                ,p_attribute13				=>   p_assets_in(i).attribute13
                ,p_attribute14				=>   p_assets_in(i).attribute14
                ,p_attribute15				=>   p_assets_in(i).attribute15
                ,p_parent_asset_id		    =>   p_assets_in(i).parent_asset_id
                ,p_manufacturer_name		=>   p_assets_in(i).manufacturer_name
                ,p_model_number			    =>   p_assets_in(i).model_number
                ,p_serial_number			=>   p_assets_in(i).serial_number
                ,p_tag_number				=>   p_assets_in(i).tag_number
                ,p_ret_target_asset_id		=>   p_assets_in(i).ret_target_asset_id
                ,p_pa_project_id_out		=>   l_project_id
                ,p_pa_project_number_out	=>   l_project_number
                ,p_pa_project_asset_id_out	=>   l_project_asset_id
                ,p_pm_asset_reference_out   =>   l_pm_asset_reference );


            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           	ELSIF l_return_status = FND_API.G_RET_STS_ERROR	THEN
        		p_assets_out(i).return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
           	ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                p_assets_out(i).pa_project_asset_id := l_project_asset_id;
                p_assets_out(i).pm_asset_reference := l_pm_asset_reference;
           	END IF;
        END IF;

	   i := p_assets_in.NEXT(i);

    END LOOP; --Project Assets



    --Now process Asset Assignments

    --Loop through all asset assignments in the IN table
    i := p_asset_assignments_in.FIRST;

    WHILE i IS NOT NULL LOOP

        --Initialize local variables
        l_task_id := NULL;
        l_project_asset_id := NULL;


        --Format output record
        p_asset_assignments_out(i).pa_task_id          := p_asset_assignments_in(i).pa_task_id;
        p_asset_assignments_out(i).pm_task_reference   := p_asset_assignments_in(i).pm_task_reference;
        p_asset_assignments_out(i).pa_project_asset_id := p_asset_assignments_in(i).pa_project_asset_id;
        p_asset_assignments_out(i).pm_asset_reference  := p_asset_assignments_in(i).pm_asset_reference;
        p_asset_assignments_out(i).pa_task_number      := NULL;
        p_asset_assignments_out(i).pa_asset_name       := NULL;
        p_asset_assignments_out(i).return_status       := FND_API.G_RET_STS_SUCCESS;


        --If the task id is not specified, determine the task id based on the pm_task_reference
        IF p_asset_assignments_in(i).pa_task_id = 0 THEN
            --Assignment is Project-Level
            l_task_id := 0;
            l_amg_pa_task_number := NULL;

        ELSIF p_asset_assignments_in(i).pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
            OR p_asset_assignments_in(i).pa_task_id IS NULL THEN

            --Determine the Task ID based on the pm_task_reference info (or pa_task_id, if specified)
            Pa_project_pvt.Convert_pm_taskref_to_id
                ( p_pa_project_id       => l_project_id,
                  p_pa_task_id          => p_asset_assignments_in(i).pa_task_id,
                  p_pm_task_reference   => p_asset_assignments_in(i).pm_task_reference,
                  p_out_task_id         => l_task_id,
                  p_return_status       => l_return_status );


            IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE  FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            l_task_id := p_asset_assignments_in(i).pa_task_id;
        END IF;


        IF l_task_id <> 0 THEN

            --Get Task Number for Output Parameter
            OPEN l_amg_task_csr( l_project_id, l_task_id );
            FETCH l_amg_task_csr INTO l_amg_pa_task_number;
            IF l_amg_task_csr%NOTFOUND THEN
                --Task is not valid for Project specified
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    pa_interface_utils_pub.map_new_amg_msg
                        (p_old_message_code => 'PA_TASK_ID_INVALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_project_number
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
		        END IF;


                p_asset_assignments_out(i).return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE l_amg_task_csr;

        END IF;


        --If the project asset id is not specified, determine
        --the project asset id based on the pm_asset_reference
        IF p_asset_assignments_in(i).pa_project_asset_id = 0 THEN
            --Assignment is Common
            l_project_asset_id := 0;
            l_amg_pa_asset_name := NULL;

        ELSIF p_asset_assignments_in(i).pa_project_asset_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
            OR p_asset_assignments_in(i).pa_project_asset_id IS NULL THEN

            --Get project asset id based on PM Asset Reference
            l_project_asset_id := fetch_project_asset_id
                                  (p_pa_project_id        => l_project_id,
                                   p_pm_asset_reference   => p_asset_assignments_in(i).pm_asset_reference);

        ELSE
            l_project_asset_id := p_asset_assignments_in(i).pa_project_asset_id;
        END IF;


        IF l_project_asset_id <> 0 THEN  --Assignment is to a specific Asset

            --Get asset name for AMG messages and validate that specified project_asset_id is valid for project
            OPEN l_amg_asset_csr(l_project_asset_id, l_project_id);
            FETCH l_amg_asset_csr into l_amg_pa_asset_name;
            IF l_amg_asset_csr%NOTFOUND THEN

                CLOSE l_amg_asset_csr;
                --Project Asset ID specified is not valid for Project
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_PROJ_ASSET_ID_INVALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_project_number
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                END IF;

                p_asset_assignments_out(i).return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE l_amg_asset_csr;

        END IF;


        --Check if Assignment already exists
        SELECT  COUNT(*)
        INTO    v_assignment_count
        FROM    pa_project_asset_assignments
        WHERE   project_id = l_project_id
        AND     task_id = l_task_id
        AND     project_asset_id = l_project_asset_id;


        --Add Assignment if it does not already exist
        IF v_assignment_count = 0 THEN

            add_asset_assignment
                (p_api_version_number		=>   p_api_version_number
                ,p_commit					=>   p_commit
                ,p_init_msg_list		    =>   p_init_msg_list
                ,p_msg_count				=>   p_msg_count
                ,p_msg_data				    =>   l_msg_data
                ,p_return_status		    =>   l_return_status
                ,p_pm_product_code			=>   p_pm_product_code
                ,p_pm_project_reference	    =>   p_pm_project_reference
                ,p_pa_project_id			=>   l_project_id
                ,p_pm_task_reference	    =>   p_asset_assignments_in(i).pm_task_reference
                ,p_pa_task_id			    =>   l_task_id
                ,p_pm_asset_reference		=>   p_asset_assignments_in(i).pm_asset_reference
                ,p_pa_project_asset_id		=>   l_project_asset_id
                ,p_attribute_category		=>   p_asset_assignments_in(i).attribute_category
                ,p_attribute1				=>   p_asset_assignments_in(i).attribute1
                ,p_attribute2				=>   p_asset_assignments_in(i).attribute2
                ,p_attribute3				=>   p_asset_assignments_in(i).attribute3
                ,p_attribute4				=>   p_asset_assignments_in(i).attribute4
                ,p_attribute5				=>   p_asset_assignments_in(i).attribute5
                ,p_attribute6				=>   p_asset_assignments_in(i).attribute6
                ,p_attribute7				=>   p_asset_assignments_in(i).attribute7
                ,p_attribute8				=>   p_asset_assignments_in(i).attribute8
                ,p_attribute9				=>   p_asset_assignments_in(i).attribute9
                ,p_attribute10				=>   p_asset_assignments_in(i).attribute10
                ,p_attribute11				=>   p_asset_assignments_in(i).attribute11
                ,p_attribute12				=>   p_asset_assignments_in(i).attribute12
                ,p_attribute13				=>   p_asset_assignments_in(i).attribute13
                ,p_attribute14				=>   p_asset_assignments_in(i).attribute14
                ,p_attribute15				=>   p_asset_assignments_in(i).attribute15
                ,p_pa_task_id_out		    =>   l_task_id
                ,p_pa_project_asset_id_out	=>   l_project_asset_id);


            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           	ELSIF l_return_status = FND_API.G_RET_STS_ERROR	THEN
        		p_asset_assignments_out(i).return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
           	ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                p_asset_assignments_out(i).pa_task_number      := l_amg_pa_task_number;
                p_asset_assignments_out(i).pa_asset_name       := l_amg_pa_asset_name;
           	END IF;

        ELSE
            --Assignment already exists, do nothing
            p_asset_assignments_out(i).pa_task_id          := l_task_id;
            p_asset_assignments_out(i).pa_task_number      := l_amg_pa_task_number;
            p_asset_assignments_out(i).pa_project_asset_id := l_project_asset_id;
            p_asset_assignments_out(i).pa_asset_name       := l_amg_pa_asset_name;
        END IF;

	    i := p_asset_assignments_in.NEXT(i);

    END LOOP; --Asset Assignments


	IF FND_API.to_boolean( p_commit ) THEN
		COMMIT;
	END IF;


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
    	ROLLBACK TO execute_add_project_asset_pub;
        p_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
    	ROLLBACK TO execute_add_project_asset_pub;
    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    	FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN OTHERS THEN
    	ROLLBACK TO execute_add_project_asset_pub;
    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	       	FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
	    END IF;

	    FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

END execute_add_project_asset;



PROCEDURE delete_project_asset
( p_api_version_number		IN	NUMBER
 ,p_commit					IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status		    OUT	 NOCOPY VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) IS


    --Used to get the project number for AMG messages
    CURSOR l_amg_project_csr(x_project_id   NUMBER) IS
    SELECT  segment1
    FROM    pa_projects p
    WHERE   p.project_id = x_project_id;

    l_amg_project_number             pa_projects_all.segment1%TYPE;


    --Used to get the asset number for AMG messages
    CURSOR l_amg_asset_csr(x_project_asset_id   NUMBER) IS
    SELECT  asset_name
    FROM    pa_project_assets p
    WHERE   p.project_asset_id = x_project_asset_id;

    l_amg_pa_asset_name              pa_project_assets_all.asset_name%TYPE;


    --Used to determine if the project is CAPITAL
    CURSOR capital_project_cur(x_project_id   NUMBER) IS
    SELECT  'Project is CAPITAL'
    FROM    pa_projects p,
            pa_project_types t
    WHERE   p.project_id = x_project_id
    AND     p.project_type = t.project_type
    AND     t.project_type_class_code = 'CAPITAL';

    capital_project_rec      capital_project_cur%ROWTYPE;


    --Used to determine if the new assignment already exists
    CURSOR lock_assignment_cur (x_project_id        NUMBER,
                                x_project_asset_id  NUMBER) IS
    SELECT  'x'
    FROM    pa_project_asset_assignments
    WHERE   project_id = x_project_id
    AND     project_asset_id = x_project_asset_id
    FOR UPDATE NOWAIT;


    --Used to determine if the new assignment already exists
    CURSOR lock_asset_cur (x_project_id        NUMBER,
                           x_project_asset_id  NUMBER) IS
    SELECT  'x'
    FROM    pa_project_assets
    WHERE   project_id = x_project_id
    AND     project_asset_id = x_project_asset_id
    FOR UPDATE NOWAIT;


    l_api_name			   CONSTANT	 VARCHAR2(30) 		:= 'delete_project_asset';
    l_return_status                  VARCHAR2(1);
    l_function_allowed				 VARCHAR2(1);
    l_resp_id					     NUMBER := 0;
    l_user_id		                 NUMBER := 0;
    l_module_name                    VARCHAR2(80);
    l_msg_count					     NUMBER ;
    l_msg_data					     VARCHAR2(2000);
    l_task_id                        NUMBER;
    l_project_asset_id               NUMBER;
    l_project_id                     NUMBER;
    v_asset_can_be_deleted           NUMBER := 0;

 BEGIN

    --  Standard begin of API savepoint
    SAVEPOINT delete_project_asset_pub;


    --  Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --	Initialize the message table if requested.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --  Set API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;


    --  pm_product_code is mandatory
    IF p_pm_product_code IS NULL OR p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
	    END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --Initialize variables
    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_module_name := 'PA_PM_DELETE_PROJECT_ASSET';



    --Get Project ID from Project Reference
    PA_PROJECT_PVT.Convert_pm_projref_to_id
        (        p_pm_project_reference =>      p_pm_project_reference
                 ,  p_pa_project_id     =>      p_pa_project_id
                 ,  p_out_project_id    =>      l_project_id
                 ,  p_return_status     =>      l_return_status
        );

    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;


    -- Get project number for AMG messages
    OPEN l_amg_project_csr( l_project_id );
    FETCH l_amg_project_csr INTO l_amg_project_number;
    CLOSE l_amg_project_csr;


    --Validate that the project is CAPITAL project type class
    OPEN capital_project_cur(l_project_id);
    FETCH capital_project_cur INTO capital_project_rec;
	IF capital_project_cur%NOTFOUND THEN

        CLOSE capital_project_cur;
        -- The project must be CAPITAL. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PR_NOT_CAPITAL'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE capital_project_cur;



    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to update the project
    -- need to call the pa_security package

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    -- Function security procedure check whether user have the
    -- privilege to delete project asset or not

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;

    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_DELETE_PROJECT_ASSET',
       p_msg_count	        => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
	       p_return_status := FND_API.G_RET_STS_ERROR;
	       RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Now verify whether project security allows the user to update the project
    IF pa_security.allow_query (x_project_id => l_project_id ) = 'N' THEN

        -- The user does not have query privileges on this project
        -- Hence, cannot update the project.Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
    ELSE
        -- If the user has query privileges, then check whether
        -- update privileges are also available
        IF pa_security.allow_update (x_project_id => l_project_id ) = 'N' THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error

            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'Y'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

	        p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;



    --Determine the Project Asset ID
    IF ((p_pa_project_asset_id IS NULL OR p_pa_project_asset_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
        AND (p_pm_asset_reference IS NULL OR p_pm_asset_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) THEN

        --Cannot determine asset to delete
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            pa_interface_utils_pub.map_new_amg_msg
                (p_old_message_code => 'PA_DELETE_ASSET_FAILED_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    ELSE
        --Get project asset id based on PM Asset Reference
        PA_PROJECT_ASSETS_PUB.convert_pm_assetref_to_id (
            p_pa_project_id        => l_project_id,
            p_pa_project_asset_id  => p_pa_project_asset_id,
            p_pm_asset_reference   => p_pm_asset_reference,
            p_out_project_asset_id => l_project_asset_id,
            p_return_status        => l_return_status );

        IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

    END IF;


    --Get the asset name for AMG messages
    OPEN l_amg_asset_csr(l_project_asset_id);
    FETCH l_amg_asset_csr into l_amg_pa_asset_name;
    CLOSE l_amg_asset_csr;


    --Determine if the Project Asset can be deleted.  A value of 1 means it can be deleted,
    --a value of 0 means that asset lines exist.

    v_asset_can_be_deleted := PA_ASSET_UTILS.CHECK_ASSET_REFERENCES(l_project_asset_id);


    IF v_asset_can_be_deleted = 0 THEN

        --Cannot delete asset, since asset lines exist
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            pa_interface_utils_pub.map_new_amg_msg
                (p_old_message_code => 'PA_ASSET_CANNOT_DELETE_AS'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'ASSET'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_pa_asset_name
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    ELSE --Delete asset and assignments

        --Delete all associated asset assignments prior to deleting the project asset
        OPEN lock_assignment_cur(l_project_id, l_project_asset_id);
        CLOSE lock_assignment_cur;


        DELETE  pa_project_asset_assignments
        WHERE   project_id = l_project_id
        AND     project_asset_id = l_project_asset_id;


        --Delete the project asset
        OPEN lock_asset_cur(l_project_id, l_project_asset_id);
        CLOSE lock_asset_cur;


        DELETE  pa_project_assets
        WHERE   project_id = l_project_id
        AND     project_asset_id = l_project_asset_id;

    END IF;


    --Perform commit if indicated
    IF FND_API.to_boolean( p_commit ) THEN
	    COMMIT;
    END IF;



 EXCEPTION
  	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO delete_project_asset_pub;

		p_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
	   ROLLBACK TO delete_project_asset_pub;

	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

 	WHEN OTHERS	THEN
	   ROLLBACK TO delete_project_asset_pub;

	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		  FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

	   END IF;

	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

 END delete_project_asset;



PROCEDURE delete_asset_assignment
( p_api_version_number		IN	NUMBER
 ,p_commit					IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status		    OUT	 NOCOPY VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference	    IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id			    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) IS


    --Used to get the project number for AMG messages
    CURSOR l_amg_project_csr(x_project_id   NUMBER) IS
    SELECT  segment1
    FROM    pa_projects p
    WHERE   p.project_id = x_project_id;

    l_amg_project_number             pa_projects_all.segment1%TYPE;


    --Used to determine if the project is CAPITAL
    CURSOR capital_project_cur(x_project_id   NUMBER) IS
    SELECT  'Project is CAPITAL'
    FROM    pa_projects p,
            pa_project_types t
    WHERE   p.project_id = x_project_id
    AND     p.project_type = t.project_type
    AND     t.project_type_class_code = 'CAPITAL';

    capital_project_rec      capital_project_cur%ROWTYPE;


    --Used to determine if the new assignment already exists
    CURSOR existing_assignment_cur (x_project_id        NUMBER,
                                    x_task_id           NUMBER,
                                    x_project_asset_id  NUMBER) IS
    SELECT  'Assignment Already Exists'
    FROM    pa_project_asset_assignments
    WHERE   project_id = x_project_id
    AND     task_id = x_task_id
    AND     project_asset_id = x_project_asset_id;

    existing_assignment_rec      existing_assignment_cur%ROWTYPE;


    --Used to determine if the new assignment already exists
    CURSOR lock_assignment_cur (x_project_id        NUMBER,
                                x_task_id           NUMBER,
                                x_project_asset_id  NUMBER) IS
    SELECT  'x'
    FROM    pa_project_asset_assignments
    WHERE   project_id = x_project_id
    AND     task_id = x_task_id
    AND     project_asset_id = x_project_asset_id
    FOR UPDATE NOWAIT;


    l_api_name			   CONSTANT	 VARCHAR2(30) 		:= 'delete_asset_assignment';
    l_return_status                  VARCHAR2(1);
    l_function_allowed				 VARCHAR2(1);
    l_resp_id					     NUMBER := 0;
    l_user_id		                 NUMBER := 0;
    l_module_name                    VARCHAR2(80);
    l_msg_count					     NUMBER ;
    l_msg_data					     VARCHAR2(2000);
    l_task_id                        NUMBER;
    l_project_asset_id               NUMBER;
    l_project_id                     NUMBER;


 BEGIN

    --  Standard begin of API savepoint
    SAVEPOINT delete_asset_assignment_pub;


    --  Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --	Initialize the message table if requested.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --  Set API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;


    --  pm_product_code is mandatory
    IF p_pm_product_code IS NULL OR p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
	    END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --Initialize variables
    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_module_name := 'PA_PM_DELETE_ASSET_ASSIGNMENT';



    --Get Project ID from Project Reference
    PA_PROJECT_PVT.Convert_pm_projref_to_id
        (        p_pm_project_reference =>      p_pm_project_reference
                 ,  p_pa_project_id     =>      p_pa_project_id
                 ,  p_out_project_id    =>      l_project_id
                 ,  p_return_status     =>      l_return_status
        );

    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;


    -- Get project number for AMG messages
    OPEN l_amg_project_csr( l_project_id );
    FETCH l_amg_project_csr INTO l_amg_project_number;
    CLOSE l_amg_project_csr;


    --Validate that the project is CAPITAL project type class
    OPEN capital_project_cur(l_project_id);
    FETCH capital_project_cur INTO capital_project_rec;
	IF capital_project_cur%NOTFOUND THEN

        CLOSE capital_project_cur;
        -- The project must be CAPITAL. Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PR_NOT_CAPITAL'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE capital_project_cur;



    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to update the project
    -- need to call the pa_security package

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    -- Function security procedure check whether user have the
    -- privilege to delete asset assignment or not

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;

    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_DELETE_ASSET_ASSIGNMENT',
       p_msg_count	        => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
	       p_return_status := FND_API.G_RET_STS_ERROR;
	       RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Now verify whether project security allows the user to update the project
    IF pa_security.allow_query (x_project_id => l_project_id ) = 'N' THEN

        -- The user does not have query privileges on this project
        -- Hence, cannot update the project.Raise error
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_ERROR;
    ELSE
        -- If the user has query privileges, then check whether
        -- update privileges are also available
        IF pa_security.allow_update (x_project_id => l_project_id ) = 'N' THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error

            pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'Y'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');

	        p_return_status := FND_API.G_RET_STS_ERROR;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;


    --Determine the Task ID for the Assignment
    IF p_pa_task_id = 0 OR
        ((p_pa_task_id IS NULL OR p_pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
        AND (p_pm_task_reference IS NULL OR p_pm_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) THEN

        l_task_id := 0;

    ELSE
        --Get task id, if both task references are not NULL and p_pa_task_id <> 0
        Pa_project_pvt.Convert_pm_taskref_to_id (
            p_pa_project_id       => l_project_id,
            p_pa_task_id          => p_pa_task_id,
            p_pm_task_reference   => p_pm_task_reference,
            p_out_task_id         => l_task_id,
            p_return_status       => l_return_status );

        IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

    END IF;


    --Determine the Project Asset ID for the Assignment
    IF p_pa_project_asset_id = 0 OR
        ((p_pa_project_asset_id IS NULL OR p_pa_project_asset_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
        AND (p_pm_asset_reference IS NULL OR p_pm_asset_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) THEN

        l_project_asset_id := 0;

    ELSE
        --Get project asset id based on PM Asset Reference
        PA_PROJECT_ASSETS_PUB.convert_pm_assetref_to_id (
            p_pa_project_id        => l_project_id,
            p_pa_project_asset_id  => p_pa_project_asset_id,
            p_pm_asset_reference   => p_pm_asset_reference,
            p_out_project_asset_id => l_project_asset_id,
            p_return_status        => l_return_status );

        IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

    END IF;



    --Before deleting, check if an assignment exists which matches the current assignment exactly
    OPEN existing_assignment_cur(l_project_id, l_task_id, l_project_asset_id);
    FETCH existing_assignment_cur INTO existing_assignment_rec;
    IF existing_assignment_cur%NOTFOUND THEN

        CLOSE existing_assignment_cur;
        --No matching assignment currently exists
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            pa_interface_utils_pub.map_new_amg_msg
                (p_old_message_code => 'PA_DELETE_AS_ASSIGN_FAILED'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'PROJ'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF; --No matching assignment currently exists
    CLOSE existing_assignment_cur;


    OPEN lock_assignment_cur(l_project_id, l_task_id, l_project_asset_id);
    CLOSE lock_assignment_cur;


    DELETE  pa_project_asset_assignments
    WHERE   project_id = l_project_id
    AND     task_id = l_task_id
    AND     project_asset_id = l_project_asset_id;


    --Perform commit if indicated
    IF FND_API.to_boolean( p_commit ) THEN
	    COMMIT;
    END IF;



 EXCEPTION
  	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO delete_asset_assignment_pub;

		p_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
	   ROLLBACK TO delete_asset_assignment_pub;

	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

 	WHEN OTHERS	THEN
	   ROLLBACK TO delete_asset_assignment_pub;

	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		  FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

	   END IF;

	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

 END delete_asset_assignment;



--JPULTORAK Project Asset Creation

--------------------------------------------------------------------------------

END PA_PROJECT_ASSETS_PUB;

/
