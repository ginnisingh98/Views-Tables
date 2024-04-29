--------------------------------------------------------
--  DDL for Package Body BOM_ALTERNATE_DESIGNATORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_ALTERNATE_DESIGNATORS_PKG" as
/* $Header: bompbadb.pls 120.6 2007/03/29 05:41:21 dikrishn ship $ */
               ------------------------------------
               -- Global Variables and Constants --
               ------------------------------------

   g_pkg_name                CONSTANT VARCHAR2(30) := 'BOM_ALTERNATE_DESIGNATORS_PKG';
   g_current_user_id         NUMBER := FND_GLOBAL.User_Id;
   g_current_login_id        NUMBER := FND_GLOBAL.Login_Id;

  TYPE Bom_Alt_Desig_Rec IS RECORD
  ( -- Columns from Bom_Alternate_Designators table
    Alternate_Designator_Code   VARCHAR2(10)
   , Organization_id    NUMBER
   , LAST_UPDATE_DATE   DATE
   , LAST_UPDATED_BY    NUMBER
   , CREATION_DATE	DATE
   , CREATED_BY		NUMBER
   , LAST_UPDATE_LOGIN	NUMBER
   , DESCRIPTION	VARCHAR2(240)
   , DISABLE_DATE	DATE
   , ATTRIBUTE_CATEGORY VARCHAR2(30)
   , ATTRIBUTE1		VARCHAR2(150)
   , ATTRIBUTE2		VARCHAR2(150)
   , ATTRIBUTE3		VARCHAR2(150)
   , ATTRIBUTE4		VARCHAR2(150)
   , ATTRIBUTE5		VARCHAR2(150)
   , ATTRIBUTE6		VARCHAR2(150)
   , ATTRIBUTE7		VARCHAR2(150)
   , ATTRIBUTE8		VARCHAR2(150)
   , ATTRIBUTE9		VARCHAR2(150)
   , ATTRIBUTE10	VARCHAR2(150)
   , ATTRIBUTE11	VARCHAR2(150)
   , ATTRIBUTE12	VARCHAR2(150)
   , ATTRIBUTE13	VARCHAR2(150)
   , ATTRIBUTE14	VARCHAR2(150)
   , ATTRIBUTE15	VARCHAR2(150)
   , REQUEST_ID		NUMBER
   , PROGRAM_APPLICATION_ID NUMBER
   , PROGRAM_ID		NUMBER
   , PROGRAM_UPDATE_DATE DATE
   , STRUCTURE_TYPE_ID	NUMBER
   , IS_PREFERRED      VARCHAR2(1)
--- Extra attributes added for internal usage
   , DISPLAY_NAME	VARCHAR2(80)
   , Alt_Desig_Code_Old	VARCHAR2(10)
   , api_version	NUMBER
  );

		    --------------------------
                    -- Private Package APIs --
                    --------------------------

Function Get_Preferred_Name (structure_type_id Number, alt_des_code varchar2) return VARCHAR2;
PROCEDURE	Insert_Row (p_alt_desig_rec   IN Bom_Alt_Desig_Rec
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE	Update_Row (p_alt_desig_rec   IN Bom_Alt_Desig_Rec
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


  ----------------------------------------------------------------------
  FUNCTION Check_Unique(X_Organization_Id NUMBER,
                         X_Alt_Desig_Code VARCHAR2) RETURN BOOLEAN IS
  BEGIN
     Check_Unique(X_Organization_Id, X_Alt_Desig_Code);
     RETURN FALSE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN TRUE;
  END Check_Unique;


  FUNCTION Check_References(X_Organization_Id NUMBER,
                         X_Alt_Desig_Code VARCHAR2) RETURN BOOLEAN IS
    CURSOR c_check_bom_rtg_cost
	 IS
	 SELECT 1
	 FROM BOM_BILL_OF_MATERIALS
	 WHERE BOM_BILL_OF_MATERIALS.Alternate_Bom_Designator =
	       X_Alt_Desig_Code
	 UNION
	 SELECT 1
	 FROM BOM_OPERATIONAL_ROUTINGS
	 WHERE BOM_OPERATIONAL_ROUTINGS.ALTERNATE_ROUTING_DESIGNATOR =
	       X_Alt_Desig_Code
	 UNION
         SELECT 1
	 FROM CST_COST_TYPES
	 WHERE CST_COST_TYPES.ALTERNATE_BOM_DESIGNATOR =
	       X_Alt_Desig_Code;
    cur_bom_rtg_cost c_check_bom_rtg_cost%ROWTYPE;
  BEGIN
      IF X_Organization_Id IS NOT NULL THEN
        Check_References(X_Organization_Id, X_Alt_Desig_Code);
        RETURN FALSE;
      ELSIF X_Organization_Id IS NULL THEN
     	   OPEN c_check_bom_rtg_cost;
	   FETCH c_check_bom_rtg_cost INTO cur_bom_rtg_cost;
	   IF c_check_bom_rtg_cost%NOTFOUND THEN
	    RETURN false; --TRUE;
	   END IF;
	   IF c_check_bom_rtg_cost%ISOPEN THEN
	    close c_check_bom_rtg_cost;
	   END IF;
	   RETURN TRUE; --FALSE;
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN TRUE;
  END Check_References;

  --------------------------------------------------------------------------------

  PROCEDURE Check_Unique(X_Organization_Id NUMBER,
                         X_Alternate_Designator_Code VARCHAR2) IS
    DUMMY NUMBER;
  BEGIN
    SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
      (SELECT 1 FROM BOM_ALTERNATE_DESIGNATORS
       WHERE Organization_Id = X_Organization_Id
       AND Alternate_Designator_Code  = X_Alternate_Designator_Code
       );

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('BOM', 'BOM_ALREADY_EXISTS');
        FND_MESSAGE.SET_TOKEN('ENTITY1', 'THIS_CAP', TRUE);
        FND_MESSAGE.SET_TOKEN('ENTITY2', 'ALTERNATE_CAP', TRUE);
        APP_EXCEPTION.RAISE_EXCEPTION;
  END Check_Unique;


  PROCEDURE Check_References(X_Organization_Id NUMBER,
  			     X_Alternate_Designator_Code VARCHAR2) IS
    DUMMY 		NUMBER;
    MESSAGE_NAME	VARCHAR2(80);
  BEGIN
    SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
      (SELECT 1 FROM BOM_BILL_OF_MATERIALS
       WHERE BOM_BILL_OF_MATERIALS.Organization_ID = X_Organization_Id
	 AND BOM_BILL_OF_MATERIALS.Alternate_Bom_Designator =
	     X_Alternate_Designator_Code
       );

    SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
      (SELECT 1 FROM BOM_OPERATIONAL_ROUTINGS
       WHERE BOM_OPERATIONAL_ROUTINGS.Organization_Id = X_Organization_Id
       AND BOM_OPERATIONAL_ROUTINGS.ALTERNATE_ROUTING_DESIGNATOR =
       X_Alternate_Designator_Code
      );

    SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
      (SELECT 1 FROM CST_COST_TYPES
       WHERE CST_COST_TYPES.Organization_Id = X_Organization_Id
	 AND CST_COST_TYPES.ALTERNATE_BOM_DESIGNATOR =
	     X_Alternate_Designator_Code
       );

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('BOM', 'BOM_ALT_IN_USE');
        FND_MESSAGE.SET_TOKEN('ENTITY', X_Alternate_Designator_Code);
        APP_EXCEPTION.RAISE_EXCEPTION;
END Check_References;

PROCEDURE Insert_Row ( --- not used, retaining for the moment
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code	        IN   VARCHAR2
       ,p_organization_id               IN   NUMBER
       ,p_description                   IN   VARCHAR2
       ,p_disable_date                  IN   DATE
       ,p_structure_type_id             IN   NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
  BEGIN
    Insert_Row (
        p_api_version           => p_api_version
       ,p_alt_desig_code        => p_alt_desig_code
       ,p_organization_id       => p_organization_id
       ,p_display_name          => p_alt_desig_code
       ,p_description           => p_description
       ,p_disable_date          => p_disable_date
       ,p_structure_type_id     => p_structure_type_id
       ,p_is_preferred          => null
       ,x_return_status         => x_return_status
       ,x_errorcode             => x_errorcode
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
    );

END Insert_row;

----------------------------------------------------------------------

PROCEDURE Insert_Row ( --- Called by OA Pages
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code                IN   VARCHAR2
       ,p_organization_id               IN   NUMBER
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_disable_date                  IN   DATE
       ,p_structure_type_id             IN   NUMBER
       ,p_is_preferred			IN  VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_api_version            CONSTANT NUMBER := 1.0;
    l_Sysdate                DATE := Sysdate;
    rec                      Bom_Alt_Desig_Rec;
  BEGIN
	rec.Alternate_Designator_Code := p_alt_desig_code;
	rec.Organization_id           := p_organization_id;
	rec.LAST_UPDATE_DATE          := l_Sysdate;
	rec.LAST_UPDATED_BY           := g_current_user_id;
	rec.CREATION_DATE             := l_Sysdate;
	rec.CREATED_BY                := g_current_user_id;
	rec.LAST_UPDATE_LOGIN         := g_current_login_id;
	rec.DESCRIPTION               := p_description;
	rec.DISABLE_DATE              := p_disable_date;
	rec.ATTRIBUTE_CATEGORY        := NULL;
	rec.ATTRIBUTE1                := NULL;
	rec.ATTRIBUTE2                := NULL;
	rec.ATTRIBUTE3                := NULL;
	rec.ATTRIBUTE4                := NULL;
	rec.ATTRIBUTE5                := NULL;
	rec.ATTRIBUTE6                := NULL;
	rec.ATTRIBUTE7                := NULL;
	rec.ATTRIBUTE8                := NULL;
	rec.ATTRIBUTE9                := NULL;
	rec.ATTRIBUTE10               := NULL;
	rec.ATTRIBUTE11               := NULL;
	rec.ATTRIBUTE12               := NULL;
	rec.ATTRIBUTE13               := NULL;
	rec.ATTRIBUTE14               := NULL;
	rec.ATTRIBUTE15               := NULL;
	rec.REQUEST_ID                := NULL;
	rec.PROGRAM_APPLICATION_ID    := NULL;
	rec.PROGRAM_ID                := NULL;
	rec.PROGRAM_UPDATE_DATE       := NULL;
	rec.STRUCTURE_TYPE_ID         := p_structure_type_id;
	rec.IS_PREFERRED 	      := p_is_preferred;
	rec.DISPLAY_NAME              := p_display_name;
	rec.Alt_Desig_Code_Old        := NULL;
	rec.api_version               := l_api_version;

	Insert_Row (p_alt_desig_rec   => rec,
	x_return_status => x_return_status,
	x_errorcode => x_errorcode,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

END Insert_row;

----------------------------------------------------------------------

PROCEDURE Update_Row ( --- not used, retaining for the moment
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code_old		IN   VARCHAR2
       ,p_organization_id               IN   NUMBER
       ,p_alt_desig_code_new		IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_disable_date                  IN   DATE
       ,p_structure_type_id             IN   NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
  BEGIN

    Update_Row (
        p_api_version           => p_api_version
       ,p_alt_desig_code_old    => p_alt_desig_code_old
       ,p_organization_id       => p_organization_id
       ,p_alt_desig_code_new    => p_alt_desig_code_new
       ,p_display_name_new      => p_alt_desig_code_new
       ,p_description           => p_description
       ,p_disable_date          => p_disable_date
       ,p_structure_type_id     => p_structure_type_id
       ,p_is_preferred		=> null
       ,x_return_status         => x_return_status
       ,x_errorcode             => x_errorcode
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
    );
END Update_Row;

----------------------------------------------------------------------

PROCEDURE Update_Row ( --- Called by OA Pages
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code_old            IN   VARCHAR2
       ,p_organization_id               IN   NUMBER
       ,p_alt_desig_code_new            IN   VARCHAR2
       ,p_display_name_new              IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_disable_date                  IN   DATE
       ,p_structure_type_id             IN   NUMBER
       ,p_is_preferred 			IN   VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_api_version            CONSTANT NUMBER := 1.0;
    l_Sysdate                DATE := Sysdate;
    rec                      Bom_Alt_Desig_Rec;
  BEGIN

	rec.Alternate_Designator_Code := p_alt_desig_code_new;
	rec.Organization_id           := p_organization_id;
	rec.LAST_UPDATE_DATE          := l_Sysdate;
	rec.LAST_UPDATED_BY           := g_current_user_id;
	rec.CREATION_DATE             := NULL;
	rec.CREATED_BY                := NULL;
	rec.LAST_UPDATE_LOGIN         := g_current_login_id;
	rec.DESCRIPTION               := p_description;
	rec.DISABLE_DATE              := p_disable_date;
	rec.ATTRIBUTE_CATEGORY        := NULL;
	rec.ATTRIBUTE1                := NULL;
	rec.ATTRIBUTE2                := NULL;
	rec.ATTRIBUTE3                := NULL;
	rec.ATTRIBUTE4                := NULL;
	rec.ATTRIBUTE5                := NULL;
	rec.ATTRIBUTE6                := NULL;
	rec.ATTRIBUTE7                := NULL;
	rec.ATTRIBUTE8                := NULL;
	rec.ATTRIBUTE9                := NULL;
	rec.ATTRIBUTE10               := NULL;
	rec.ATTRIBUTE11               := NULL;
	rec.ATTRIBUTE12               := NULL;
	rec.ATTRIBUTE13               := NULL;
	rec.ATTRIBUTE14               := NULL;
	rec.ATTRIBUTE15               := NULL;
	rec.REQUEST_ID                := NULL;
	rec.PROGRAM_APPLICATION_ID    := NULL;
	rec.PROGRAM_ID                := NULL;
	rec.PROGRAM_UPDATE_DATE       := NULL;
	rec.STRUCTURE_TYPE_ID         := p_structure_type_id;
	rec.IS_PREFERRED	      := p_is_preferred;
	rec.DISPLAY_NAME              := p_display_name_new;
	rec.Alt_Desig_Code_Old        := p_alt_desig_code_old;
	rec.api_version               := l_api_version;

	Update_Row (p_alt_desig_rec   => rec
       ,x_return_status => x_return_status
       ,x_errorcode => x_errorcode
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data);

END Update_Row;

----------------------------------------------------------------------

PROCEDURE Delete_Row (
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code                IN   VARCHAR2
       ,p_from_struct_alt_page          IN   VARCHAR2 DEFAULT 'N'
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Alternate_In_All_Org';
    l_api_version            CONSTANT NUMBER := 1.0;
  BEGIN

    -- Standard start of API savepoint
    SAVEPOINT Delete_Alternate_PUB;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF NOT Check_References(NULL, p_alt_desig_code) THEN
      -- Added for Bug Fix : 3045566
      IF p_from_struct_alt_page = 'N' THEN
        DELETE FROM BOM_ALTERNATE_DESIGNATORS
          WHERE ALTERNATE_DESIGNATOR_CODE = p_alt_desig_code;

	DELETE FROM BOM_ALTERNATE_DESIGNATORS_TL
	  WHERE ALTERNATE_DESIGNATOR_CODE = p_alt_desig_code;

      ELSE
        UPDATE BOM_ALTERNATE_DESIGNATORS SET structure_type_id =
          (SELECT structure_type_id
           FROM bom_structure_types_b
           WHERE parent_structure_type_id IS NULL)
        WHERE ALTERNATE_DESIGNATOR_CODE = p_alt_desig_code ;
      END IF;

      -- End of bug fix

      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
        FND_MESSAGE.SET_NAME('BOM', 'BOM_ALT_IN_USE');
        FND_MESSAGE.SET_TOKEN('ENTITY', p_alt_desig_code);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := FND_MESSAGE.GET;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO Delete_Alternate_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      x_msg_data := FND_MESSAGE.GET;

END Delete_Row;

----------------------------------------------------------------------

PROCEDURE Delete_Row (
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code		IN   VARCHAR2
       ,p_organization_id		IN   NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Alternate_For_Org';
    l_api_version            CONSTANT NUMBER := 1.0;
  BEGIN

    -- Standard start of API savepoint
    SAVEPOINT Delete_Alternate_PUB;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

     IF NOT Check_References(p_organization_id, p_alt_desig_code) THEN
	    DELETE FROM BOM_ALTERNATE_DESIGNATORS
	    WHERE ALTERNATE_DESIGNATOR_CODE = p_alt_desig_code
	    AND ORGANIZATION_ID = p_organization_id;

	    DELETE FROM BOM_ALTERNATE_DESIGNATORS_TL
	    WHERE ALTERNATE_DESIGNATOR_CODE = p_alt_desig_code
	    and ORGANIZATION_ID = p_organization_id;

	    commit;
	    x_return_status := FND_API.G_RET_STS_SUCCESS;
     ELSE
        FND_MESSAGE.SET_NAME('BOM', 'BOM_ALT_IN_USE');
        FND_MESSAGE.SET_TOKEN('ENTITY', p_alt_desig_code);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := FND_MESSAGE.GET;
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO Delete_Alternate_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      x_msg_data := FND_MESSAGE.GET;

END Delete_Row;

PROCEDURE Create_Association(
        p_api_version                   IN NUMBER
--       ,p_organization_id               IN NUMBER
       ,p_alternate_designator_code     IN VARCHAR2
       ,p_structure_type_id             IN NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Association';
    l_api_version            CONSTANT NUMBER := 1.0;
BEGIN
   -- Standard start of API Savepoint
   SAVEPOINT Create_Association;

   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   UPDATE BOM_ALTERNATE_DESIGNATORS
     SET structure_type_id = p_structure_type_id
     WHERE alternate_designator_code = p_alternate_designator_code;
--     AND   organization_id = p_organization_id;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS
 THEN
   ROLLBACK TO Create_Association;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MESSAGE.SET_NAME('BOM', 'BOM_UPDATE_FAILED');
   x_msg_data := FND_MESSAGE.GET;
--   x_msg_data := 'Executing - '||G_PKG_NAME ||'.'||l_api_name||' '||SQLERRM;

END Create_Association;
-- -------------------------------
-- Description : Added the following wrapper function
--               for the Original Check_References Function
--               since due to limitation of CallableStatement not
--                able to return values of BOOLEAN type
--    Bug No :  2826480
-- ------
  FUNCTION Check_References_wrapper(X_Organization_Id NUMBER,
    			     X_Alternate_Designator_Code VARCHAR2)
   RETURN VARCHAR2 IS
    l_result BOOLEAN;
  BEGIN
    l_result := Check_References(x_Organization_id => null,
                            X_Alt_Desig_Code  => x_Alternate_Designator_code);
    IF l_result THEN
     RETURN 'T';
    ELSE
     RETURN 'F';
    END IF;
  END Check_References_wrapper;

-- ----------------------------

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM BOM_ALTERNATE_DESIGNATORS_TL T
  WHERE not exists
    (SELECT NULL
    FROM BOM_ALTERNATE_DESIGNATORS B
    WHERE B.ALTERNATE_DESIGNATOR_CODE = T.ALTERNATE_DESIGNATOR_CODE
    and B.ORGANIZATION_ID = T.ORGANIZATION_ID
    );

  UPDATE BOM_ALTERNATE_DESIGNATORS_TL T SET (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (SELECT
      B.DISPLAY_NAME,
      B.DESCRIPTION
    FROM BOM_ALTERNATE_DESIGNATORS_TL B
    WHERE B.ALTERNATE_DESIGNATOR_CODE = T.ALTERNATE_DESIGNATOR_CODE
    AND B.ORGANIZATION_ID = T.ORGANIZATION_ID
    AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.ALTERNATE_DESIGNATOR_CODE,
      T.ORGANIZATION_ID,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.ALTERNATE_DESIGNATOR_CODE,
      SUBT.ORGANIZATION_ID,
      SUBT.LANGUAGE
    FROM BOM_ALTERNATE_DESIGNATORS_TL SUBB, BOM_ALTERNATE_DESIGNATORS_TL SUBT
    WHERE SUBB.ALTERNATE_DESIGNATOR_CODE = SUBT.ALTERNATE_DESIGNATOR_CODE
    AND SUBB.ORGANIZATION_ID = SUBT.ORGANIZATION_ID
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      OR (SUBB.DISPLAY_NAME IS NULL AND SUBT.DISPLAY_NAME IS NOT NULL)
      OR (SUBB.DISPLAY_NAME IS NOT NULL AND SUBT.DISPLAY_NAME IS NULL)
      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
  ));

  INSERT INTO BOM_ALTERNATE_DESIGNATORS_TL (
    ALTERNATE_DESIGNATOR_CODE,
    ORGANIZATION_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT /*+ ORDERED */
    B.ALTERNATE_DESIGNATOR_CODE,
    B.ORGANIZATION_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM BOM_ALTERNATE_DESIGNATORS_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM BOM_ALTERNATE_DESIGNATORS_TL T
    WHERE T.ALTERNATE_DESIGNATOR_CODE = B.ALTERNATE_DESIGNATOR_CODE
    AND T.ORGANIZATION_ID = B.ORGANIZATION_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);

END ADD_LANGUAGE;


PROCEDURE Insert_Row ( --- Called by form BOMFDBAD.fmb
	P_ALTERNATE_DESIGNATOR_CODE in VARCHAR2,
	P_ORGANIZATION_ID in NUMBER,
	P_STRUCTURE_TYPE_ID in NUMBER,
	P_DISABLE_DATE in DATE,
	P_ATTRIBUTE_CATEGORY in VARCHAR2,
	P_ATTRIBUTE1 in VARCHAR2,
	P_ATTRIBUTE2 in VARCHAR2,
	P_ATTRIBUTE3 in VARCHAR2,
	P_ATTRIBUTE4 in VARCHAR2,
	P_ATTRIBUTE5 in VARCHAR2,
	P_ATTRIBUTE6 in VARCHAR2,
	P_ATTRIBUTE7 in VARCHAR2,
	P_ATTRIBUTE8 in VARCHAR2,
	P_ATTRIBUTE9 in VARCHAR2,
	P_ATTRIBUTE10 in VARCHAR2,
	P_ATTRIBUTE11 in VARCHAR2,
	P_ATTRIBUTE12 in VARCHAR2,
	P_ATTRIBUTE13 in VARCHAR2,
	P_ATTRIBUTE14 in VARCHAR2,
	P_ATTRIBUTE15 in VARCHAR2,
	P_REQUEST_ID in NUMBER,
	P_DISPLAY_NAME in VARCHAR2,
	P_DESCRIPTION in VARCHAR2,
	P_CREATION_DATE in DATE,
	P_CREATED_BY in NUMBER,
	P_LAST_UPDATE_DATE in DATE,
	P_LAST_UPDATED_BY in NUMBER,
	P_LAST_UPDATE_LOGIN in NUMBER
) IS
    l_api_version            CONSTANT NUMBER := 1.0;
    x_return_status		VARCHAR2(10);
    x_errorcode			NUMBER;
    x_msg_count			NUMBER;
    x_msg_data			VARCHAR2(1000);
    rec                      Bom_Alt_Desig_Rec;
BEGIN

	rec.Alternate_Designator_Code := P_ALTERNATE_DESIGNATOR_CODE;
	rec.Organization_id           := P_ORGANIZATION_ID;
	rec.LAST_UPDATE_DATE          := P_LAST_UPDATE_DATE;
	rec.LAST_UPDATED_BY           := P_LAST_UPDATED_BY;
	rec.CREATION_DATE             := P_CREATION_DATE;
	rec.CREATED_BY                := P_CREATED_BY;
	rec.LAST_UPDATE_LOGIN         := P_LAST_UPDATE_LOGIN;
	rec.DESCRIPTION               := P_DESCRIPTION;
	rec.DISABLE_DATE              := P_DISABLE_DATE;
	rec.ATTRIBUTE_CATEGORY        := P_ATTRIBUTE_CATEGORY;
	rec.ATTRIBUTE1                := P_ATTRIBUTE1;
	rec.ATTRIBUTE2                := P_ATTRIBUTE2;
	rec.ATTRIBUTE3                := P_ATTRIBUTE3;
	rec.ATTRIBUTE4                := P_ATTRIBUTE4;
	rec.ATTRIBUTE5                := P_ATTRIBUTE5;
	rec.ATTRIBUTE6                := P_ATTRIBUTE6;
	rec.ATTRIBUTE7                := P_ATTRIBUTE7;
	rec.ATTRIBUTE8                := P_ATTRIBUTE8;
	rec.ATTRIBUTE9                := P_ATTRIBUTE9;
	rec.ATTRIBUTE10               := P_ATTRIBUTE10;
	rec.ATTRIBUTE11               := P_ATTRIBUTE11;
	rec.ATTRIBUTE12               := P_ATTRIBUTE12;
	rec.ATTRIBUTE13               := P_ATTRIBUTE13;
	rec.ATTRIBUTE14               := P_ATTRIBUTE14;
	rec.ATTRIBUTE15               := P_ATTRIBUTE15;
	rec.REQUEST_ID                := P_REQUEST_ID;
	rec.PROGRAM_APPLICATION_ID    := NULL;
	rec.PROGRAM_ID                := NULL;
	rec.PROGRAM_UPDATE_DATE       := NULL;
	rec.STRUCTURE_TYPE_ID         := P_STRUCTURE_TYPE_ID;
	rec.DISPLAY_NAME              := P_DISPLAY_NAME;
	rec.Alt_Desig_Code_Old        := NULL;
	rec.api_version               := l_api_version;

	Insert_Row (p_alt_desig_rec   => rec,
	x_return_status               => x_return_status,
	x_errorcode                   => x_errorcode,
	x_msg_count                   => x_msg_count,
	x_msg_data                    => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		-- Write exception handling specific to forms using the returned error messages
		NULL;
	END IF;
END Insert_Row;


PROCEDURE Insert_Row (
	p_alt_desig_rec                 IN Bom_Alt_Desig_Rec
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Alternate';
    l_api_version            CONSTANT NUMBER := 1.0;
--    l_object_id              NUMBER;
--    l_Sysdate                DATE := Sysdate;
    l_structure_type_id      NUMBER;
   old_preferred_name            varchar2(10);

  BEGIN

    -- Standard start of API savepoint
    SAVEPOINT Create_Alternate_PUB;

    IF NOT FND_API.Compatible_API_Call (l_api_version, p_alt_desig_rec.api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF p_alt_desig_rec.ORGANIZATION_ID IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF p_alt_desig_rec.STRUCTURE_TYPE_ID = -1 THEN
       l_structure_type_id := NULL;
    ELSE
       l_structure_type_id := p_alt_desig_rec.structure_type_id;
    END IF;

-- when the preferred structure name is set as current structure name
-- and there exists another preferred structure name already
-- reset that value
         old_preferred_name := Get_Preferred_Name(p_alt_desig_rec.structure_type_id,  p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE);
       if(p_alt_desig_rec.is_preferred = 'Y' and
          old_preferred_name <> p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE)
        then
          update bom_alternate_designators
             set is_preferred ='N'
          where
            alternate_designator_code =old_preferred_name;
        end if;


    IF NOT Check_Unique(p_alt_desig_rec.ORGANIZATION_ID, p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE) THEN
	    INSERT INTO BOM_ALTERNATE_DESIGNATORS
	    (
		ALTERNATE_DESIGNATOR_CODE
	       ,ORGANIZATION_ID
	       ,DESCRIPTION
	       ,DISABLE_DATE
	       ,STRUCTURE_TYPE_ID
	       ,ATTRIBUTE_CATEGORY
	       ,ATTRIBUTE1
	       ,ATTRIBUTE2
	       ,ATTRIBUTE3
	       ,ATTRIBUTE4
	       ,ATTRIBUTE5
	       ,ATTRIBUTE6
	       ,ATTRIBUTE7
	       ,ATTRIBUTE8
	       ,ATTRIBUTE9
	       ,ATTRIBUTE10
	       ,ATTRIBUTE11
	       ,ATTRIBUTE12
	       ,ATTRIBUTE13
	       ,ATTRIBUTE14
	       ,ATTRIBUTE15
	       ,REQUEST_ID
	       ,CREATION_DATE
	       ,CREATED_BY
	       ,LAST_UPDATE_DATE
	       ,LAST_UPDATED_BY
	       ,LAST_UPDATE_LOGIN
	       ,PROGRAM_APPLICATION_ID
	       ,PROGRAM_ID
	       ,PROGRAM_UPDATE_DATE
               , IS_PREFERRED
	    )
	    VALUES
	    (
		p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE
	       ,p_alt_desig_rec.ORGANIZATION_ID
	       ,p_alt_desig_rec.DESCRIPTION
	       ,p_alt_desig_rec.DISABLE_DATE
	       ,l_structure_type_id
	       ,p_alt_desig_rec.ATTRIBUTE_CATEGORY
	       ,p_alt_desig_rec.ATTRIBUTE1
	       ,p_alt_desig_rec.ATTRIBUTE2
	       ,p_alt_desig_rec.ATTRIBUTE3
	       ,p_alt_desig_rec.ATTRIBUTE4
	       ,p_alt_desig_rec.ATTRIBUTE5
	       ,p_alt_desig_rec.ATTRIBUTE6
	       ,p_alt_desig_rec.ATTRIBUTE7
	       ,p_alt_desig_rec.ATTRIBUTE8
	       ,p_alt_desig_rec.ATTRIBUTE9
	       ,p_alt_desig_rec.ATTRIBUTE10
	       ,p_alt_desig_rec.ATTRIBUTE11
	       ,p_alt_desig_rec.ATTRIBUTE12
	       ,p_alt_desig_rec.ATTRIBUTE13
	       ,p_alt_desig_rec.ATTRIBUTE14
	       ,p_alt_desig_rec.ATTRIBUTE15
	       ,p_alt_desig_rec.REQUEST_ID
	       ,p_alt_desig_rec.CREATION_DATE
	       ,p_alt_desig_rec.CREATED_BY
	       ,p_alt_desig_rec.LAST_UPDATE_DATE
	       ,p_alt_desig_rec.LAST_UPDATED_BY
	       ,p_alt_desig_rec.LAST_UPDATE_LOGIN
	       ,p_alt_desig_rec.PROGRAM_APPLICATION_ID
	       ,p_alt_desig_rec.PROGRAM_ID
	       ,p_alt_desig_rec.PROGRAM_UPDATE_DATE
	       ,p_alt_desig_rec.IS_PREFERRED
	    );

--- Added for MLS enabling of Bom_Alternate_Designators table
	    insert into BOM_ALTERNATE_DESIGNATORS_TL (
	        ALTERNATE_DESIGNATOR_CODE,
		ORGANIZATION_ID,
		DISPLAY_NAME,
		DESCRIPTION,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		LANGUAGE,
		SOURCE_LANG
	    ) select
	        p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE,
		p_alt_desig_rec.ORGANIZATION_ID,
		p_alt_desig_rec.DISPLAY_NAME,
		p_alt_desig_rec.DESCRIPTION,
		p_alt_desig_rec.LAST_UPDATE_DATE,
		p_alt_desig_rec.LAST_UPDATED_BY,
		p_alt_desig_rec.CREATION_DATE,
		p_alt_desig_rec.CREATED_BY,
		p_alt_desig_rec.LAST_UPDATE_LOGIN,
		L.LANGUAGE_CODE,
		userenv('LANG')
	    from FND_LANGUAGES L
	    where L.INSTALLED_FLAG in ('I', 'B')
	    and not exists
	    (select NULL
	     from BOM_ALTERNATE_DESIGNATORS_TL T
	     where T.ALTERNATE_DESIGNATOR_CODE = p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE
	     and T.ORGANIZATION_ID = p_alt_desig_rec.ORGANIZATION_ID
	     and T.LANGUAGE = L.LANGUAGE_CODE);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO Create_Alternate_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      x_msg_data := FND_MESSAGE.GET;
END Insert_row;

procedure UPDATE_ROW ( --- Called from the form BOMFDBAD.fmb
  P_ALTERNATE_DESIGNATOR_CODE in VARCHAR2,
  P_ORGANIZATION_ID in NUMBER,
  P_STRUCTURE_TYPE_ID in NUMBER,
  P_DISABLE_DATE in DATE,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_REQUEST_ID in NUMBER,
  P_DISPLAY_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) IS
    l_api_version            CONSTANT NUMBER := 1.0;
    x_return_status		VARCHAR2(1);
    x_errorcode			NUMBER;
    x_msg_count			NUMBER;
    x_msg_data			VARCHAR2(1000);
    rec                      Bom_Alt_Desig_Rec;
BEGIN

	rec.Alternate_Designator_Code := P_ALTERNATE_DESIGNATOR_CODE;
	rec.Organization_id           := P_ORGANIZATION_ID;
	rec.LAST_UPDATE_DATE          := P_LAST_UPDATE_DATE;
	rec.LAST_UPDATED_BY           := P_LAST_UPDATED_BY;
	rec.CREATION_DATE             := NULL;
	rec.CREATED_BY                := NULL;
	rec.LAST_UPDATE_LOGIN         := P_LAST_UPDATE_LOGIN;
	rec.DESCRIPTION               := P_DESCRIPTION;
	rec.DISABLE_DATE              := P_DISABLE_DATE;
	rec.ATTRIBUTE_CATEGORY        := P_ATTRIBUTE_CATEGORY;
	rec.ATTRIBUTE1                := P_ATTRIBUTE1;
	rec.ATTRIBUTE2                := P_ATTRIBUTE2;
	rec.ATTRIBUTE3                := P_ATTRIBUTE3;
	rec.ATTRIBUTE4                := P_ATTRIBUTE4;
	rec.ATTRIBUTE5                := P_ATTRIBUTE5;
	rec.ATTRIBUTE6                := P_ATTRIBUTE6;
	rec.ATTRIBUTE7                := P_ATTRIBUTE7;
	rec.ATTRIBUTE8                := P_ATTRIBUTE8;
	rec.ATTRIBUTE9                := P_ATTRIBUTE9;
	rec.ATTRIBUTE10               := P_ATTRIBUTE10;
	rec.ATTRIBUTE11               := P_ATTRIBUTE11;
	rec.ATTRIBUTE12               := P_ATTRIBUTE12;
	rec.ATTRIBUTE13               := P_ATTRIBUTE13;
	rec.ATTRIBUTE14               := P_ATTRIBUTE14;
	rec.ATTRIBUTE15               := P_ATTRIBUTE15;
	rec.REQUEST_ID                := P_REQUEST_ID;
	rec.PROGRAM_APPLICATION_ID    := NULL;
	rec.PROGRAM_ID                := NULL;
	rec.PROGRAM_UPDATE_DATE       := NULL;
	rec.STRUCTURE_TYPE_ID         := P_STRUCTURE_TYPE_ID;
	rec.DISPLAY_NAME              := P_DISPLAY_NAME;
	rec.Alt_Desig_Code_Old        := P_ALTERNATE_DESIGNATOR_CODE;
	rec.api_version               := l_api_version;

	Update_Row (p_alt_desig_rec   => rec
       ,x_return_status => x_return_status
       ,x_errorcode => x_errorcode
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		/* Write exception handling specific to forms using the returned error messages */
		NULL;
	END IF;
END;


PROCEDURE Update_Row (
        p_alt_desig_rec                 IN Bom_Alt_Desig_Rec
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Alternate';
    l_api_version            CONSTANT NUMBER := 1.0;
    old_preferred_name       VARCHAR2(30);

  BEGIN

    -- Standard start of API savepoint
    SAVEPOINT Update_Alternate_PUB;


    IF NOT FND_API.Compatible_API_Call (l_api_version, p_alt_desig_rec.api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF p_alt_desig_rec.ORGANIZATION_ID IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If the current structure is set as preferred structure name
    -- and there exists another preferred structure name for this structure type then
    -- reset that is_preferred value for the old structure name.
    old_preferred_name := Get_Preferred_Name(p_alt_desig_rec.structure_type_id,  p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE);
    IF(p_alt_desig_rec.is_preferred = 'Y' AND
        old_preferred_name <> p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE)
    THEN
        UPDATE bom_alternate_designators
            SET is_preferred ='N'
        WHERE
            structure_type_id = p_alt_desig_rec.structure_type_id
            AND is_preferred ='Y';
    END IF;

    IF( p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE = p_alt_desig_rec.Alt_Desig_Code_Old ) THEN
     UPDATE BOM_ALTERNATE_DESIGNATORS
	SET
	   ALTERNATE_DESIGNATOR_CODE = p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE,
	   DESCRIPTION = p_alt_desig_rec.DESCRIPTION,
	   DISABLE_DATE = p_alt_desig_rec.DISABLE_DATE,
	   STRUCTURE_TYPE_ID = p_alt_desig_rec.STRUCTURE_TYPE_ID,
	   ATTRIBUTE_CATEGORY = p_alt_desig_rec.ATTRIBUTE_CATEGORY,
	   ATTRIBUTE1 = p_alt_desig_rec.ATTRIBUTE1,
	   ATTRIBUTE2 = p_alt_desig_rec.ATTRIBUTE2,
	   ATTRIBUTE3 = p_alt_desig_rec.ATTRIBUTE3,
	   ATTRIBUTE4 = p_alt_desig_rec.ATTRIBUTE4,
	   ATTRIBUTE5 = p_alt_desig_rec.ATTRIBUTE5,
	   ATTRIBUTE6 = p_alt_desig_rec.ATTRIBUTE6,
	   ATTRIBUTE7 = p_alt_desig_rec.ATTRIBUTE7,
	   ATTRIBUTE8 = p_alt_desig_rec.ATTRIBUTE8,
	   ATTRIBUTE9 = p_alt_desig_rec.ATTRIBUTE9,
	   ATTRIBUTE10 = p_alt_desig_rec.ATTRIBUTE10,
	   ATTRIBUTE11 = p_alt_desig_rec.ATTRIBUTE11,
	   ATTRIBUTE12 = p_alt_desig_rec.ATTRIBUTE12,
	   ATTRIBUTE13 = p_alt_desig_rec.ATTRIBUTE13,
	   ATTRIBUTE14 = p_alt_desig_rec.ATTRIBUTE14,
	   ATTRIBUTE15 = p_alt_desig_rec.ATTRIBUTE15,
	   REQUEST_ID = p_alt_desig_rec.REQUEST_ID,
           LAST_UPDATE_DATE = p_alt_desig_rec.LAST_UPDATE_DATE,
           LAST_UPDATED_BY = p_alt_desig_rec.LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN = p_alt_desig_rec.LAST_UPDATE_LOGIN,
           IS_PREFERRED = p_alt_desig_rec.IS_PREFERRED
	WHERE
	   ALTERNATE_DESIGNATOR_CODE = p_alt_desig_rec.alt_desig_code_old
	   AND ORGANIZATION_ID = p_alt_desig_rec.ORGANIZATION_ID;

     UPDATE BOM_ALTERNATE_DESIGNATORS_TL
        SET
	   ALTERNATE_DESIGNATOR_CODE = p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE,
	   DESCRIPTION = p_alt_desig_rec.DESCRIPTION,
	   DISPLAY_NAME = p_alt_desig_rec.DISPLAY_NAME,
	   LAST_UPDATE_DATE = p_alt_desig_rec.LAST_UPDATE_DATE,
	   LAST_UPDATED_BY = p_alt_desig_rec.LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN = p_alt_desig_rec.LAST_UPDATE_LOGIN,
	   SOURCE_LANG = userenv('LANG')
	WHERE
	   ALTERNATE_DESIGNATOR_CODE = p_alt_desig_rec.alt_desig_code_old
	   and ORGANIZATION_ID = p_alt_desig_rec.ORGANIZATION_ID
	   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

       x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSIF( p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE <> p_alt_desig_rec.alt_desig_code_old ) THEN
     IF NOT Check_Unique(p_alt_desig_rec.ORGANIZATION_ID, p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE) THEN
     UPDATE BOM_ALTERNATE_DESIGNATORS
	SET
	   ALTERNATE_DESIGNATOR_CODE = p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE,
	   DESCRIPTION = p_alt_desig_rec.description,
	   DISABLE_DATE = p_alt_desig_rec.disable_date,
	   STRUCTURE_TYPE_ID = p_alt_desig_rec.structure_type_id,
	   ATTRIBUTE_CATEGORY = p_alt_desig_rec.ATTRIBUTE_CATEGORY,
	   ATTRIBUTE1 = p_alt_desig_rec.ATTRIBUTE1,
	   ATTRIBUTE2 = p_alt_desig_rec.ATTRIBUTE2,
	   ATTRIBUTE3 = p_alt_desig_rec.ATTRIBUTE3,
	   ATTRIBUTE4 = p_alt_desig_rec.ATTRIBUTE4,
	   ATTRIBUTE5 = p_alt_desig_rec.ATTRIBUTE5,
	   ATTRIBUTE6 = p_alt_desig_rec.ATTRIBUTE6,
	   ATTRIBUTE7 = p_alt_desig_rec.ATTRIBUTE7,
	   ATTRIBUTE8 = p_alt_desig_rec.ATTRIBUTE8,
	   ATTRIBUTE9 = p_alt_desig_rec.ATTRIBUTE9,
	   ATTRIBUTE10 = p_alt_desig_rec.ATTRIBUTE10,
	   ATTRIBUTE11 = p_alt_desig_rec.ATTRIBUTE11,
	   ATTRIBUTE12 = p_alt_desig_rec.ATTRIBUTE12,
	   ATTRIBUTE13 = p_alt_desig_rec.ATTRIBUTE13,
	   ATTRIBUTE14 = p_alt_desig_rec.ATTRIBUTE14,
	   ATTRIBUTE15 = p_alt_desig_rec.ATTRIBUTE15,
	   REQUEST_ID = p_alt_desig_rec.REQUEST_ID,
           LAST_UPDATE_DATE = p_alt_desig_rec.LAST_UPDATE_DATE,
           LAST_UPDATED_BY = p_alt_desig_rec.LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN = p_alt_desig_rec.LAST_UPDATE_LOGIN
	WHERE
	   ALTERNATE_DESIGNATOR_CODE = p_alt_desig_rec.alt_desig_code_old -- 4054618
	   AND ORGANIZATION_ID = p_alt_desig_rec.ORGANIZATION_ID;

     UPDATE BOM_ALTERNATE_DESIGNATORS_TL
        SET
	   ALTERNATE_DESIGNATOR_CODE = p_alt_desig_rec.ALTERNATE_DESIGNATOR_CODE,
	   DESCRIPTION = p_alt_desig_rec.description,
	   DISPLAY_NAME = p_alt_desig_rec.display_name,
	   LAST_UPDATE_DATE = p_alt_desig_rec.LAST_UPDATE_DATE,
	   LAST_UPDATED_BY = p_alt_desig_rec.LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN = p_alt_desig_rec.LAST_UPDATE_LOGIN,
	   SOURCE_LANG = userenv('LANG')
	WHERE
	   ALTERNATE_DESIGNATOR_CODE = p_alt_desig_rec.alt_desig_code_old
	   and ORGANIZATION_ID = p_alt_desig_rec.organization_id
	   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

       x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO Update_Alternate_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      x_msg_data := FND_MESSAGE.GET;

END Update_Row;

procedure DELETE_ROW ( ---- Called from form BOMFDBAD.fmb
  P_ALTERNATE_DESIGNATOR_CODE in VARCHAR2,
  P_ORGANIZATION_ID in NUMBER
) IS
    l_api_version            CONSTANT NUMBER := 1.0;
    x_return_status		VARCHAR2(1);
    x_errorcode			NUMBER;
    x_msg_count			NUMBER;
    x_msg_data			VARCHAR2(1000);
BEGIN
	Delete_Row (
        p_api_version => l_api_version
       ,p_alt_desig_code => P_ALTERNATE_DESIGNATOR_CODE
       ,p_organization_id => P_ORGANIZATION_ID
       ,x_return_status => x_return_status
       ,x_errorcode => x_errorcode
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		/* Write exception handling specific to forms using the returned error messages */
		NULL;
	END IF;
END DELETE_ROW;

procedure LOCK_ROW (
  P_ALTERNATE_DESIGNATOR_CODE in VARCHAR2,
  P_ORGANIZATION_ID in NUMBER,
  P_STRUCTURE_TYPE_ID in NUMBER,
  P_DISABLE_DATE in DATE,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_REQUEST_ID in NUMBER,
--  P_DISPLAY_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      STRUCTURE_TYPE_ID,
      DISABLE_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      REQUEST_ID
    from BOM_ALTERNATE_DESIGNATORS
    where ALTERNATE_DESIGNATOR_CODE = P_ALTERNATE_DESIGNATOR_CODE
    and ORGANIZATION_ID = P_ORGANIZATION_ID
    for update of ALTERNATE_DESIGNATOR_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
--      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BOM_ALTERNATE_DESIGNATORS_TL
    where ALTERNATE_DESIGNATOR_CODE = P_ALTERNATE_DESIGNATOR_CODE
    and ORGANIZATION_ID = P_ORGANIZATION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ALTERNATE_DESIGNATOR_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.STRUCTURE_TYPE_ID = P_STRUCTURE_TYPE_ID)
           OR ((recinfo.STRUCTURE_TYPE_ID is null) AND (P_STRUCTURE_TYPE_ID is null)))
      AND ((recinfo.DISABLE_DATE = P_DISABLE_DATE)
           OR ((recinfo.DISABLE_DATE is null) AND (P_DISABLE_DATE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (P_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (P_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (P_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (P_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (P_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (P_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (P_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (P_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (P_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (P_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (P_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (P_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (P_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (P_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (P_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (P_ATTRIBUTE15 is null)))
      AND ((recinfo.REQUEST_ID = P_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (P_REQUEST_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if ( --   (tlinfo.DISPLAY_NAME = P_DISPLAY_NAME) AND
               ((tlinfo.DESCRIPTION = P_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (P_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

Function Get_Preferred_Name ( structure_type_id Number, alt_des_code varchar2) return VARCHAR2
is
return_value varchar2(10);
cursor get_preferred (p_structure_type_id Number,p_alt_code varchar2) is
 select distinct alternate_designator_code from bom_alternate_designators
    where is_preferred ='Y'
    and structure_type_id = p_structure_type_id
    and alternate_designator_code <> p_alt_code;
begin

 for c1 in get_preferred(structure_type_id,alt_des_code) loop
    return_value := c1.alternate_designator_code;
 end loop;
 return return_value;

end Get_Preferred_Name;

PROCEDURE copy_to_org( p_alt_desig_code IN VARCHAR2, p_from_org_id IN NUMBER, p_to_org_id IN NUMBER) IS
  CURSOR c_from_structure_name_csr(cp_alt_desig_code IN VARCHAR2, cp_org_id IN NUMBER) IS
       SELECT display_name,
	          description,
			  NULL disable_date,
			  structure_type_id,
			  is_preferred
	   FROM bom_alternate_designators_vl badv
	   WHERE badv.alternate_designator_code = cp_alt_desig_code
	     AND badv.organization_id = cp_org_id;
  l_display_name bom_alternate_designators_tl.display_name%TYPE;
  l_description bom_alternate_designators_tl.description%TYPE;
  l_disable_date bom_alternate_designators.disable_date%TYPE;
  l_structure_type_id bom_alternate_designators.structure_type_id%TYPE;
  l_is_preferred bom_alternate_designators.is_preferred%TYPE;
  x_return_status VARCHAR2(1);
  x_errorcode NUMBER;
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(4000);
BEGIN

  OPEN c_from_structure_name_csr(p_alt_desig_code, p_from_org_id);
  FETCH c_from_structure_name_csr INTO l_display_name, l_description, l_disable_date, l_structure_type_id, l_is_preferred;
  IF (c_from_structure_name_csr%NOTFOUND) THEN
    CLOSE c_from_structure_name_csr;
    fnd_message.set_name('BOM', 'BOM_NO_SOURCE_ALT_DESIG_EXISTS');
	fnd_message.set_token('ALT_DESIG', p_alt_desig_code, FALSE);
    app_exception.raise_exception;
  end if;
  close c_from_structure_name_csr;
  insert_row (
        p_api_version => 1.0
       ,p_alt_desig_code => p_alt_desig_code
       ,p_organization_id => p_to_org_id
       ,p_display_name => l_display_name
       ,p_description => l_description
       ,p_disable_date => l_disable_date
       ,p_structure_type_id => l_structure_type_id
       ,p_is_preferred => l_is_preferred
       ,x_return_status => x_return_status
       ,x_errorcode => x_errorcode
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      app_exception.raise_exception;
   END IF;
END copy_to_org;

PROCEDURE LOAD_ROW(  --called from bomalt.lct
  p_alternate_designator_code IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_description IN VARCHAR2,
  p_display_name IN VARCHAR2,
  p_disable_date IN DATE,
  p_structure_type_id IN NUMBER,
  p_attribute_category IN VARCHAR2,
  p_attribute1 IN VARCHAR2,
  p_attribute2 IN VARCHAR2,
  p_attribute3 IN VARCHAR2,
  p_attribute4 IN VARCHAR2,
  p_attribute5 IN VARCHAR2,
  p_attribute6 IN VARCHAR2,
  p_attribute7 IN VARCHAR2,
  p_attribute8 IN VARCHAR2,
  p_attribute9 IN VARCHAR2,
  p_attribute10 IN VARCHAR2,
  p_attribute11 IN VARCHAR2,
  p_attribute12 IN VARCHAR2,
  p_attribute13 IN VARCHAR2,
  p_attribute14 IN VARCHAR2,
  p_attribute15 IN VARCHAR2,
  p_request_id IN NUMBER,
  p_program_application_id IN NUMBER,
  p_program_id IN NUMBER,
  p_program_update_date IN DATE,
  p_creation_date IN DATE,
  p_created_by IN NUMBER,
  p_last_update_date IN DATE,
  p_last_updated_by IN NUMBER,
  p_last_update_login IN NUMBER,
  p_custom_mode IN VARCHAR2,
  p_is_preferred IN VARCHAR2)
IS
  CURSOR GET_ALL_ORGS IS
  SELECT organization_id
    FROM mtl_parameters ;
BEGIN
/* special logic for seeded packbom to propagate to all orgs */
  IF p_alternate_designator_code ='PIM_PBOM_S' THEN
    FOR c1 IN GET_ALL_ORGS LOOP
      LOAD_ALTERNATE_DESIGNATOR (
        p_alternate_designator_code => p_alternate_designator_code,
        p_organization_id     => c1.organization_id,
        p_description         => p_description,
        p_display_name        => p_display_name,
        p_disable_date        => p_disable_date,
        p_structure_type_id   => p_structure_type_id,
        p_attribute_category  => p_attribute_category,
        p_attribute1          => p_attribute1,
        p_attribute2          => p_attribute2,
        p_attribute3          => p_attribute3,
        p_attribute4          => p_attribute4,
        p_attribute5          => p_attribute5,
        p_attribute6          => p_attribute6,
        p_attribute7          => p_attribute7,
        p_attribute8          => p_attribute8,
        p_attribute9          => p_attribute9,
        p_attribute10         => p_attribute10,
        p_attribute11         => p_attribute11,
        p_attribute12         => p_attribute12,
        p_attribute13         => p_attribute13,
        p_attribute14         => p_attribute14,
        p_attribute15         => p_attribute15,
        p_request_id          => p_request_id,
        p_program_application_id => p_program_application_id,
        p_program_id          => p_program_id,
        p_program_update_date => p_program_update_date,
        p_creation_date       => p_creation_date,
        p_created_by          => p_created_by,
        p_last_update_date    => p_last_update_date,
        p_last_updated_by     => p_last_updated_by,
        p_last_update_login   => p_last_update_login,
        p_custom_mode         => p_custom_mode,
        p_is_preferred        => p_is_preferred
      );
    END LOOP; -- GET_ALL_ORGS
  ELSE
      LOAD_ALTERNATE_DESIGNATOR (
        p_alternate_designator_code => p_alternate_designator_code,
        p_organization_id     => p_organization_id ,
        p_description         => p_description,
        p_display_name        => p_display_name,
        p_disable_date        => p_disable_date,
        p_structure_type_id   => p_structure_type_id,
        p_attribute_category  => p_attribute_category,
        p_attribute1          => p_attribute1,
        p_attribute2          => p_attribute2,
        p_attribute3          => p_attribute3,
        p_attribute4          => p_attribute4,
        p_attribute5          => p_attribute5,
        p_attribute6          => p_attribute6,
        p_attribute7          => p_attribute7,
        p_attribute8          => p_attribute8,
        p_attribute9          => p_attribute9,
        p_attribute10         => p_attribute10,
        p_attribute11         => p_attribute11,
        p_attribute12         => p_attribute12,
        p_attribute13         => p_attribute13,
        p_attribute14         => p_attribute14,
        p_attribute15         => p_attribute15,
        p_request_id          => p_request_id,
        p_program_application_id => p_program_application_id,
        p_program_id          => p_program_id,
        p_program_update_date => p_program_update_date,
        p_creation_date       => p_creation_date,
        p_created_by          => p_created_by,
        p_last_update_date    => p_last_update_date,
        p_last_updated_by     => p_last_updated_by,
        p_last_update_login   => p_last_update_login,
        p_custom_mode         => p_custom_mode,
        p_is_preferred        => p_is_preferred
      );
  END IF; --p_alternate_designator_code PIM_PBOM_S
END LOAD_ROW;

PROCEDURE LOAD_ALTERNATE_DESIGNATOR ( --- called from  load_row
  p_alternate_designator_code IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_description IN VARCHAR2,
  p_display_name IN VARCHAR2,
  p_disable_date IN DATE,
  p_structure_type_id IN NUMBER,
  p_attribute_category IN VARCHAR2,
  p_attribute1 IN VARCHAR2,
  p_attribute2 IN VARCHAR2,
  p_attribute3 IN VARCHAR2,
  p_attribute4 IN VARCHAR2,
  p_attribute5 IN VARCHAR2,
  p_attribute6 IN VARCHAR2,
  p_attribute7 IN VARCHAR2,
  p_attribute8 IN VARCHAR2,
  p_attribute9 IN VARCHAR2,
  p_attribute10 IN VARCHAR2,
  p_attribute11 IN VARCHAR2,
  p_attribute12 IN VARCHAR2,
  p_attribute13 IN VARCHAR2,
  p_attribute14 IN VARCHAR2,
  p_attribute15 IN VARCHAR2,
  p_request_id IN NUMBER,
  p_program_application_id IN NUMBER,
  p_program_id IN NUMBER,
  p_program_update_date IN DATE,
  p_creation_date IN DATE,
  p_created_by IN NUMBER,
  p_last_update_date IN DATE,
  p_last_updated_by IN NUMBER,
  p_last_update_login IN NUMBER,
  p_custom_mode IN VARCHAR2,
  p_is_preferred IN VARCHAR2)
IS
  db_luby   NUMBER;  -- entity owner in db
  db_ludate DATE;    -- entity update date in db
  old_preferred_name VARCHAR2(30);
BEGIN

  SELECT
        bad.LAST_UPDATED_BY, bad.LAST_UPDATE_DATE
  INTO
        db_luby, db_ludate
  FROM
        BOM_ALTERNATE_DESIGNATORS bad
  WHERE
      (
        (
              p_alternate_designator_code IS NULL
         AND  bad.ALTERNATE_DESIGNATOR_CODE IS NULL
        )
      OR
        (
          p_alternate_designator_code = bad.ALTERNATE_DESIGNATOR_CODE
        )
      )
  AND  ( bad.ORGANIZATION_ID = p_organization_id
    or (bad.organization_id is null and p_organization_id is null));

  -- Test for customization and version
  IF ( FND_LOAD_UTIL.UPLOAD_TEST(p_last_updated_by, p_last_update_date, db_luby, db_ludate, p_custom_mode) )
  THEN
    -- When is_preferred is set for current structure name and there exists another preferred structure name already
    -- then reset that value.
    IF (p_is_preferred = 'Y' )
    THEN
      old_preferred_name := Get_Preferred_Name(p_structure_type_id,  p_alternate_designator_code);
      IF(old_preferred_name <> p_alternate_designator_code)
      THEN
        UPDATE BOM_ALTERNATE_DESIGNATORS
          SET is_preferred ='N'
        WHERE alternate_designator_code = old_preferred_name;
      END IF;
    END IF;

    -- Update existing row
    -- Since update_row is not taking care of NULL alternate designator, updating row directly.
    UPDATE BOM_ALTERNATE_DESIGNATORS
    SET
      DESCRIPTION = NVL(p_description, DESCRIPTION),
      DISABLE_DATE = p_disable_date,
      STRUCTURE_TYPE_ID = p_structure_type_id,
      ATTRIBUTE_CATEGORY = p_attribute_category,
      ATTRIBUTE1 = p_attribute1,
      ATTRIBUTE2 = p_attribute2,
      ATTRIBUTE3 = p_attribute3,
      ATTRIBUTE4 = p_attribute4,
      ATTRIBUTE5 = p_attribute5,
      ATTRIBUTE6 = p_attribute6,
      ATTRIBUTE7 = p_attribute7,
      ATTRIBUTE8 = p_attribute8,
      ATTRIBUTE9 = p_attribute9,
      ATTRIBUTE10 = p_attribute10,
      ATTRIBUTE11 = p_attribute11,
      ATTRIBUTE12 = p_attribute12,
      ATTRIBUTE13 = p_attribute13,
      ATTRIBUTE14 = p_attribute14,
      ATTRIBUTE15 = p_attribute15,
      REQUEST_ID = p_request_id,
      PROGRAM_APPLICATION_ID = p_program_application_id,
      PROGRAM_ID = p_program_id,
      PROGRAM_UPDATE_DATE = p_program_update_date,
      LAST_UPDATE_DATE = p_last_update_date,
      LAST_UPDATED_BY = p_last_updated_by,
      LAST_UPDATE_LOGIN = p_last_update_login,
      IS_PREFERRED = p_is_preferred
    WHERE
        (
          (
                p_alternate_designator_code IS NULL
           AND  ALTERNATE_DESIGNATOR_CODE  IS NULL
          )
         OR
          ( ALTERNATE_DESIGNATOR_CODE = p_alternate_designator_code )
        )
    AND (ORGANIZATION_ID = p_organization_id
    or (organization_id is null and p_organization_id is null));

    UPDATE BOM_ALTERNATE_DESIGNATORS_TL
    SET
      DESCRIPTION = NVL(p_description, DESCRIPTION),
      DISPLAY_NAME = NVL(p_display_name, DISPLAY_NAME),
      LAST_UPDATE_DATE = p_last_update_date,
      LAST_UPDATED_BY = p_last_updated_by,
      LAST_UPDATE_LOGIN = p_last_update_login,
      SOURCE_LANG = userenv('LANG')
    WHERE
        (
          (
                p_alternate_designator_code IS NULL
           AND  ALTERNATE_DESIGNATOR_CODE  IS NULL
          )
         OR
          ( ALTERNATE_DESIGNATOR_CODE = p_alternate_designator_code )
        )
    AND ORGANIZATION_ID = p_organization_id
    AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  END IF; -- end of IF FND_LOAD_UTIL

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Record doesn't exist - insert in all cases
    -- Since insert_row is not taking care of NULL alternate designator, inserting row directly.
    INSERT INTO BOM_ALTERNATE_DESIGNATORS
      (
         ALTERNATE_DESIGNATOR_CODE
        ,ORGANIZATION_ID
        ,DESCRIPTION
        ,DISABLE_DATE
        ,STRUCTURE_TYPE_ID
        ,ATTRIBUTE_CATEGORY
        ,ATTRIBUTE1
        ,ATTRIBUTE2
        ,ATTRIBUTE3
        ,ATTRIBUTE4
        ,ATTRIBUTE5
        ,ATTRIBUTE6
        ,ATTRIBUTE7
        ,ATTRIBUTE8
        ,ATTRIBUTE9
        ,ATTRIBUTE10
        ,ATTRIBUTE11
        ,ATTRIBUTE12
        ,ATTRIBUTE13
        ,ATTRIBUTE14
        ,ATTRIBUTE15
        ,REQUEST_ID
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,PROGRAM_APPLICATION_ID
        ,PROGRAM_ID
        ,PROGRAM_UPDATE_DATE
        ,IS_PREFERRED
      )
    VALUES
      (
         p_alternate_designator_code
        ,p_organization_id
        ,p_description
        ,p_disable_date
        ,p_structure_type_id
        ,p_attribute_category
        ,p_attribute1
        ,p_attribute2
        ,p_attribute3
        ,p_attribute4
        ,p_attribute5
        ,p_attribute6
        ,p_attribute7
        ,p_attribute8
        ,p_attribute9
        ,p_attribute10
        ,p_attribute11
        ,p_attribute12
        ,p_attribute13
        ,p_attribute14
        ,p_attribute15
        ,p_request_id
        ,p_creation_date
        ,p_created_by
        ,p_last_update_date
        ,p_last_updated_by
        ,p_last_update_login
        ,p_program_application_id
        ,p_program_id
        ,p_program_update_date
        ,p_is_preferred
      );

    INSERT INTO BOM_ALTERNATE_DESIGNATORS_TL
      (
        ALTERNATE_DESIGNATOR_CODE,
        ORGANIZATION_ID,
        DISPLAY_NAME,
        DESCRIPTION,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        LANGUAGE,
        SOURCE_LANG
      )
      SELECT
        p_alternate_designator_code,
        p_organization_id,
        p_display_name,
        p_description,
        p_last_update_date,
        p_last_updated_by,
        p_creation_date,
        p_created_by,
        p_last_update_login,
        L.LANGUAGE_CODE,
        userenv('LANG')
      FROM
        FND_LANGUAGES L
      WHERE
          L.INSTALLED_FLAG IN ('I', 'B')
      AND NOT EXISTS
                (
                  SELECT NULL
                  FROM BOM_ALTERNATE_DESIGNATORS_TL T
                  WHERE
                    (
                      (
                            p_alternate_designator_code IS NULL
                       AND  T.ALTERNATE_DESIGNATOR_CODE  IS NULL
                      )
                     OR
                      ( T.ALTERNATE_DESIGNATOR_CODE = p_alternate_designator_code )
                    )
                  AND T.ORGANIZATION_ID = p_organization_id
                  AND T.LANGUAGE = L.LANGUAGE_CODE
                );

    -- When is_preferred is set for current structure name and there exists another preferred structure name already
    -- then reset that value.
    IF (p_is_preferred = 'Y' )
    THEN
      old_preferred_name := Get_Preferred_Name(p_structure_type_id,  p_alternate_designator_code);
      IF(old_preferred_name <> p_alternate_designator_code)
      THEN
        UPDATE BOM_ALTERNATE_DESIGNATORS
          SET is_preferred ='N'
        WHERE alternate_designator_code = old_preferred_name;
      END IF;
    END IF;

END LOAD_ALTERNATE_DESIGNATOR;

PROCEDURE TRANSLATE_ROW ( --- called from bomalt.lct
  p_alternate_designator_code IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_description IN VARCHAR2,
  p_display_name IN VARCHAR2,
  p_last_update_date IN DATE,
  p_last_updated_by IN NUMBER,
  p_last_update_login IN NUMBER,
  p_custom_mode IN VARCHAR2)
IS
  db_luby   NUMBER;  -- entity owner in db
  db_ludate DATE;    -- entity update date in db
BEGIN

  SELECT
        badtl.LAST_UPDATED_BY, badtl.LAST_UPDATE_DATE
  INTO
        db_luby, db_ludate
  FROM
        BOM_ALTERNATE_DESIGNATORS_TL badtl
  WHERE
      badtl.LANGUAGE = userenv('LANG')
  AND
      (
        (
              p_alternate_designator_code IS NULL
         AND  badtl.ALTERNATE_DESIGNATOR_CODE IS NULL
        )
      OR
        (
          p_alternate_designator_code = badtl.ALTERNATE_DESIGNATOR_CODE
        )
      )
  AND   badtl.ORGANIZATION_ID = p_organization_id;

  -- Test for customization and version
  IF ( FND_LOAD_UTIL.UPLOAD_TEST(p_last_updated_by, p_last_update_date, db_luby, db_ludate, p_custom_mode) )
  THEN
     -- Update translations for this language
     UPDATE BOM_ALTERNATE_DESIGNATORS_TL
     SET
        DISPLAY_NAME = NVL(p_display_name, DISPLAY_NAME),
        DESCRIPTION = NVL(p_description, DESCRIPTION),
        LAST_UPDATE_DATE = p_last_update_date,
        LAST_UPDATED_BY = p_last_updated_by,
        LAST_UPDATE_LOGIN = p_last_update_login,
        SOURCE_LANG = userenv('LANG')
     WHERE
        userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
      AND
          (
            (
                  p_alternate_designator_code IS NULL
             AND  ALTERNATE_DESIGNATOR_CODE IS NULL
            )
          OR
            (
              p_alternate_designator_code = ALTERNATE_DESIGNATOR_CODE
            )
          )
      AND   ORGANIZATION_ID = p_organization_id;

  END IF; -- end of IF FND_LOAD_UTIL

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Do not insert missing translations, skip this row
    NULL;
END TRANSLATE_ROW;

END BOM_ALTERNATE_DESIGNATORS_PKG;

/
