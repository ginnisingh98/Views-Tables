--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_TYPES_PUB" as
/* $Header: asxintyb.pls 120.1 2005/06/14 01:30:21 appldev  $ */
--
--***************************************************************************
-- Package Name : AS_INTEREST_TYPES_PUB
--
-- Purpose :
-- 	Public API to Create and Update Interest Types in the Oracle Sales
--     Online.
--
-- History:
--
--   09/12/2002    Rajan T          Created
--***************************************************************************
-- Delcare Global Variables

  G_PKG_NAME  CONSTANT VARCHAR2(30):= 'as_interest_types_pub';

-- Start of Comments
--
-- API Name        : create_interest_type
-- Type            : Public
-- Function        : To create the Interest Types using the table handler
-- Pre-Reqs        : Table Handler as_interest_types_pkg.insert_row should exist
-- Parameters      :
--         IN      : p_api_version_number   IN     NUMBER
--                   p_init_msg_list        IN     VARCHAR2
--                   p_commit               IN     VARCHAR2
--                   p_validation_level     IN     NUMBER
--                   p_interest_type_rec    IN     interest_code_rec_type
--        OUT      : x_return_status        OUT    VARCHAR2
--                   x_msg_count            OUT    NUMBER
--                   x_msg_data             OUT    VARCHAR2
-- Version         : 2.0
-- Purpose         : Public API to Create Interest Types in the Oracle Sales Online.
-- Notes           : This procedure is a public procedure called using the
--                   public API as_interest_type_pub to create interest types.
--
-- End of Comments


PROCEDURE create_interest_type(
 p_api_version_number   IN  NUMBER,
 p_init_msg_list        IN  VARCHAR2 ,
 p_commit               IN  VARCHAR2 ,
 p_validation_level     IN  NUMBER   ,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2,
 p_interest_type_rec    IN interest_type_rec_type ,
 x_interest_type_id     OUT NOCOPY NUMBER
 ) IS
-- Declare Local variables and cursors
l_api_version	        NUMBER := p_api_version_number;
l_count               NUMBER := 0;
l_api_name   CONSTANT VARCHAR2(30) := 'create_interest_type';
l_row_id              VARCHAR2(100) := '';
l_creation_date	 DATE   := p_interest_type_rec.creation_date;
l_created_by	        NUMBER := p_interest_type_rec.created_by;
l_last_update_date    DATE;
l_last_update_login   NUMBER;
l_last_updated_by     NUMBER;
l_description         VARCHAR2(240);
l_master_enabled_flag      VARCHAR2(1);
l_enabled_flag             VARCHAR2(1);
l_company_classification_flag VARCHAR2(1);
l_contact_interest_flag    VARCHAR2(1);
l_lead_classification_flag VARCHAR2(1);
l_expected_purchase_flag   VARCHAR2(1);
l_current_environment_flag VARCHAR2(1);
l_org_id                   NUMBER;
l_interest_type            VARCHAR2(80);
l_prod_cat_set_id     NUMBER;
l_prod_cat_id         NUMBER;
l_prod_cat_not_found      VARCHAR2(1) := 'N';

CURSOR interest_dup_cur(p_interest_type IN VARCHAR2) IS
       SELECT 1
 	   FROM as_interest_types_vl
	  WHERE TRIM(NLS_UPPER(interest_type)) = p_interest_type; -- passing in trimmed value while opening.

CURSOR interest_id_cur IS
	 SELECT as_interest_types_s.NEXTVAL
         FROM DUAL;

CURSOR prod_category_val_cur(p_prod_cat_set_id IN NUMBER, p_prod_cat_id IN NUMBER) IS
    SELECT 1 FROM ENI_PROD_DEN_HRCHY_PARENTS_V P
    WHERE P.CATEGORY_ID = p_prod_cat_id
    AND P.CATEGORY_SET_ID = p_prod_cat_set_id;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.intypub.create_interest_type';

BEGIN
	-- Standard Start of API SavePoint
	SAVEPOINT create_interest_type_PUB;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
	 FND_MSG_PUB.initialize;
	END IF;


	-- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	    p_api_version_number,
                                      l_api_name,
		    	    	    	    G_PKG_NAME )
	THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API Body --

	-- Initialize the flags
	IF ( p_interest_type_rec.master_enabled_flag = FND_API.G_MISS_CHAR OR
	   TRIM(p_interest_type_rec.master_enabled_flag) IS NULL) THEN
	   l_master_enabled_flag := 'N';
	ELSE
	   l_master_enabled_flag := p_interest_type_rec.master_enabled_flag;
	END IF;

	IF ( p_interest_type_rec.company_classification_flag = FND_API.G_MISS_CHAR
	OR  TRIM(p_interest_type_rec.company_classification_flag ) IS NULL ) THEN
	   l_company_classification_flag := 'N';
	ELSE
	   l_company_classification_flag := p_interest_type_rec.company_classification_flag;
	END IF;

	IF ( p_interest_type_rec.contact_interest_flag = FND_API.G_MISS_CHAR
	OR  TRIM(p_interest_type_rec.contact_interest_flag ) IS NULL ) THEN
	   l_contact_interest_flag := 'N';
	ELSE
	   l_contact_interest_flag := p_interest_type_rec.contact_interest_flag;
	END IF;

	IF ( p_interest_type_rec.lead_classification_flag = FND_API.G_MISS_CHAR
	OR  TRIM(p_interest_type_rec.lead_classification_flag  )  IS NULL ) THEN
	   l_lead_classification_flag := 'N';
	ELSE
	   l_lead_classification_flag := p_interest_type_rec.lead_classification_flag;
	END IF;

	IF ( p_interest_type_rec.expected_purchase_flag = FND_API.G_MISS_CHAR
	OR  TRIM(p_interest_type_rec.expected_purchase_flag ) IS NULL) THEN
	   l_expected_purchase_flag := 'N';
	ELSE
	   l_expected_purchase_flag := p_interest_type_rec.expected_purchase_flag;
	END IF;

	IF ( p_interest_type_rec.current_environment_flag = FND_API.G_MISS_CHAR
	OR  TRIM(p_interest_type_rec.current_environment_flag ) IS NULL ) THEN
	   l_current_environment_flag := 'N';
	ELSE
	   l_current_environment_flag := p_interest_type_rec.current_environment_flag;
	END IF;

	IF ( p_interest_type_rec.enabled_flag = FND_API.G_MISS_CHAR
	OR  TRIM(p_interest_type_rec.enabled_flag ) IS NULL ) THEN
	   l_enabled_flag := 'N';
	ELSE
	   l_enabled_flag := p_interest_type_rec.enabled_flag;
	END IF;

	-- Initialize the creation date and created by
	--  if the User has not entered them.

	IF (p_interest_type_rec.creation_date= FND_API.G_MISS_DATE)
	OR  TRIM(p_interest_type_rec.creation_date) IS NULL THEN
		l_creation_date := SYSDATE;
	END IF;

	IF (p_interest_type_rec.created_by = FND_API.G_MISS_NUM)
	OR  TRIM(p_interest_type_rec.created_by ) IS NULL THEN
		l_created_by := FND_GLOBAL.user_id;
	ELSE
		l_created_by := p_interest_type_rec.created_by;
	END IF;

	IF (p_interest_type_rec.last_update_date = FND_API.G_MISS_DATE)
	OR  TRIM(p_interest_type_rec.last_update_date) IS NULL THEN
	   l_last_update_date := sysdate;
	ELSE
		l_last_update_date := p_interest_type_rec.last_update_date;
	END IF;

	IF (p_interest_type_rec.last_updated_by = FND_API.G_MISS_NUM)
	OR  TRIM(p_interest_type_rec.last_updated_by ) IS NULL THEN
		l_last_updated_by := FND_GLOBAL.user_id;
	ELSE
		l_last_updated_by := p_interest_type_rec.last_updated_by;
	END IF;

	IF (p_interest_type_rec.last_update_login = FND_API.G_MISS_NUM)
	OR  TRIM(p_interest_type_rec.last_update_login ) IS NULL THEN
		l_last_update_login := FND_GLOBAL.login_id;
	ELSE
		l_last_update_login  := p_interest_type_rec.last_update_login;
	END IF;

	-- If g_miss is passed then replace with null before insert
	-- otherwise use the value passed for the insert.
	-- This is done only for optional fields, for required fields
	-- the DB will throw error.
	IF    p_interest_type_rec.description = FND_API.G_MISS_CHAR
	OR  TRIM(p_interest_type_rec.description ) IS NULL
	THEN
		  l_description := NULL;
	ELSE
		  l_description := p_interest_type_rec.description;
	END IF;

	IF (p_interest_type_rec.prod_cat_set_id = FND_API.G_MISS_NUM) THEN
		l_prod_cat_set_id := NULL;
	ELSE
		l_prod_cat_set_id := p_interest_type_rec.prod_cat_set_id;
	END IF;

	IF (p_interest_type_rec.prod_cat_id = FND_API.G_MISS_NUM) THEN
		l_prod_cat_id := NULL;
	ELSE
		l_prod_cat_id := p_interest_type_rec.prod_cat_id;
	END IF;

   -- Assign org_id
   l_org_id  := p_interest_type_rec.org_id ;

   -- Assign interest_type
   l_interest_type := p_interest_type_rec.interest_type;


	-- Check if Required Values have been passed
	IF ( l_master_enabled_flag NOT IN ('N','Y') ) THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_MAST_ENAB_FLAG');
		FND_MESSAGE.SET_TOKEN('MASTER_ENABLED_FLAG',l_master_enabled_flag);
		FND_MSG_PUB.Add;
	END IF;

	IF ( l_interest_type = FND_API.G_MISS_CHAR
	OR  TRIM(l_interest_type) IS NULL) THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_INT_TYPE');
		 FND_MESSAGE.SET_TOKEN('INTEREST_TYPE',l_interest_type);
		FND_MSG_PUB.Add;
	END IF;

	IF ( l_company_classification_flag NOT IN ('N','Y') ) THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_COMP_CLAS_FLAG');
		FND_MESSAGE.SET_TOKEN('COMPANY_CLASSIFICATION_FLAG',l_company_classification_flag);
		FND_MSG_PUB.Add;
	END IF;

	IF ( l_contact_interest_flag NOT IN ('N','Y') ) THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_CONT_INT_FLAG');
		FND_MESSAGE.SET_TOKEN('CONTACT_INTEREST_FLAG',l_contact_interest_flag);
		FND_MSG_PUB.Add;
	END IF;

	IF ( l_lead_classification_flag  NOT IN ('N','Y') ) THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_LEAD_CLAS_FLAG');
		FND_MESSAGE.SET_TOKEN('LEAD_CLASSIFICATION_FLAG',l_lead_classification_flag);
		FND_MSG_PUB.Add;
	END IF;

	IF ( l_expected_purchase_flag NOT IN ('N','Y') ) THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_EXP_PURC_FLAG');
		FND_MESSAGE.SET_TOKEN('EXPECTED_PURCHASE_FLAG',l_expected_purchase_flag);
		FND_MSG_PUB.Add;
	END IF;

	IF ( l_current_environment_flag NOT IN ('N','Y') ) THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_CURR_ENVT_FLAG');
		FND_MESSAGE.SET_TOKEN('CURRENT_ENVIRONMENT_FLAG',l_current_environment_flag);
		FND_MSG_PUB.Add;
	END IF;

	IF ( l_enabled_flag  NOT IN ('N','Y') ) THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_ENABLED_FLAG');
		FND_MESSAGE.SET_TOKEN('ENABLED_FLAG',l_enabled_flag);
		FND_MSG_PUB.Add;
	END IF;

	IF ( l_org_id = FND_API.G_MISS_NUM
	OR  TRIM(l_org_id) IS NULL ) THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_ORG_ID');
		FND_MESSAGE.SET_TOKEN('ORG_ID',l_org_id);
		FND_MSG_PUB.Add;
	END IF;

   -- Raise exception if error
   IF (FND_MSG_PUB.COUNT_MSG > 0)
   THEN
       RAISE fnd_api.g_exc_error;
   END IF;

	-- Check for duplicate or uniqueness of the Interest Type
    OPEN   interest_dup_cur(TRIM(NLS_UPPER(p_interest_type_rec.interest_type)));
    FETCH  interest_dup_cur INTO l_count;
    IF     (interest_dup_cur%FOUND)
    THEN
     FND_MESSAGE.SET_NAME('ASF', 'ASF_ADM_DUPLICATE');
	 --FND_MESSAGE.SET_NAME ( 'AS' , 'AS_DUPLICATE_INTEREST_TYPE');
         fnd_msg_pub.add;
         CLOSE interest_dup_cur;
         RAISE fnd_api.g_exc_error;
    ELSE
      -- get nextval for interest type id
      OPEN interest_id_cur;
      FETCH interest_id_cur INTO x_interest_type_id;
      IF (interest_id_cur%NOTFOUND)
      THEN
         CLOSE interest_id_cur;
         RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE interest_id_cur;

if (l_prod_cat_set_id is not null
	AND l_prod_cat_id is not null) then
  OPEN prod_category_val_cur
    (l_prod_cat_set_id, l_prod_cat_id);
  FETCH prod_category_val_cur INTO l_count;
  IF (prod_category_val_cur%NOTFOUND) THEN
     l_prod_cat_not_found := 'Y';
     CLOSE prod_category_val_cur;
  END IF;
  CLOSE prod_category_val_cur;
elsif (l_prod_cat_set_id is not null
	OR l_prod_cat_id is not null) then
    l_prod_cat_not_found := 'Y';
end if;

if (l_prod_cat_not_found = 'Y') THEN
    FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_PRODUCT_CATEGORY');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
end if;

	-- Insert a New Interest Type into table
	 as_interest_types_pkg.insert_row(
				l_row_id,
				x_interest_type_id,
				l_master_enabled_flag,
				l_enabled_flag,
				l_company_classification_flag,
				l_contact_interest_flag,
				l_lead_classification_flag,
				l_expected_purchase_flag,
				l_current_environment_flag,
				l_org_id,
				l_interest_type,
				l_description,
				l_creation_date,
				l_created_by,
				l_last_update_date,
				l_last_updated_by,
				l_last_update_login,
                l_prod_cat_set_id,
                l_prod_cat_id
				);
	END IF;

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
	  COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1,
	--  get message info.

	FND_MSG_PUB.Count_And_Get(
					p_count	=> x_msg_count,
					p_data	=> x_msg_data
					);

 EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
 END create_interest_type;

-- Start of Comments
--
-- API Name        : update_interest_type
-- Type            : Public
-- Function        : To update the Interest Types using the table handler
-- Pre-Reqs        : Table Handler as_interest_types_pkg.update_row should exist
-- Parameters      :
--         IN      : p_api_version_number   IN     NUMBER
--                   p_init_msg_list        IN     VARCHAR2
--                   p_commit               IN     VARCHAR2
--                   p_validation_level     IN     NUMBER
--                   p_interest_type_rec    IN     interest_code_rec_type
--        OUT      : x_return_status        OUT    VARCHAR2
--                   x_msg_count            OUT    NUMBER
--                   x_msg_data             OUT    VARCHAR2
-- Version         : 2.0
-- Purpose         : Public API to Update Interest Types in the Oracle Sales Online.
-- Notes           : This procedure is a public procedure called using the
--                   public API as_interest_type_pub to update interest types.
--
-- End of Comments


PROCEDURE update_interest_type(
 p_api_version_number   IN  NUMBER,
 p_init_msg_list        IN  VARCHAR2   ,
 p_commit               IN  VARCHAR2   ,
 p_validation_level     IN  NUMBER     ,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2,
 p_interest_type_rec	IN  as_interest_types_pub.interest_type_rec_type
 ) IS
-- Devlare Local Variables and Cursors
l_api_version              NUMBER := p_api_version_number;
l_count                    NUMBER := 0;
l_api_name 	    CONSTANT VARCHAR2(30) := 'update_interest_type';
x_interest_type_id         NUMBER;
x_master_enabled_flag      VARCHAR2(1);
x_enabled_flag             VARCHAR2(1);
x_company_classification_flag VARCHAR2(1);
X_contact_interest_flag    VARCHAR2(1);
x_lead_classification_flag VARCHAR2(1);
x_expected_purchase_flag   VARCHAR2(1);
x_current_environment_flag VARCHAR2(1);
x_org_id                   NUMBER;
x_interest_type            VARCHAR2(80);
x_description              VARCHAR2(240);
x_last_update_date         DATE;
x_last_updated_by          NUMBER;
x_last_update_login        NUMBER;
x_prod_cat_set_id	   NUMBER;
x_prod_cat_id		   NUMBER;
l_interest_type_id         NUMBER;
l_master_enabled_flag      VARCHAR2(1);
l_enabled_flag             VARCHAR2(1);
l_company_classification_flag VARCHAR2(1);
l_contact_interest_flag    VARCHAR2(1);
l_lead_classification_flag VARCHAR2(1);
l_expected_purchase_flag   VARCHAR2(1);
l_current_environment_flag VARCHAR2(1);
l_org_id                   NUMBER;
l_interest_type            VARCHAR2(80);
l_description              VARCHAR2(240);
l_last_update_date         DATE;
l_last_updated_by          NUMBER;
l_current_last_update_date DATE;
l_last_update_login        NUMBER;
l_prod_cat_set_id	   NUMBER;
l_prod_cat_id		   NUMBER;
l_prod_cat_not_found      VARCHAR2(1) := 'N';

CURSOR get_db_values_cur(p_interest_type_id IN NUMBER) IS
 SELECT  master_enabled_flag,
         org_id,
         description,
         enabled_flag,
         company_classification_flag,
         contact_interest_flag,
         lead_classification_flag,
         expected_purchase_flag,
         current_environment_flag,
         interest_type,
         last_update_date,
         last_updated_by,
         last_update_login,
         product_cat_set_id,
         product_category_id
  FROM   as_interest_types_vl
 WHERE   interest_type_id = p_interest_type_id;

CURSOR as_int_type_cur(p_interest_type_id IN NUMBER,p_interest_type IN VARCHAR2) IS
	SELECT 1
	  FROM as_interest_types_vl
	 WHERE interest_type_id <> p_interest_type_id
         AND TRIM(NLS_UPPER(interest_type)) = p_interest_type;


CURSOR  lock_row_for_update( p_interest_type_id in NUMBER) IS
      SELECT   last_update_date
        FROM   as_interest_types_vl
       WHERE   interest_type_id = p_interest_type_id;

CURSOR prod_category_val_cur(p_prod_cat_set_id IN NUMBER, p_prod_cat_id IN NUMBER) IS
    SELECT 1 FROM ENI_PROD_DEN_HRCHY_PARENTS_V P
    WHERE P.CATEGORY_ID = p_prod_cat_id
    AND P.CATEGORY_SET_ID = p_prod_cat_set_id;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.intypub.update_interest_type';

BEGIN

	-- Standard STart of API SavePoint
	SAVEPOINT update_interest_type_PUB;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
	 FND_MSG_PUB.initialize;
	END IF;

	-- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                            p_api_version_number,
                                            l_api_name,
                                            G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API Body --

	-- Check if Required Values have been passed
 	   IF (p_interest_type_rec.interest_type_id = FND_API.G_MISS_NUM)
          OR TRIM(p_interest_type_rec.interest_type_id) IS NULL THEN
	   	FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_INT_TYPE_ID');
	   	FND_MESSAGE.SET_TOKEN('INTEREST_TYPE_ID',
				p_interest_type_rec.interest_type_id);
		FND_MSG_PUB.Add;
	   END IF;


-- Check if the values are passed, if the g_miss values are passed then
-- replace the g_miss values with the database value. If the user passes
-- the value then use that value for update.

    OPEN   get_db_values_cur(p_interest_type_rec.interest_type_id);
    FETCH  get_db_values_cur INTO
           l_master_enabled_flag,
           l_org_id,
           l_description,
           l_enabled_flag,
           l_company_classification_flag,
           l_contact_interest_flag,
           l_lead_classification_flag,
           l_expected_purchase_flag,
           l_current_environment_flag,
           l_interest_type,
           l_last_update_date,
           l_last_updated_by,
           l_last_update_login,
           l_prod_cat_set_id,
           l_prod_cat_id;
    IF     get_db_values_cur%NOTFOUND
    THEN
           CLOSE  get_db_values_cur;
           RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE  get_db_values_cur;


	-- If the value passed in is G_MISS then replace the value with
	-- fetched value from the database before updating.

	IF p_interest_type_rec.master_enabled_flag = FND_API.G_MISS_CHAR
	THEN
	   x_master_enabled_flag := l_master_enabled_flag ;
	ELSE
	   x_master_enabled_flag  := p_interest_type_rec.master_enabled_flag ;
	END IF;

	IF p_interest_type_rec.enabled_flag = FND_API.G_MISS_CHAR
	THEN
	   x_enabled_flag  := l_enabled_flag ;
	ELSE
	   x_enabled_flag  := p_interest_type_rec.enabled_flag ;
	END IF;

	IF p_interest_type_rec.company_classification_flag = FND_API.G_MISS_CHAR
	THEN
	   x_company_classification_flag  := l_company_classification_flag ;
	ELSE
	   x_company_classification_flag  := p_interest_type_rec.company_classification_flag ;
	END IF;

	IF p_interest_type_rec.contact_interest_flag = FND_API.G_MISS_CHAR
	THEN
	   x_contact_interest_flag  := l_contact_interest_flag ;
	ELSE
	   x_contact_interest_flag  := p_interest_type_rec.contact_interest_flag ;
	END IF;

	IF p_interest_type_rec.lead_classification_flag = FND_API.G_MISS_CHAR
	THEN
	   x_lead_classification_flag  := l_lead_classification_flag ;
	ELSE
	   x_lead_classification_flag  := p_interest_type_rec.lead_classification_flag ;
	END IF;

	IF p_interest_type_rec.expected_purchase_flag = FND_API.G_MISS_CHAR
	THEN
	   x_expected_purchase_flag  := l_expected_purchase_flag ;
	ELSE
	   x_expected_purchase_flag  := p_interest_type_rec.expected_purchase_flag ;
	END IF;

	IF p_interest_type_rec.current_environment_flag = FND_API.G_MISS_CHAR
	THEN
	   x_current_environment_flag  := l_current_environment_flag ;
	ELSE
	   x_current_environment_flag  := p_interest_type_rec.current_environment_flag ;
	END IF;


	IF p_interest_type_rec.org_id = FND_API.G_MISS_NUM
	THEN
	   x_org_id  := l_org_id ;
	ELSE
	   x_org_id  := p_interest_type_rec.org_id ;
	END IF;


	IF p_interest_type_rec.interest_type = FND_API.G_MISS_CHAR
	THEN
	   x_interest_type  := l_interest_type ;
	ELSE
	   x_interest_type  := p_interest_type_rec.interest_type ;
	END IF;

	IF p_interest_type_rec.description = FND_API.G_MISS_CHAR
	THEN
	   x_description  := l_description ;
	ELSE
	   x_description  := p_interest_type_rec.description ;
	END IF;

	IF p_interest_type_rec.last_update_date = FND_API.G_MISS_DATE
	OR TRIM(p_interest_type_rec.last_update_date) IS NULL
	THEN
	   x_last_update_date  := sysdate ;
	ELSE
	   x_last_update_date  := p_interest_type_rec.last_update_date ;
	END IF;

	IF p_interest_type_rec.last_updated_by = FND_API.G_MISS_NUM
	OR TRIM(p_interest_type_rec.last_updated_by ) IS NULL
	THEN
	   x_last_updated_by  := fnd_global.user_id ;
	ELSE
	   x_last_updated_by  := p_interest_type_rec.last_updated_by ;
	END IF;

	IF p_interest_type_rec.last_update_login = FND_API.G_MISS_NUM
	OR TRIM(p_interest_type_rec.last_update_login ) IS NULL
	THEN
	   x_last_update_login :=  fnd_global.login_id ;
	ELSE
	   x_last_update_login := p_interest_type_rec.last_update_login ;
	END IF;

	IF p_interest_type_rec.prod_cat_set_id = FND_API.G_MISS_NUM
	THEN
	   x_prod_cat_set_id :=  l_prod_cat_set_id;
	ELSE
	   x_prod_cat_set_id := p_interest_type_rec.prod_cat_set_id;
	END IF;
	IF p_interest_type_rec.prod_cat_id = FND_API.G_MISS_NUM
	THEN
	   x_prod_cat_id :=  l_prod_cat_id;
	ELSE
	   x_prod_cat_id := p_interest_type_rec.prod_cat_id;
	END IF;

	--Default Flags if null
	IF x_master_enabled_flag IS NULL THEN
		x_master_enabled_flag := 'N';
	END IF;

	IF x_contact_interest_flag IS NULL THEN
		x_contact_interest_flag := 'N';
	END IF;

	IF x_company_classification_flag IS NULL THEN
		x_company_classification_flag := 'N';
	END IF;

	IF x_lead_classification_flag IS NULL THEN
		x_lead_classification_flag := 'N';
	END IF;

	IF x_expected_purchase_flag IS NULL THEN
		x_expected_purchase_flag := 'N';
	END IF;

	IF x_current_environment_flag IS NULL THEN
		x_current_environment_flag := 'N';
	END IF;

	IF x_enabled_flag IS NULL THEN
		x_enabled_flag := 'N';
	END IF;


	-- Check if Valid Values have been passed
	--  e.g. If master_enabled_flag value is passed and Not N or Y
	--        trap it as an error
	--

    IF x_master_enabled_flag NOT IN ('N','Y')
    THEN
            FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_MAST_ENAB_FLAG');
            FND_MESSAGE.SET_TOKEN('MASTER_ENABLED_FLAG',p_interest_type_rec.master_enabled_flag);
            FND_MSG_PUB.Add;
    END IF;

    IF x_contact_interest_flag NOT IN ('N','Y')
    THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_CONT_INT_FLAG');
		FND_MESSAGE.SET_TOKEN('CONTACT_INTEREST_FLAG',p_interest_type_rec.contact_interest_flag);
		FND_MSG_PUB.Add;
    END IF;

    IF x_company_classification_flag NOT IN ('N','Y')
    THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_COMP_CLAS_FLAG');
		FND_MESSAGE.SET_TOKEN('COMPANY_CLASSIFICAITON_FLAG',p_interest_type_rec.company_classification_flag);
		FND_MSG_PUB.Add;
    END IF;

	IF  x_lead_classification_flag  NOT IN ('N','Y')
    THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_LEAD_CLAS_FLAG');
		FND_MESSAGE.SET_TOKEN('LEAD_CLASSIFICATION_FLAG',p_interest_type_rec.lead_classification_flag);
		FND_MSG_PUB.Add;
    END IF;


    IF  x_expected_purchase_flag NOT IN ('N','Y')
    THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_EXP_PURC_FLAG');
		FND_MESSAGE.SET_TOKEN('EXPECTED_PURCHASE_FLAG',p_interest_type_rec.expected_purchase_flag);
		FND_MSG_PUB.Add;
    END IF;


	IF  x_current_environment_flag NOT IN ('N','Y')
    THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_CURR_ENVT_FLAG');
		FND_MESSAGE.SET_TOKEN('CURRENT_ENVIRONMENT_FLAG',p_interest_type_rec.current_environment_flag);
		FND_MSG_PUB.Add;
    END IF;


    IF  x_enabled_flag  NOT IN ('N','Y')
    THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_ENABLED_FLAG');
		FND_MESSAGE.SET_TOKEN('ENABLED_FLAG',p_interest_type_rec.enabled_flag);
		FND_MSG_PUB.Add;
    END IF;

    IF x_org_id = FND_API.G_MISS_NUM
    THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_ORG_ID');
		FND_MESSAGE.SET_TOKEN('ORG_ID',p_interest_type_rec.org_id);
		FND_MSG_PUB.Add;
    END IF;

    IF (FND_MSG_PUB.COUNT_MSG > 0)
    THEN
       RAISE fnd_api.g_exc_error;
    END IF;


   -- Check if Interest Type ID and Type exists
   OPEN   as_int_type_cur(p_interest_type_rec.interest_type_id,TRIM(NLS_UPPER(p_interest_type_rec.interest_type)));
   FETCH  as_int_type_cur INTO l_count;
   IF     as_int_type_cur%FOUND
   THEN
   	  FND_MESSAGE.SET_NAME('ASF', 'ASF_ADM_DUPLICATE');
      FND_MSG_PUB.Add;
      CLOSE as_int_type_cur;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE as_int_type_cur;

	if (x_prod_cat_set_id is not null
		AND x_prod_cat_id is not null) then
	  OPEN prod_category_val_cur
		(x_prod_cat_set_id, x_prod_cat_id);
	  FETCH prod_category_val_cur INTO l_count;
	  IF (prod_category_val_cur%NOTFOUND) THEN
		 l_prod_cat_not_found := 'Y';
	  END IF;
	  CLOSE prod_category_val_cur;
	elsif (x_prod_cat_set_id is not null
		OR x_prod_cat_id is not null) then
		l_prod_cat_not_found := 'Y';
	end if;

	if (l_prod_cat_not_found = 'Y') THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_PRODUCT_CATEGORY');
		fnd_msg_pub.add;
		RAISE fnd_api.g_exc_error;
	end if;

	--  Lock the row for update. Check to see if the fetched value is same still.
	-- If they are same then update the record else give a message that the row has been
	-- updated by others.

   OPEN   lock_row_for_update(p_interest_type_rec.interest_type_id);
   FETCH  lock_row_for_update INTO  l_current_last_update_date;
   IF     lock_row_for_update%NOTFOUND
   THEN
          CLOSE  lock_row_for_update;
          RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF l_last_update_date <> l_current_last_update_date
   THEN
          fnd_message.set_name('AS', 'API_RECORD_CHANGED');
          FND_MESSAGE.Set_Token('INFO', 'interest_type', FALSE); -- ??
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
   END IF;

	-- update Interest Type ID in the table
	  as_interest_types_pkg.update_row(
				 p_interest_type_rec.interest_type_id,
				 x_master_enabled_flag,
				 x_enabled_flag,
				 x_company_classification_flag,
				 x_contact_interest_flag,
				 x_lead_classification_flag,
				 x_expected_purchase_flag,
				 x_current_environment_flag,
				 x_org_id,
				 x_interest_type,
				 x_description,
				 SYSDATE,
				 x_last_updated_by,
				 x_last_update_login,
                 x_prod_cat_set_id,
                 x_prod_cat_id);

      -- Close Cursor
      CLOSE  lock_row_for_update ;

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
	  COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get
	--  message info.
	FND_MSG_PUB.Count_And_Get(
					p_count	=> x_msg_count,
					p_data	=> x_msg_data
					);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END update_interest_type;
END as_interest_types_pub;


/
