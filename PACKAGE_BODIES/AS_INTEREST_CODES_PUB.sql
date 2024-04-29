--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_CODES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_CODES_PUB" as
/* $Header: asxintcb.pls 120.1 2005/06/14 01:30:16 appldev  $ */
-- Delcare Global Variables
G_PKG_NAME  CONSTANT VARCHAR2(30):='as_interest_codes_pub';

--
-- ****************************************************************************
--
-- NAME : AS_INTEREST_CODES_PUB
--
-- Purpose :
-- 	Public API to Create and Update Interest Codes in the Oracle Sales
--	Online
--
-- History
--
--   09/14/2002    Rajan T          Created
--
-- ****************************************************************************


-- Start of Comments
--
-- API Name        : create_interest_code
-- Type            : Public
-- Function        : To create the Interest Codes using the table handler
-- Pre-Reqs        : Table Handler as_interest_codes_pkg.insert_row should exist
-- Parameters      :
--         IN      : p_api_version_number   IN     NUMBER
--                   p_init_msg_list        IN     VARCHAR2
--                   p_commit               IN     VARCHAR2
--                   p_validation_level     IN     NUMBER
--                   p_interest_code_rec    IN     interest_code_rec_type
--        OUT      : x_return_status        OUT    VARCHAR2
--                   x_msg_count            OUT    NUMBER
--                   x_msg_data             OUT    VARCHAR2
-- Version         : 2.0
-- Purpose         : Public API to Create Interest Codes in the Oracle Sales Online.
-- Notes           : This procedure is a public procedure called using the
--                   public API as_interest_code_pub to create interest codes.
--
-- End of Comments

PROCEDURE create_interest_code(
  p_api_version_number 	IN 	NUMBER,
  p_init_msg_list		IN	VARCHAR2 ,
  p_commit			IN	VARCHAR2 ,
  p_validation_level	IN	NUMBER   ,
  x_return_status		OUT NOCOPY	VARCHAR2,
  x_msg_count		OUT NOCOPY	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2,
  p_interest_code_rec	IN	interest_code_rec_type ,
  x_interest_code_id 	OUT NOCOPY	NUMBER
) IS
-- Declare Local Variables and Cursors
  l_api_version	       NUMBER := p_api_version_number;
  l_count 		       NUMBER := 0;
  l_api_name       CONSTANT VARCHAR2(30) := 'create_interest_code';
  x_row_id 		       VARCHAR2(100) := '';
  l_creation_date 	       DATE;
  l_created_by 	       NUMBER;
  l_last_update_date        DATE;
  l_current_last_update_date        DATE;
  l_last_update_login       NUMBER;
  l_last_updated_by         NUMBER;
  l_parent_interest_code_id NUMBER;
  l_category_id             NUMBER;
  l_category_set_id         NUMBER;
  l_attribute_category      VARCHAR2(30);
  l_attribute1              VARCHAR2(150);
  l_attribute2              VARCHAR2(150);
  l_attribute3              VARCHAR2(150);
  l_attribute4              VARCHAR2(150);
  l_attribute5              VARCHAR2(150);
  l_attribute6              VARCHAR2(150);
  l_attribute7              VARCHAR2(150);
  l_attribute8              VARCHAR2(150);
  l_attribute9              VARCHAR2(150);
  l_attribute10             VARCHAR2(150);
  l_attribute11             VARCHAR2(150);
  l_attribute12             VARCHAR2(150);
  l_attribute13             VARCHAR2(150);
  l_attribute14             VARCHAR2(150);
  l_attribute15             VARCHAR2(150);
  l_pf_item_id              NUMBER;
  l_pf_organization_id      NUMBER;
  l_price                   NUMBER;
  l_currency_code           VARCHAR2(15);
  l_code                    VARCHAR2(100);
  l_description             VARCHAR2(240);
  l_prod_cat_set_id         NUMBER;
  l_prod_cat_id             NUMBER;
  l_prod_cat_not_found      VARCHAR2(1) := 'N';

CURSOR as_int_code_cur(p_parent_interest_code_id IN NUMBER) IS
      SELECT 1
	  FROM as_interest_codes_vl
	 WHERE interest_code_id = p_parent_interest_code_id
           AND interest_code_id IS NOT NULL;


CURSOR as_int_type_cur(p_interest_type_id IN NUMBER) IS
	SELECT 1
	  FROM as_interest_types_vl
	 WHERE interest_type_id = p_interest_type_id
           AND interest_type_id IS NOT NULL;


CURSOR as_int_codes_vl_cur(p_code IN VARCHAR2,p_interest_type_id IN NUMBER) IS
	SELECT 1
	  FROM as_interest_codes_vl
	 WHERE TRIM(NLS_UPPER(code)) = p_code  -- passing in trimmed value while opening.
	   AND interest_type_id = p_interest_type_id
	   AND parent_interest_code_id IS NULL ;

CURSOR as_int_codes_vl_1_cur(p_code IN VARCHAR2,p_interest_type_id IN NUMBER,p_parent_interest_code_id IN NUMBER) IS
	SELECT 1
	  FROM as_interest_codes_vl
	 WHERE TRIM(NLS_UPPER(code)) = p_code  -- passing in trimmed value while opening.
	   AND interest_type_id = p_interest_type_id
	   AND parent_interest_code_id = p_parent_interest_code_id ;

CURSOR as_int_code_nextval_cur IS
	 SELECT as_interest_codes_s.NEXTVAL
	   FROM DUAL;

CURSOR prod_category_val_cur(p_prod_cat_set_id IN NUMBER, p_prod_cat_id IN NUMBER) IS
    SELECT 1 FROM ENI_PROD_DEN_HRCHY_PARENTS_V P
    WHERE P.CATEGORY_ID = p_prod_cat_id
    AND P.CATEGORY_SET_ID = p_prod_cat_set_id;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.intc.create_interest_code';

BEGIN
	-- Standard Start of API SavePoint
	SAVEPOINT create_interest_code_PUB;

        FND_MSG_PUB.DELETE_MSG;

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
	   IF p_interest_code_rec.code = FND_API.G_MISS_CHAR
         OR TRIM(p_interest_code_rec.code) IS NULL
         THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_INT_CODE');
		--FND_MESSAGE.SET_TOKEN('INTEREST_CODE',p_interest_code_rec.code);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	   END IF;

         IF p_interest_code_rec.interest_type_id  = FND_API.G_MISS_NUM
         OR TRIM(p_interest_code_rec.interest_type_id) IS NULL
         THEN
		FND_MESSAGE.SET_NAME ( 'ASF' , 'ASF_MISSING_INTEREST_TYPE');
		--FND_MESSAGE.SET_TOKEN('INTEREST_TYPE_ID',p_interest_code_rec.interest_type_id);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	   END IF;

	   IF p_interest_code_rec.master_enabled_flag NOT IN ('N','Y')
         OR TRIM(p_interest_code_rec.master_enabled_flag) IS NULL
         OR p_interest_code_rec.master_enabled_flag  = FND_API.G_MISS_CHAR
         THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_MAST_ENAB_FLAG');
		FND_MESSAGE.SET_TOKEN('MASTER_ENABLED_FLAG',p_interest_code_rec.master_enabled_flag);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	   END IF;

	-- Check for Who columns to see if they values passed is G_MISS
	-- Replace the G_MISS with NULL else replace with the value passed

	  IF p_interest_code_rec.creation_date  = FND_API.G_MISS_DATE
	  OR TRIM(p_interest_code_rec.creation_date) IS NULL
	  THEN
		 l_creation_date := SYSDATE;
	  ELSE
		 l_creation_date := p_interest_code_rec.creation_date;
	  END IF;
	  IF p_interest_code_rec.created_by  = FND_API.G_MISS_NUM
	  OR TRIM(p_interest_code_rec.created_by) IS NULL
	  THEN
		l_created_by := FND_GLOBAL.user_id;
	  ELSE
		l_created_by := p_interest_code_rec.created_by;
	  END IF;
	  IF p_interest_code_rec.last_update_date  = FND_API.G_MISS_DATE
	  OR TRIM(p_interest_code_rec.last_update_date) IS NULL
	  THEN
		l_last_update_date := SYSDATE;
	  ELSE
		l_last_update_date := p_interest_code_rec.last_update_date;
	  END IF;
	  IF p_interest_code_rec.last_updated_by  = FND_API.G_MISS_NUM
	  OR TRIM(p_interest_code_rec.last_updated_by) IS NULL
	  THEN
		l_last_updated_by := FND_GLOBAL.user_id;
	  ELSE
		l_last_updated_by := p_interest_code_rec.last_updated_by;
	  END IF;
	  IF p_interest_code_rec.last_update_login  = FND_API.G_MISS_NUM
	  OR TRIM(p_interest_code_rec.last_update_login) IS NULL
	  THEN
		l_last_update_login := FND_GLOBAL.login_id;
	  ELSE
		l_last_update_login := p_interest_code_rec.last_update_login;
	  END IF;

	-- End of Who Columns Check

	-- Check for all optional fields to see if the value is G_MISS then
	-- replace with NULL before insert. Else use the value passed for insert.
	-- Only optional fields needs to be checked for Insert and replace with
	-- NULL for required fields the DB will throw error.

	IF p_interest_code_rec.parent_interest_code_id = FND_API.G_MISS_NUM
	THEN
		 l_parent_interest_code_id := NULL;
	ELSE
		 l_parent_interest_code_id := p_interest_code_rec.parent_interest_code_id;
	END IF;

	IF p_interest_code_rec.category_id = FND_API.G_MISS_NUM
	OR TRIM(p_interest_code_rec.category_id) IS NULL
	THEN
	   l_category_id := NULL;
	ELSE
	   l_category_id := p_interest_code_rec.category_id;
	END IF;
	IF p_interest_code_rec.category_set_id = FND_API.G_MISS_NUM
	OR TRIM(p_interest_code_rec.category_set_id) IS NULL
	THEN
	   l_category_set_id := NULL;
	ELSE
	   l_category_set_id := p_interest_code_rec.category_set_id;
	END IF;
	IF p_interest_code_rec.attribute_category = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute_category) IS NULL
	THEN
	   l_attribute_category := NULL;
	ELSE
	   l_attribute_category := p_interest_code_rec.attribute_category ;
	END IF;
	IF p_interest_code_rec.attribute1 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute1) IS NULL
	THEN
	   l_attribute1 := NULL;
	ELSE
	   l_attribute1 := p_interest_code_rec.attribute1;
	END IF;
	IF p_interest_code_rec.attribute2 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute2) IS NULL
	THEN
	   l_attribute2 := NULL;
	ELSE
	   l_attribute2 := p_interest_code_rec.attribute2;
	END IF;
	IF p_interest_code_rec.attribute3 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute3) IS NULL
	THEN
	   l_attribute3 := NULL;
	ELSE
	   l_attribute3 := p_interest_code_rec.attribute3;
	END IF;
	IF p_interest_code_rec.attribute4 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute4) IS NULL
	THEN
	   l_attribute4 := NULL;
	ELSE
	   l_attribute4 := p_interest_code_rec.attribute4;
	END IF;
	IF p_interest_code_rec.attribute5 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute5) IS NULL
	THEN
	   l_attribute5 := NULL;
	ELSE
	   l_attribute5 := p_interest_code_rec.attribute5;
	END IF;
	IF p_interest_code_rec.attribute6 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute6) IS NULL
	THEN
	   l_attribute6 := NULL;
	ELSE
	   l_attribute6 := p_interest_code_rec.attribute6;
	END IF;
	IF p_interest_code_rec.attribute7 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute7) IS NULL
	THEN
	   l_attribute7 := NULL;
	ELSE
	   l_attribute7 := p_interest_code_rec.attribute7;
	END IF;
	IF p_interest_code_rec.attribute8 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute8) IS NULL
	THEN
	   l_attribute8 := NULL;
	ELSE
	   l_attribute8 := p_interest_code_rec.attribute8;
	END IF;
	IF p_interest_code_rec.attribute9 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute9) IS NULL
	THEN
	   l_attribute9 := NULL;
	ELSE
	   l_attribute9 := p_interest_code_rec.attribute9;
	END IF;
	IF p_interest_code_rec.attribute10 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute10) IS NULL
	THEN
	   l_attribute10 := NULL;
	ELSE
	   l_attribute10 := p_interest_code_rec.attribute10;
	END IF;
	IF p_interest_code_rec.attribute11 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute11) IS NULL
	THEN
	   l_attribute11 := NULL;
	ELSE
	   l_attribute11 := p_interest_code_rec.attribute11;
	END IF;
	IF p_interest_code_rec.attribute12 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute12) IS NULL
	THEN
	   l_attribute12 := NULL;
	ELSE
	   l_attribute12 := p_interest_code_rec.attribute12;
	END IF;
	IF p_interest_code_rec.attribute13 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute13) IS NULL
	THEN
	   l_attribute13 := NULL;
	ELSE
	   l_attribute13 := p_interest_code_rec.attribute13;
	END IF;
	IF p_interest_code_rec.attribute14 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute14) IS NULL
	THEN
	   l_attribute14 := NULL;
	ELSE
	   l_attribute14 := p_interest_code_rec.attribute14;
	END IF;
	IF p_interest_code_rec.attribute15 = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.attribute15) IS NULL
	THEN
	   l_attribute15 := NULL;
	ELSE
	   l_attribute15 := p_interest_code_rec.attribute15;
	END IF;
	IF p_interest_code_rec.pf_item_id = FND_API.G_MISS_NUM
	OR TRIM(p_interest_code_rec.pf_item_id) IS NULL
	THEN
	   l_pf_item_id := NULL;
	ELSE
	   l_pf_item_id := p_interest_code_rec.pf_item_id ;
	END IF;
	IF p_interest_code_rec.pf_organization_id = FND_API.G_MISS_NUM
	OR TRIM(p_interest_code_rec.pf_organization_id) IS NULL
	THEN
		  l_pf_organization_id := NULL;
	ELSE
		  l_pf_organization_id := p_interest_code_rec.pf_organization_id ;
	END IF;
	IF   p_interest_code_rec.price = FND_API.G_MISS_NUM
	OR   TRIM(p_interest_code_rec.price) IS NULL
	THEN
		  l_price := NULL;
	ELSE
		  l_price  := p_interest_code_rec.price ;
	END IF;
	IF p_interest_code_rec.currency_code = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.currency_code) IS NULL
	THEN
		  l_currency_code := NULL;
	ELSE
		  l_currency_code  := p_interest_code_rec.currency_code ;
	END IF;
	IF p_interest_code_rec.code = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.code) IS NULL
	THEN
		  l_code := NULL;
	ELSE
		  l_code  := p_interest_code_rec.code ;
	END IF;
	IF p_interest_code_rec.description = FND_API.G_MISS_CHAR
	OR TRIM(p_interest_code_rec.description) IS NULL
	THEN
		  l_description := NULL;
	ELSE
		  l_description  := p_interest_code_rec.description ;
	END IF;

	IF (p_interest_code_rec.prod_cat_set_id = FND_API.G_MISS_NUM) THEN
		l_prod_cat_set_id := NULL;
	ELSE
		l_prod_cat_set_id := p_interest_code_rec.prod_cat_set_id;
	END IF;

	IF (p_interest_code_rec.prod_cat_id = FND_API.G_MISS_NUM) THEN
		l_prod_cat_id := NULL;
	ELSE
		l_prod_cat_id := p_interest_code_rec.prod_cat_id;
	END IF;
	-- End of all optional fields check for g_miss


	-- Check if Interest Type ID and Parent Interest Code ID exist in
	--  as_interest_types_vl and as_interest_codes_vl respectively

	IF (l_parent_interest_code_id IS NOT NULL)
	THEN
		 OPEN   as_int_code_cur(p_interest_code_rec.parent_interest_code_id);
		 FETCH  as_int_code_cur INTO l_count;
		 IF (as_int_code_cur%NOTFOUND)
		 THEN
		  FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_PAR_INT_CODE_ID');
		  FND_MESSAGE.SET_TOKEN('PARENT_INTEREST_CODE_ID',p_interest_code_rec.parent_interest_code_id);
		  FND_MSG_PUB.Add;
			  CLOSE as_int_code_cur;
		  RAISE FND_API.G_EXC_ERROR;
		 END IF;
		 CLOSE as_int_code_cur;
	END IF;

	IF (p_interest_code_rec.interest_type_id IS NOT NULL) THEN
		OPEN  as_int_type_cur(p_interest_code_rec.interest_type_id);
		FETCH as_int_type_cur INTO l_count;
		IF (as_int_type_cur%NOTFOUND)
		THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_INT_TYPE_ID');
		FND_MESSAGE.SET_TOKEN('INTEREST_TYPE_ID',p_interest_code_rec.interest_type_id);
		FND_MSG_PUB.Add;
			CLOSE as_int_type_cur;
		RAISE FND_API.G_EXC_ERROR;
		END IF;
		CLOSE as_int_type_cur;
	END IF;

	-- Check if the Interest Code exists.

	IF l_parent_interest_code_id  IS NULL THEN

	-- If parent interest code id is null, then the combination of
	--  interest_type_id and code must be unique

	   OPEN  as_int_codes_vl_cur(TRIM(NLS_UPPER(p_interest_code_rec.code)),p_interest_code_rec.interest_type_id);
	   FETCH as_int_codes_vl_cur INTO l_count;
	   IF    as_int_codes_vl_cur%FOUND
	   THEN
		FND_MESSAGE.SET_NAME('ASF', 'ASF_ADM_DUPLICATE');
		FND_MSG_PUB.Add;
			CLOSE as_int_codes_vl_cur;
			RAISE FND_API.G_EXC_ERROR;
	   END IF;
	   CLOSE as_int_codes_vl_cur;

	ELSE

	-- If parent interest code id is Not null, then the
	-- combination of interest_type_id,parent interest code id
	-- and code must be unique

	   OPEN  as_int_codes_vl_1_cur(TRIM(NLS_UPPER(p_interest_code_rec.code)),p_interest_code_rec.interest_type_id,p_interest_code_rec.parent_interest_code_id);
	   FETCH as_int_codes_vl_1_cur INTO l_count;
	   IF    as_int_codes_vl_1_cur%FOUND
	   THEN
		FND_MESSAGE.SET_NAME('ASF', 'ASF_ADM_DUPLICATE');
		FND_MSG_PUB.Add;
			CLOSE as_int_codes_vl_1_cur;
			RAISE FND_API.G_EXC_ERROR;
	   END IF;
	   CLOSE as_int_codes_vl_1_cur;
	END IF;

	-- Get the sequence number before inserting.
     OPEN  as_int_code_nextval_cur;
     FETCH as_int_code_nextval_cur INTO x_interest_code_id;
     IF    as_int_code_nextval_cur%NOTFOUND
     THEN
            CLOSE as_int_code_nextval_cur;
            RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE as_int_code_nextval_cur;

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

	-- Insert a New Interest Code into table
	 as_interest_codes_pkg.insert_row(
				x_row_id,
				x_interest_code_id,
				p_interest_code_rec.interest_type_id,
				p_interest_code_rec.master_enabled_flag,
				l_parent_interest_code_id,
				l_category_id,
				l_category_set_id,
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
				l_attribute15,
				l_pf_item_id,
				l_pf_organization_id,
				l_price,
				l_currency_code,
				TRIM(l_code),
				l_description,
				l_creation_date,
				l_created_by,
				l_last_update_date,
				l_last_updated_by,
				l_last_update_login,
                l_prod_cat_set_id,
                l_prod_cat_id
				);


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
 END create_interest_code;

-- Start of Comments
--
-- API Name        : update_interest_code
-- Type            : Public
-- Function        : To update the Interest Codes using the table handler
-- Pre-Reqs        : Table Handler as_interest_codes_pkg.update_row should exist
-- Parameters      :
--         IN      : p_api_version_number   IN     NUMBER
--                   p_init_msg_list        IN     VARCHAR2
--                   p_commit               IN     VARCHAR2
--                   p_validation_level     IN     NUMBER
--                   p_interest_code_rec    IN     interest_code_rec_type
--        OUT      : x_return_status        OUT    VARCHAR2
--                   x_msg_count            OUT    NUMBER
--                   x_msg_data             OUT    VARCHAR2
-- Version         : 2.0
-- Purpose         : Public API to update Interest Codes in the Oracle Sales Online.
-- Notes           : This procedure is a public procedure called using the
--                   public API as_interest_code_pub to update interest codes.
--
-- End of Comments

PROCEDURE update_interest_code(
p_api_version_number 	IN 	NUMBER,
p_init_msg_list		IN	VARCHAR2 ,
p_commit	        IN	VARCHAR2 ,
p_validation_level	IN	NUMBER   ,
x_return_status		OUT NOCOPY	VARCHAR2,
x_msg_count             OUT NOCOPY	NUMBER,
x_msg_data              OUT NOCOPY	VARCHAR2,
p_interest_code_rec	IN	interest_code_rec_type
) IS
-- Declare Local Variable and Cursors
l_api_version	          NUMBER := p_api_version_number;
l_count 		  NUMBER := 0;
l_count_ids 		  NUMBER := 0;
l_api_name 	CONSTANT  VARCHAR2(30) := 'update_interest_code';
x_last_update_date        DATE;
x_last_update_login       NUMBER;
x_last_updated_by         NUMBER;
l_last_update_date        DATE;
l_current_last_update_date        DATE;
l_last_update_login       NUMBER;
l_last_updated_by         NUMBER;
x_parent_interest_code_id NUMBER;
x_interest_code_id        NUMBER;
x_category_id             NUMBER;
x_category_set_id         NUMBER;
x_interest_type_id        NUMBER;
x_attribute_category      VARCHAR2(30);
x_attribute1              VARCHAR2(150);
x_attribute2              VARCHAR2(150);
x_attribute3              VARCHAR2(150);
x_attribute4              VARCHAR2(150);
x_attribute5              VARCHAR2(150);
x_attribute6              VARCHAR2(150);
x_attribute7              VARCHAR2(150);
x_attribute8              VARCHAR2(150);
x_attribute9              VARCHAR2(150);
x_attribute10             VARCHAR2(150);
x_attribute11             VARCHAR2(150);
x_attribute12             VARCHAR2(150);
x_attribute13             VARCHAR2(150);
x_attribute14             VARCHAR2(150);
x_attribute15             VARCHAR2(150);
x_pf_item_id              NUMBER;
x_pf_organization_id      NUMBER;
x_price                   NUMBER;
x_currency_code           VARCHAR2(15);
x_code                    VARCHAR2(100);
x_description             VARCHAR2(240);
x_master_enabled_flag     VARCHAR2(1);
l_parent_interest_code_id NUMBER;
l_interest_code_id        NUMBER;
l_category_id             NUMBER;
l_category_set_id         NUMBER;
l_interest_type_id        NUMBER;
l_attribute_category      VARCHAR2(30);
l_attribute1              VARCHAR2(150);
l_attribute2              VARCHAR2(150);
l_attribute3              VARCHAR2(150);
l_attribute4              VARCHAR2(150);
l_attribute5              VARCHAR2(150);
l_attribute6              VARCHAR2(150);
l_attribute7              VARCHAR2(150);
l_attribute8              VARCHAR2(150);
l_attribute9              VARCHAR2(150);
l_attribute10             VARCHAR2(150);
l_attribute11             VARCHAR2(150);
l_attribute12             VARCHAR2(150);
l_attribute13             VARCHAR2(150);
l_attribute14             VARCHAR2(150);
l_attribute15             VARCHAR2(150);
l_pf_item_id              NUMBER;
l_pf_organization_id      NUMBER;
l_price                   NUMBER;
l_currency_code           VARCHAR2(15);
l_code                    VARCHAR2(100);
l_description             VARCHAR2(240);
l_master_enabled_flag     VARCHAR2(1);
x_prod_cat_set_id	      NUMBER;
x_prod_cat_id		      NUMBER;
l_prod_cat_set_id	      NUMBER;
l_prod_cat_id		      NUMBER;
l_prod_cat_not_found      VARCHAR2(1) := 'N';

CURSOR fetch_db_value_cur(p_interest_code_id IN NUMBER) IS SELECT
              master_enabled_flag,
              parent_interest_code_id,
              category_id,
              category_set_id,
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
              pf_item_id,
              pf_organization_id,
              price,
              currency_code,
              code,
              description,
              last_update_date,
              last_updated_by,
              last_update_login,
              product_cat_set_id,
              product_category_id
       FROM  AS_INTEREST_CODES_vl
      WHERE  interest_code_id = p_interest_code_id;

CURSOR validate_interest_type_cur(p_interest_type_id IN NUMBER) IS
       SELECT 1
         FROM AS_INTEREST_TYPES_B
        WHERE INTEREST_TYPE_ID = p_interest_type_id
          AND INTEREST_TYPE_ID IS NOT NULL;

CURSOR validate_parent_int_code_cur(p_parent_interest_code_id IN NUMBER) IS
       SELECT 1
         FROM AS_INTEREST_CODES_B
        WHERE INTEREST_CODE_ID = p_parent_interest_code_id
          AND INTEREST_CODE_ID IS NOT NULL;

CURSOR as_int_codes_vl_cur(p_interest_code_id IN NUMBER, p_code IN VARCHAR2,p_interest_type_id IN NUMBER) IS
	SELECT 1
	  FROM as_interest_codes_vl
	 WHERE interest_code_id <> p_interest_code_id
           AND TRIM(NLS_UPPER(code)) = p_code     ----  -- passing in trimmed value while opening.
	   AND interest_type_id = p_interest_type_id
	   AND parent_interest_code_id IS NULL ;

CURSOR as_int_codes_vl_1_cur(p_interest_code_id IN NUMBER, p_code IN VARCHAR2,p_interest_type_id IN NUMBER,p_parent_interest_code_id IN NUMBER) IS
	SELECT 1
	  FROM as_interest_codes_vl
	 WHERE interest_code_id <> p_interest_code_id
           AND TRIM(NLS_UPPER(code)) = p_code  ----- -- passing in trimmed value while opening.
	   AND interest_type_id = p_interest_type_id
	   AND parent_interest_code_id = p_parent_interest_code_id ;

CURSOR  lock_row_for_update(p_interest_code_id in number) IS
      SELECT   last_update_date
        FROM   as_interest_codes_vl
       WHERE   interest_code_id = p_interest_code_id;

CURSOR prod_category_val_cur(p_prod_cat_set_id IN NUMBER, p_prod_cat_id IN NUMBER) IS
    SELECT 1 FROM ENI_PROD_DEN_HRCHY_PARENTS_V P
    WHERE P.CATEGORY_ID = p_prod_cat_id
    AND P.CATEGORY_SET_ID = p_prod_cat_set_id;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.intc.update_interest_code';

BEGIN

	-- Standard STart of API SavePoint
	SAVEPOINT update_interest_code_PUB;

        FND_MSG_PUB.DELETE_MSG;

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

	   IF (p_interest_code_rec.interest_code_id  = FND_API.G_MISS_NUM)
          OR TRIM(p_interest_code_rec.interest_code_id) IS NULL
          THEN
	   	FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_INT_CODE');
	   	--FND_MESSAGE.SET_TOKEN('INTEREST_CODE',p_interest_code_rec.code);
		FND_MSG_PUB.Add;
	   	RAISE FND_API.G_EXC_ERROR;
	   END IF;

	   IF (p_interest_code_rec.interest_type_id  = FND_API.G_MISS_NUM )
          OR TRIM(p_interest_code_rec.interest_type_id) IS NULL
          THEN
	   	FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_INT_TYPE_ID');
	   	FND_MESSAGE.SET_TOKEN('INTEREST_TYPE_ID',p_interest_code_rec.interest_type_id);
		FND_MSG_PUB.Add;
	   	RAISE FND_API.G_EXC_ERROR;
          ELSE
		OPEN  validate_interest_type_cur(p_interest_code_rec.interest_type_id);
		FETCH validate_interest_type_cur INTO l_count;
                IF validate_interest_type_cur%NOTFOUND
                THEN
                     CLOSE validate_interest_type_cur;
                     RAISE FND_API.G_EXC_ERROR;
                ELSE
                     x_interest_type_id := p_interest_code_rec.interest_type_id;
                END IF;
                CLOSE validate_interest_type_cur;
	   END IF;


	-- Check if the value passed is G_MISS if so then replace it with the
	-- database fetched column

	OPEN fetch_db_value_cur(p_interest_code_rec.interest_code_id) ;
	FETCH fetch_db_value_cur INTO
				  l_master_enabled_flag,
				  l_parent_interest_code_id,
				  l_category_id,
				  l_category_set_id,
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
				  l_attribute15,
				  l_pf_item_id,
				  l_pf_organization_id,
				  l_price,
				  l_currency_code,
				  l_code,
				  l_description,
				  l_last_update_date,
				  l_last_updated_by,
				  l_last_update_login,
				  l_prod_cat_set_id,
				  l_prod_cat_id;

	IF fetch_db_value_cur%NOTFOUND
	THEN
	   CLOSE fetch_db_value_cur;
	   RAISE fnd_api.g_exc_error;
	END IF;
	CLOSE fetch_db_value_cur;


	-- For Who Columns if the value passed is G_miss then default them
	-- else use the passed value

	IF p_interest_code_rec.last_update_date  = FND_API.G_MISS_DATE
	OR TRIM(p_interest_code_rec.last_update_date) IS NULL
	THEN
	   x_last_update_date := SYSDATE;
	ELSE
	   x_last_update_date := p_interest_code_rec.last_update_date;
	END IF;
	IF p_interest_code_rec.last_updated_by  = FND_API.G_MISS_NUM
	OR TRIM(p_interest_code_rec.last_updated_by) IS NULL
	THEN
	   x_last_updated_by := FND_GLOBAL.user_id;
	ELSE
	   x_last_updated_by := p_interest_code_rec.last_updated_by;
	END IF;
	IF p_interest_code_rec.last_update_login  = FND_API.G_MISS_NUM
	OR TRIM(p_interest_code_rec.last_update_login) IS NULL
	THEN
	   x_last_update_login := FND_GLOBAL.login_id;
	ELSE
	   x_last_update_login := p_interest_code_rec.last_update_login;
	END IF;


	-- For all other required and optional columns check to see if the
	-- value is g_miss then replace them with the database fetched column.


	IF p_interest_code_rec.parent_interest_code_id = FND_API.G_MISS_NUM
	THEN
	   x_parent_interest_code_id := l_parent_interest_code_id;
	ELSE
	   -- make sure it is a valid parent_interest_code_id
	   OPEN  validate_parent_int_code_cur(p_interest_code_rec.parent_interest_code_id);
	   FETCH validate_parent_int_code_cur INTO l_count;
	   IF    validate_parent_int_code_cur%NOTFOUND
	   THEN

		  FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_PAR_INT_CODE_ID');
		  FND_MESSAGE.SET_TOKEN('PARENT_INTEREST_CODE_ID',p_interest_code_rec.parent_interest_code_id);
		  FND_MSG_PUB.Add;
			  CLOSE validate_parent_int_code_cur;
			  RAISE FND_API.G_EXC_ERROR;
	   ELSE
		x_parent_interest_code_id := p_interest_code_rec.parent_interest_code_id;
	   END IF;
	   CLOSE validate_parent_int_code_cur;
	END IF;

	IF p_interest_code_rec.master_enabled_flag = FND_API.G_MISS_CHAR
	THEN
	   x_master_enabled_flag := l_master_enabled_flag;
	ELSE
	   -- make sure master enabled flag is valid
		IF p_interest_code_rec.master_enabled_flag NOT IN ('N','Y') THEN
		FND_MESSAGE.SET_NAME ( 'AS' , 'AS_INVALID_MAST_ENAB_FLAG');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
		ELSE
		  x_master_enabled_flag := p_interest_code_rec.master_enabled_flag;
	   END IF;
	END IF;

	-- Check to see if the value passed is G_MISS if so replace the
	-- value with the fetched value from the database.

	IF p_interest_code_rec.code = FND_API.G_MISS_CHAR
	THEN
	   x_code := l_code  ;
	ELSE
	   x_code  := p_interest_code_rec.code ;
	END IF;
	IF p_interest_code_rec.category_id = FND_API.G_MISS_NUM
	THEN
	   x_category_id := l_category_id ;
	ELSE
	   x_category_id := p_interest_code_rec.category_id;
	END IF;
	IF p_interest_code_rec.category_set_id = FND_API.G_MISS_NUM
	THEN
	   x_category_set_id := l_category_set_id ;
	ELSE
	   x_category_set_id := p_interest_code_rec.category_set_id;
	END IF;
	IF p_interest_code_rec.attribute_category = FND_API.G_MISS_CHAR
	THEN
	   x_attribute_category := l_attribute_category ;
	ELSE
	   x_attribute_category := p_interest_code_rec.attribute_category ;
	END IF;
	IF p_interest_code_rec.attribute1 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute1 := l_attribute1 ;
	ELSE
	   x_attribute1 := p_interest_code_rec.attribute1;
	END IF;
	IF p_interest_code_rec.attribute2 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute2 := l_attribute2 ;
	ELSE
	   x_attribute2 := p_interest_code_rec.attribute2;
	END IF;
	IF p_interest_code_rec.attribute3 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute3 := l_attribute3 ;
	ELSE
	   x_attribute3 := p_interest_code_rec.attribute3;
	END IF;
	IF p_interest_code_rec.attribute4 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute4 := l_attribute4 ;
	ELSE
	   x_attribute4 := p_interest_code_rec.attribute4;
	END IF;
	IF p_interest_code_rec.attribute5 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute5 := l_attribute5 ;
	ELSE
	   x_attribute5 := p_interest_code_rec.attribute5;
	END IF;
	IF p_interest_code_rec.attribute6 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute6 := l_attribute6 ;
	ELSE
	   x_attribute6 := p_interest_code_rec.attribute6;
	END IF;
	IF p_interest_code_rec.attribute7 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute7 := l_attribute7 ;
	ELSE
	   x_attribute7 := p_interest_code_rec.attribute7;
	END IF;
	IF p_interest_code_rec.attribute8 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute8 := l_attribute8 ;
	ELSE
	   x_attribute8 := p_interest_code_rec.attribute8;
	END IF;
	IF p_interest_code_rec.attribute9 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute9 := l_attribute9 ;
	ELSE
	   x_attribute9 := p_interest_code_rec.attribute9;
	END IF;
	IF p_interest_code_rec.attribute10 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute10 := l_attribute10 ;
	ELSE
	   x_attribute10 := p_interest_code_rec.attribute10;
	END IF;
	IF p_interest_code_rec.attribute11 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute11 := l_attribute11 ;
	ELSE
	   x_attribute11 := p_interest_code_rec.attribute11;
	END IF;
	IF p_interest_code_rec.attribute12 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute12 := l_attribute12 ;
	ELSE
	   x_attribute12 := p_interest_code_rec.attribute12;
	END IF;
	IF p_interest_code_rec.attribute13 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute13 := l_attribute13 ;
	ELSE
	   x_attribute13 := p_interest_code_rec.attribute13;
	END IF;
	IF p_interest_code_rec.attribute14 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute14 := l_attribute14 ;
	ELSE
	   x_attribute14 := p_interest_code_rec.attribute14;
	END IF;
	IF p_interest_code_rec.attribute15 = FND_API.G_MISS_CHAR
	THEN
	   x_attribute15 := l_attribute15 ;
	ELSE
	   x_attribute15 := p_interest_code_rec.attribute15;
	END IF;
	IF p_interest_code_rec.pf_item_id = FND_API.G_MISS_NUM
	THEN
	   x_pf_item_id := l_pf_item_id ;
	ELSE
	   x_pf_item_id := p_interest_code_rec.pf_item_id ;
	END IF;
	IF p_interest_code_rec.pf_organization_id = FND_API.G_MISS_NUM
	THEN
	   x_pf_organization_id := l_pf_organization_id ;
	ELSE
	   x_pf_organization_id := p_interest_code_rec.pf_organization_id ;
	END IF;
	IF       p_interest_code_rec.price = FND_API.G_MISS_NUM
	THEN
	   x_price := l_price ;
	ELSE
	   x_price  := p_interest_code_rec.price ;
	END IF;
	IF p_interest_code_rec.currency_code = FND_API.G_MISS_CHAR
	THEN
	   x_currency_code := l_currency_code   ;
	ELSE
	   x_currency_code  := p_interest_code_rec.currency_code ;
	END IF;
	IF p_interest_code_rec.description = FND_API.G_MISS_CHAR
	THEN
	   x_description := l_description;
	ELSE
	   x_description  := p_interest_code_rec.description ;
	END IF;

	IF p_interest_code_rec.prod_cat_set_id = FND_API.G_MISS_NUM THEN
		x_prod_cat_set_id :=  l_prod_cat_set_id;
	ELSE
		x_prod_cat_set_id := p_interest_code_rec.prod_cat_set_id;
	END IF;

	IF p_interest_code_rec.prod_cat_id = FND_API.G_MISS_NUM THEN
		x_prod_cat_id :=  l_prod_cat_id;
	ELSE
		x_prod_cat_id := p_interest_code_rec.prod_cat_id;
	END IF;

	IF x_parent_interest_code_id  IS NULL THEN

	-- If parent interest code id is null, then the combination of
	--  interest_type_id and code must be unique

	   OPEN  as_int_codes_vl_cur(p_interest_code_rec.interest_code_id,TRIM(NLS_UPPER(x_code)),p_interest_code_rec.interest_type_id);
	   FETCH as_int_codes_vl_cur INTO l_count_ids;
	   IF    as_int_codes_vl_cur%FOUND
	   THEN
		   FND_MESSAGE.SET_NAME('ASF', 'ASF_ADM_DUPLICATE');
		   FND_MSG_PUB.Add;
			   CLOSE as_int_codes_vl_cur;
			   RAISE FND_API.G_EXC_ERROR;
	   END IF;
	   CLOSE as_int_codes_vl_cur;

	ELSE

	-- If parent interest code id is Not null, then the
	-- combination of interest_type_id,parent interest code id
	-- and code must be unique

	   OPEN  as_int_codes_vl_1_cur(p_interest_code_rec.interest_code_id,TRIM(NLS_UPPER(x_code)),p_interest_code_rec.interest_type_id,x_parent_interest_code_id);
	   FETCH as_int_codes_vl_1_cur INTO l_count_ids;

	   IF    as_int_codes_vl_1_cur%FOUND
	   THEN
		   FND_MESSAGE.SET_NAME('ASF', 'ASF_ADM_DUPLICATE');
		   FND_MSG_PUB.Add;
			   CLOSE as_int_codes_vl_1_cur;
			   RAISE FND_API.G_EXC_ERROR;
	   END IF;
	   CLOSE as_int_codes_vl_1_cur;
	END IF;

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

   OPEN   lock_row_for_update(TRIM(NLS_UPPER(p_interest_code_rec.interest_code_id)));
   FETCH  lock_row_for_update INTO  l_current_last_update_date;
   IF     lock_row_for_update%NOTFOUND
   THEN
          CLOSE  lock_row_for_update;
          RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF l_last_update_date <> l_current_last_update_date
   THEN
          fnd_message.set_name('AS', 'API_RECORD_CHANGED');
          FND_MESSAGE.Set_Token('INFO', 'interest_code', FALSE); -- ??
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
   END IF;

-- Update the Row using the API
	  as_interest_codes_pkg.update_row(
				p_interest_code_rec.interest_code_id,
				p_interest_code_rec.interest_type_id,
				x_master_enabled_flag,
				x_parent_interest_code_id,
				x_category_id,
				x_category_set_id,
				x_attribute_category,
				x_attribute1,
				x_attribute2,
				x_attribute3,
				x_attribute4,
				x_attribute5,
				x_attribute6,
				x_attribute7,
				x_attribute8,
				x_attribute9,
				x_attribute10,
				x_attribute11,
				x_attribute12,
				x_attribute13,
				x_attribute14,
				x_attribute15,
				x_pf_item_id,
				x_pf_organization_id,
				x_price,
				x_currency_code,
				x_code,
				x_description,
				x_last_update_date,
				x_last_updated_by,
				x_last_update_login,
				x_prod_cat_set_id,
				x_prod_cat_id
				);

      -- Close Cursors
      CLOSE  lock_row_for_update ;

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
 END update_interest_code;
END as_interest_codes_pub;


/
