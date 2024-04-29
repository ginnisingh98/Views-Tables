--------------------------------------------------------
--  DDL for Package Body EGO_CATEGORY_SET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_CATEGORY_SET_PUB" AS
/* $Header: EGOCSTPB.pls 120.2 2006/01/25 08:45:23 bparthas noship $ */

  g_pkg_name                VARCHAR2(30) := 'EGO_CATEGORY_SET_PUB';
  g_app_name                VARCHAR2(3)  := 'EGO';
  g_current_user_id         NUMBER       := EGO_SCTX.Get_User_Id();
  g_current_login_id        NUMBER       := FND_GLOBAL.Login_Id;
  g_plsql_err               VARCHAR2(17) := 'EGO_PLSQL_ERR';
  g_pkg_name_token          VARCHAR2(8)  := 'PKG_NAME';
  g_api_name_token          VARCHAR2(8)  := 'API_NAME';
  g_sql_err_msg_token       VARCHAR2(11) := 'SQL_ERR_MSG';



-------------------------------------------

FUNCTION Check_DBI_59_Installed
RETURN  VARCHAR2
IS

  l_dbi_59_is_installed   VARCHAR2(1);
  l_exist       NUMBER := 0;
BEGIN

  --Pre R12, this method checked for existence of ENI_DENORM_HRCHY
    -- in user_objects.
    -- Since R12 is a single APPS delivery, all package objects
    -- are expected to available, and hence this package has been
    -- modified to return Y in all cases

  l_dbi_59_is_installed := 'Y';
  RETURN( l_dbi_59_is_installed );
END Check_DBI_59_Installed;

-------------------------------------------



PROCEDURE Process_Category_Set_Assoc
(  p_cat_set_id                   IN  NUMBER
 , p_child_id                     IN  NUMBER
 , p_parent_id                    IN  NUMBER
 , p_mode_flag                     IN  VARCHAR2
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2

)
IS
  l_dbi_59_installed             VARCHAR2(1);
BEGIN

  l_dbi_59_installed := Check_DBI_59_Installed();

  IF ( l_dbi_59_installed = 'Y' ) THEN

     EXECUTE IMMEDIATE
      ' BEGIN                                                        '||
      '    ENI_DENORM_HRCHY.INSERT_INTO_STAGING                       '||
      '    (                                                         '||
      '      p_object_type         =>  :p_object_type                '||
      '   ,  p_object_id           =>  :p_cat_set_id                 '||
      '   ,  p_child_id            =>  :p_child_id                   '||
      '   ,  p_parent_id           =>  :p_parent_id                  '||
      '   ,  p_mode_flag           =>  :p_mode_flag                  '||
      '   ,  x_return_status       =>  :x_return_status              '||
      '   ,  x_msg_count           =>  :x_msg_count                  '||
      '   ,  x_msg_data            =>  :x_msg_data                   '||
      '   );                                                         '||
      ' END;'
     USING IN 'CATEGORY_SET',
           IN p_cat_set_id,
           IN p_child_id,
           IN p_parent_id,
           IN p_mode_flag,
           OUT x_return_status,
           OUT x_msg_count,
           OUT x_msg_data;


     IF ( x_return_status = FND_API.g_RET_STS_ERROR ) THEN
        FND_MESSAGE.Set_Encoded (x_msg_data);
        APP_EXCEPTION.Raise_Exception;
     ELSIF ( x_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
        FND_MESSAGE.Set_Encoded (x_msg_data);
        APP_EXCEPTION.Raise_Exception;
     END IF;

   END IF;


END Process_Category_Set_Assoc;


---------------------------------------------------
-- This method returns 'Y' if default DBI Category Set exists
-- ELSE returns 'N'
---------------------------------------------------
FUNCTION Check_DBI_Default_Exists
RETURN VARCHAR2
IS

  l_default_exists  VARCHAR2(1);
  l_exists          NUMBER := 0;

BEGIN

  l_default_exists := 'N';

  select count(1) into l_exists
  from mtl_default_category_sets
  where functional_area_id = G_DBI_FUNCTIONAL_AREA_ID;

  if (l_exists <> 0 ) then
  -- default exists
    l_default_exists := 'Y';
  end if;

  RETURN( l_default_exists );

END Check_DBI_Default_Exists;


---------------------------------------------------
--This method will return the default category set id for DBI
--IF it exists, ELSE returns -1
---------------------------------------------------

FUNCTION Get_DBI_Default_Category_Set
RETURN NUMBER
IS

  l_default_exists                VARCHAR2(1);
  l_DBI_category_set_id           NUMBER := -1;
BEGIN

  l_default_exists := Check_DBI_Default_Exists();

  IF( l_default_exists = 'Y' ) THEN

    SELECT category_set_id INTO l_DBI_category_set_id
    FROM
    (select * from mtl_default_category_sets
     where functional_area_id = EGO_CATEGORY_SET_PUB.G_DBI_FUNCTIONAL_AREA_ID
     and rownum = 1);

  END IF;

  RETURN( l_DBI_category_set_id );

END ;

---------------------------------------------------
--This method will return 'Y' if this category is a category included in the default category set for DBI
--ELSE returns 'N'
---------------------------------------------------
FUNCTION Is_DBI_Catalog_Category
(
  p_Category_Id       IN NUMBER
)
RETURN VARCHAR2
IS
  l_DBI_category_set_id          NUMBER;
  l_is_DBI_catalog_category      VARCHAR2(1) := 'N';
  l_exists                       NUMBER := 0;
BEGIN

  l_DBI_category_set_id := Get_DBI_Default_Category_Set();
  IF ( l_DBI_category_set_id <> -1 ) THEN

    select count(1) into l_exists
    from mtl_category_set_valid_cats
    where category_set_id = l_DBI_category_set_id
    and category_id = p_Category_Id;

    IF( l_exists <> 0 ) THEN
      l_is_DBI_catalog_category := 'Y';
     END IF;
  END IF;

  RETURN( l_is_DBI_Catalog_Category );

END Is_DBI_Catalog_Category;


---------------------------------------------------
--Insert into DBI staging table to indicate that this category Description and/or Disable_Date has been changed
--IF this category is a DBI category AND DBI 11.5.9 is installed
--PARAMETERS
--p_mode_flag = 'C' for Description update
--p_mode_flag = 'E' for Disable Date update
---------------------------------------------------

PROCEDURE Process_DBI_Category
(  p_category_id                    IN  NUMBER
 , p_language_code                  IN VARCHAR2
 , p_mode_flag                    IN VARCHAR2
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2

)
IS
BEGIN

  Process_DBI_Category( p_category_id,
                        p_mode_flag,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

END Process_DBI_Category;

PROCEDURE Process_DBI_Category
(  p_category_id                    IN  NUMBER
 , p_mode_flag                    IN VARCHAR2
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2

)
IS
  l_is_DBI_category              VARCHAR2(1);
BEGIN

  l_is_DBI_category := Is_DBI_Catalog_Category(p_Category_Id);

  IF (l_is_DBI_category = 'Y') THEN
    Process_Category_Set_Assoc
    (  p_cat_set_id   => Get_DBI_Default_Category_Set()
     , p_child_id     => p_category_id
     , p_parent_id    => null
     , p_mode_flag    => p_mode_flag
     , x_return_status  => x_return_status
     , x_msg_count      => x_msg_count
     , x_msg_data       => x_msg_data
    );

   END IF;


END Process_DBI_Category;


END EGO_CATEGORY_SET_PUB;

/
