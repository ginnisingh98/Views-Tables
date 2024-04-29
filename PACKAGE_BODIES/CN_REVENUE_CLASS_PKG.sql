--------------------------------------------------------
--  DDL for Package Body CN_REVENUE_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_REVENUE_CLASS_PKG" AS
/* $Header: cntrclsb.pls 120.2 2005/08/07 23:02:48 vensrini noship $ */
--
-- Package Name
-- CN_REVENUE_CLASS_PKG
-- Purpose
--  Table Handler for CN_REVENUE_CLASS
--
-- History
-- 02-feb-01	Kumar Sivasankaran
-- ==========================================================================
-- |
-- |                             PRIVATE VARIABLES
-- |
-- ==========================================================================
  g_program_type     VARCHAR2(30) := NULL;
-- ==========================================================================
-- |
-- |                             PRIVATE ROUTINES
-- |
-- ==========================================================================

-- ==========================================================================
--  |                             Custom Validation
-- ==========================================================================

-- ==========================================================================
  -- Procedure Name
  --	Get_UID
  -- Purpose
  --    Get the Sequence Number to Create a new revenue Class
-- ==========================================================================
 PROCEDURE Get_UID( x_revenue_class_id     IN OUT NOCOPY NUMBER) IS

 BEGIN

    SELECT cn_revenue_classes_s.nextval
      INTO   X_revenue_class_id
      FROM   dual;

 END Get_UID;

-- ==========================================================================
  -- Procedure Name
  --	Insert_row
  -- Purpose
  --    Main insert procedure
-- ==========================================================================
PROCEDURE insert_row
   (x_revenue_class_id          IN OUT NOCOPY NUMBER
    ,p_name                     VARCHAR2   := NULL
    ,p_description 		VARCHAR2   := NULL
    ,p_liability_account_id    NUMBER      := NULL
    ,p_expense_account_id      NUMBER      := NULL
    ,p_Created_By               NUMBER
    ,p_Creation_Date            DATE
    ,p_Last_Updated_By          NUMBER
    ,p_Last_Update_Date         DATE
    ,p_Last_Update_Login        NUMBER
    ,p_org_id	IN		NUMBER)
   IS
      l_dummy NUMBER;

   BEGIN

      Get_UID( x_revenue_class_id );

     INSERT INTO cn_revenue_Classes
       ( ORG_ID
        ,revenue_class_id
        ,name
        ,DESCRIPTION
        ,liability_account_id
        ,expense_account_id
        ,object_version_number
 	,Created_By
	,Creation_Date
	,Last_Updated_By
	,Last_Update_Date
	,Last_Update_Login)
       VALUES
       ( p_org_id
        ,x_revenue_class_id
        ,p_name
        ,p_DESCRIPTION
        ,p_liability_account_id
        ,p_expense_account_id
        ,1
	,p_Created_By
	,p_Creation_Date
	,p_Last_Updated_By
	,p_Last_Update_Date
	,p_Last_Update_Login
	);

   END Insert_row;

-- ==========================================================================
  -- Procedure Name
  --   Update Record
  -- Purpose
  --
-- ==========================================================================
PROCEDURE update_row
    (p_revenue_class_id         NUMBER
    ,p_name                     VARCHAR2
    ,p_description              VARCHAR2
    ,p_liability_account_id     NUMBER
    ,p_expense_account_id       NUMBER
    ,p_object_version_number    NUMBER
    ,p_Last_Updated_By          NUMBER
    ,p_Last_Update_Date         DATE
    ,p_Last_Update_Login        NUMBER ) IS


   l_revenue_class_id          cn_revenue_classes.revenue_class_id%TYPE;
   l_name                      cn_revenue_classes.name%TYPE;
   l_description               cn_revenue_classes.description%TYPE;
   l_liability_account_Id      cn_revenue_classes.liability_account_id%TYPE;
   l_expense_account_Id        cn_revenue_classes.expense_account_id%TYPE;

   CURSOR C IS
	  SELECT *
	    FROM cn_revenue_classes
	    WHERE revenue_class_id = p_revenue_class_id
	    FOR UPDATE of revenue_class_id NOWAIT;
       oldrow C%ROWTYPE;

BEGIN
   OPEN C;
   FETCH C INTO oldrow;

   IF (C%NOTFOUND) then
      CLOSE C;
      fnd_message.Set_Name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   END IF;
   CLOSE C;


   SELECT decode(p_revenue_class_id,
	     fnd_api.g_miss_num, oldrow.revenue_class_id,
	     p_revenue_class_id),
      decode(p_name,
	     fnd_api.g_miss_char, oldrow.name,
	     p_name),
      decode(p_description,
	     fnd_api.g_miss_char, oldrow.description,
	     p_description),
      decode(p_liability_account_id,
	     fnd_api.g_miss_num, oldrow.liability_account_id,
	     p_liability_account_id),
      decode(p_expense_account_id,
	     fnd_api.g_miss_num, oldrow.expense_account_id,
	     p_expense_account_id)
     INTO
      l_revenue_class_id,
      l_name             ,
      l_description      ,
      l_liability_account_id,
      l_expense_account_id
      FROM dual;

     IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
     END IF;


    UPDATE cn_revenue_classes
      SET
      revenue_class_id          =       l_revenue_class_id,
      object_version_number     =       nvl(p_object_version_number,0) + 1,
      name                      =       l_name,
      description               =       l_description,
      liability_account_id      =       l_liability_account_id,
      expense_account_id        =       l_expense_account_id,
      last_update_date	        =	p_Last_Update_Date,
      last_updated_by      	=     	p_Last_Updated_By,
      last_update_login    	=     	p_Last_Update_Login
      WHERE revenue_class_id    =       p_revenue_class_id;

   IF oldrow.name <> l_name THEN

    UPDATE cn_hierarchy_nodes  chn
      SET chn.name = l_name
    WHERE chn.external_id = l_revenue_class_id
      AND chn.dim_hierarchy_id IN (
        select dh.dim_hierarchy_id
          from cn_dimensions d,
            cn_obj_tables_v t,
            cn_head_hierarchies h,
            cn_dim_hierarchies dh
      where d.source_table_id = t.table_id
        and d.dimension_id = h.dimension_id
        and h.head_hierarchy_id = dh.header_dim_hierarchy_id
        and t.name = 'CN_REVENUE_CLASSES');

  END IF;

  END Update_row;

-- ==========================================================================
  -- Procedure Name
  --	Delete_row
  -- Purpose
-- ==========================================================================

  PROCEDURE Delete_row( p_revenue_class_id     NUMBER ) IS
  BEGIN

     DELETE FROM cn_revenue_classes
       WHERE  revenue_class_id  = p_revenue_class_id ;
     IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
     END IF;

  END Delete_row;

END CN_REVENUE_CLASS_PKG;

/
