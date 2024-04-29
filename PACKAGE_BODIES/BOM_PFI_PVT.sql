--------------------------------------------------------
--  DDL for Package Body BOM_PFI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_PFI_PVT" AS
/* $Header: BOMVPFIB.pls 120.2 2005/06/21 03:58:14 appldev ship $ */

/****************************************************************************/
--        ---------------  Private constants  -----------------
--        -----------------------------------------------------

G_PKG_NAME	CONSTANT VARCHAR2(30)	:=  'BOM_PFI_PVT' ;

/****************************************************************************/

-- Record in PL/SQL table each product family item corresponding to a
-- category to be created.
--
PROCEDURE Store_Cat_Create
( 	p_return_sts		IN OUT NOCOPY NUMBER			,
	p_return_err		IN OUT NOCOPY VARCHAR2		,
	p_item_id		IN	NUMBER			,
	p_org_id		IN	NUMBER			,
	p_Cat_Create_Num	 IN OUT NOCOPY 	BINARY_INTEGER		,
	p_Create_Cat_Tbl	 IN OUT NOCOPY 	Create_Category_Tbl_Type
)
IS
   l_return_sts		NUMBER		:=  0	 ;
   l_return_err		VARCHAR2(2000)  :=  NULL ;
BEGIN
   p_return_sts := 0 ;

   p_Cat_Create_Num := p_Cat_Create_Num + 1 ;
   p_Create_Cat_Tbl( p_Cat_Create_Num ).item_id  :=  p_item_id	;
   p_Create_Cat_Tbl( p_Cat_Create_Num ).org_id   :=  p_org_id	;


EXCEPTION
   WHEN OTHERS THEN
        p_Cat_Create_Num := 0 ;
   	p_return_sts := 1 ;
        l_return_err := 'BOM_PFI_PVT.Store_Cat_Create: ' || SQLERRM ;
        raise_application_error (-20000, l_return_err);

END Store_Cat_Create;

/****************************************************************************/

PROCEDURE Create_PF_Category
( 	p_return_sts		IN OUT NOCOPY NUMBER			,
	p_return_err		IN OUT NOCOPY VARCHAR2		,
	p_Cat_Create_Num	 IN OUT NOCOPY 	BINARY_INTEGER		,
	p_Create_Cat_Tbl	 IN OUT NOCOPY 	Create_Category_Tbl_Type
)
IS
   l_return_sts		NUMBER		:=  0	 ;
   l_return_err		VARCHAR2(2000)  :=  NULL ;
   l_item_id		NUMBER		;
   l_org_id		NUMBER		;
   l_concat_segments	VARCHAR2(2000)  :=  NULL ;
   l_category_id	NUMBER		;
   l_stmt_num		NUMBER	 :=  0	;
   CAT_NOT_INSERTED	EXCEPTION	;

   l_New_Category_ID	NUMBER		;
   l_Source_Lang	VARCHAR2(4)	;
   l_Description	VARCHAR2(240)  := 'Product family' ;

   v_user_id	VARCHAR2(20) ;
BEGIN
  v_user_id   := fnd_global.user_id;

   select userenv('LANG')
   into  l_Source_Lang
   from  dual ;

   IF ( SQL%NOTFOUND ) THEN
      RAISE no_data_found;
   END IF;

   p_return_sts := 0 ;

l_stmt_num := 1 ;

   -- Loop through each recorded product family item
   -- corresponding to category to be created
   --
   FOR l_Cat_Ind IN 1..p_Cat_Create_Num LOOP
   -----------------------------------------
      l_item_id  :=  p_Create_Cat_Tbl( l_Cat_Ind ).item_id ;
      l_org_id   :=  p_Create_Cat_Tbl( l_Cat_Ind ).org_id  ;

l_stmt_num := 2 ;

   BOM_PFI_PVT.Get_Category_ID
	( 	p_return_sts		=>	l_return_sts	,
		p_return_err		=>	l_return_err	,
		p_item_id		=>	l_item_id	,
		p_org_id		=>	l_org_id	 ,
		p_concat_segments	=>	l_concat_segments ,
		p_category_id		=>	l_category_id
	);

      IF ( l_return_sts = 0 ) THEN
         -- Do not insert if category already exists
         GOTO No_Insert;
      ELSIF ( l_return_sts <> 3 ) THEN
	 p_return_sts := 2 ;
         l_return_err := 'BOM_PFI_PVT.Create_PF_Category: ' || l_return_err ;
	 FND_MESSAGE.set_name('BOM', 'BOM_PFI_PVT_MSG');
	 FND_MESSAGE.set_token('MSG', l_return_err);
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

      -- Proceed  with insert if category does not exist (l_return_sts = 3)

l_stmt_num := 3 ;

   select  MTL_CATEGORIES_S.nextval
   into  l_New_Category_ID
   from  dual ;

   INSERT INTO MTL_CATEGORIES_B
   (
	CATEGORY_ID	,
	STRUCTURE_ID	,
	DISABLE_DATE	,
	SEGMENT1	,
	SEGMENT2	,
	SEGMENT3	,
	SEGMENT4	,
	SEGMENT5	,
	SEGMENT6	,
	SEGMENT7	,
	SEGMENT8	,
	SEGMENT9	,
	SEGMENT10	,
	SEGMENT11	,
	SEGMENT12	,
	SEGMENT13	,
	SEGMENT14	,
	SEGMENT15	,
	SEGMENT16	,
	SEGMENT17	,
	SEGMENT18	,
	SEGMENT19	,
	SEGMENT20	,
	SUMMARY_FLAG	,
	ENABLED_FLAG	,
	CREATION_DATE	,
	CREATED_BY	,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY	,
	LAST_UPDATE_LOGIN
   )
   SELECT
   	l_New_Category_ID		,
	BOM_PFI_PVT.G_PF_Structure_ID	,
	null		,
	SI.SEGMENT1	,
	SI.SEGMENT2	,
	SI.SEGMENT3	,
	SI.SEGMENT4	,
	SI.SEGMENT5	,
	SI.SEGMENT6	,
	SI.SEGMENT7	,
	SI.SEGMENT8	,
	SI.SEGMENT9	,
	SI.SEGMENT10	,
	SI.SEGMENT11	,
	SI.SEGMENT12	,
	SI.SEGMENT13	,
	SI.SEGMENT14	,
	SI.SEGMENT15	,
	SI.SEGMENT16	,
	SI.SEGMENT17	,
	SI.SEGMENT18	,
	SI.SEGMENT19	,
	SI.SEGMENT20	,
	'N'		,
	'Y'		,
	sysdate		,
	v_user_id	,
	sysdate		,
	v_user_id	,
	null
   FROM  MTL_SYSTEM_ITEMS_B  SI
   WHERE  INVENTORY_ITEM_ID = l_item_id
     AND  ORGANIZATION_ID   = l_org_id  ;

   IF ( SQL%NOTFOUND ) THEN
      RAISE CAT_NOT_INSERTED;
   END IF;

  insert into MTL_CATEGORIES_TL (
    CATEGORY_ID,
    LANGUAGE,
    SOURCE_LANG,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    l_New_Category_ID	,
    L.LANGUAGE_CODE	,
    l_Source_Lang	,
    l_Description	,
    sysdate	,
    v_user_id	,
    sysdate	,
    v_user_id	,
    null
  from  FND_LANGUAGES  L
  where  L.INSTALLED_FLAG in ('I', 'B')
    and  not exists
         ( select NULL
           from  MTL_CATEGORIES_TL  T
           where  T.CATEGORY_ID = l_New_Category_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE );

   <<No_Insert>>
   NULL;
   ----------------------------------------
   END LOOP;  -- recorded category creation

   -- Reset counter so the next execution will start new index count
   --
   p_Cat_Create_Num := 0 ;


EXCEPTION
   WHEN CAT_NOT_INSERTED THEN
      p_Cat_Create_Num := 0 ;
      p_return_sts := 1 ;
      l_return_err := 'BOM_PFI_PVT.Create_PF_Category: cannot insert category' ;
      raise_application_error (-20000, l_return_err);

   WHEN OTHERS THEN
      p_Cat_Create_Num := 0 ;
      IF ( SQLCODE = -20001 ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      ELSE
         p_return_sts := 4 ;
         l_return_err := 'BOM_PFI_PVT.Create_PF_Category: ' || SQLERRM ;
         raise_application_error (-20000, l_return_err);
      END IF;

END Create_PF_Category;

/****************************************************************************/

-- Record in PL/SQL table each product family item corresponding to a
-- category to be deleted.
--
PROCEDURE Store_Category
( 	p_return_sts		IN OUT NOCOPY NUMBER			,
	p_return_err		IN OUT NOCOPY VARCHAR2		,
	p_item_id		IN	NUMBER			,
	p_org_id		IN	NUMBER			,
	p_Cat_Num		 IN OUT NOCOPY 	BINARY_INTEGER		,
	p_Delete_Cat_Tbl	 IN OUT NOCOPY 	Delete_Category_Tbl_Type
)
IS
   l_return_sts		NUMBER		:=  0	 ;
   l_return_err		VARCHAR2(2000)  :=  NULL ;
BEGIN
   p_return_sts := 0 ;

   p_Cat_Num := p_Cat_Num + 1 ;
   p_Delete_Cat_Tbl( p_Cat_Num ).item_id  :=  p_item_id	;
   p_Delete_Cat_Tbl( p_Cat_Num ).org_id   :=  p_org_id	;


EXCEPTION
   WHEN OTHERS THEN
        p_Cat_Num := 0 ;
   	p_return_sts := 1 ;
        l_return_err := 'BOM_PFI_PVT.Store_Category: ' || SQLERRM ;
        raise_application_error (-20000, l_return_err);

END Store_Category;

/****************************************************************************/

PROCEDURE Delete_PF_Category
( 	p_return_sts		IN OUT NOCOPY NUMBER			,
	p_return_err		IN OUT NOCOPY VARCHAR2		,
	p_Cat_Num		 IN OUT NOCOPY 	BINARY_INTEGER		,
	p_Delete_Cat_Tbl	 IN OUT NOCOPY 	Delete_Category_Tbl_Type
)
IS
   l_return_sts		NUMBER	 	:=  0	 ;
   l_return_err		VARCHAR2(2000)  :=  NULL ;
   l_item_id		NUMBER		;
   l_org_id		NUMBER		;
   l_concat_segments	VARCHAR2(2000)  :=  NULL ;
   l_category_id	NUMBER		;
   l_stmt_num		NUMBER	 :=  0	;
BEGIN
   p_return_sts := 0 ;

l_stmt_num := 1 ;

   -- Loop through each recorded product family item
   -- corresponding to category to be deleted
   --
   FOR l_Cat_Ind IN 1..p_Cat_Num LOOP
   ----------------------------------
      l_item_id  :=  p_Delete_Cat_Tbl( l_Cat_Ind ).item_id ;
      l_org_id   :=  p_Delete_Cat_Tbl( l_Cat_Ind ).org_id  ;

l_stmt_num := 2 ;

   BOM_PFI_PVT.Get_Category_ID
	( 	p_return_sts		=>	l_return_sts	,
		p_return_err		=>	l_return_err	,
		p_item_id		=>	l_item_id	,
		p_org_id		=>	l_org_id	 ,
		p_concat_segments	=>	l_concat_segments ,
		p_category_id		=>	l_category_id
	);

      -- Do not rise exception when category ID is not found.
      -- The category could have not been created.

      IF ( l_return_sts = 0 ) THEN

      DELETE FROM  MTL_CATEGORIES_TL
      WHERE  CATEGORY_ID = l_category_id ;

      DELETE FROM  MTL_CATEGORIES_B
      WHERE  CATEGORY_ID = l_category_id ;

      ELSE
	 p_return_sts := 2 ;
         l_return_err := 'BOM_PFI_PVT.Delete_PF_Category: ' || l_return_err ;
      END IF;

   ----------------------------------------
   END LOOP;  -- recorded category deletion

   -- Reset deletion counter so the next execution will start new index count
   --
   p_Cat_Num := 0 ;


EXCEPTION
   WHEN OTHERS THEN
      p_Cat_Num := 0 ;
      p_return_sts := 4 ;
      l_return_err := 'BOM_PFI_PVT.Delete_PF_Category: ' || SQLERRM ;
      raise_application_error (-20000, l_return_err);

END Delete_PF_Category;

/****************************************************************************/

-- Record in PL/SQL table each item assignment to category/category set.
--
PROCEDURE Store_Cat_Assign
( 	p_return_sts		IN OUT NOCOPY NUMBER				,
	p_return_err		IN OUT NOCOPY VARCHAR2			,
	p_item_id		IN	NUMBER				,
	p_org_id		IN	NUMBER				,
	p_pf_item_id		IN	NUMBER				,
	p_Assign_Num		 IN OUT NOCOPY 	BINARY_INTEGER			,
	p_Cat_Assign_Tbl	 IN OUT NOCOPY 	Category_Assign_Tbl_Type
)
IS
   l_return_sts		NUMBER	 	:=  0	 ;
   l_return_err		VARCHAR2(2000)  :=  NULL ;
BEGIN
   p_return_sts := 0 ;

   p_Assign_Num := p_Assign_Num + 1 ;
   p_Cat_Assign_Tbl( p_Assign_Num ).item_id	:=  p_item_id	 ;
   p_Cat_Assign_Tbl( p_Assign_Num ).org_id	:=  p_org_id	 ;
   p_Cat_Assign_Tbl( p_Assign_Num ).pf_item_id	:=  p_pf_item_id ;


EXCEPTION
   WHEN OTHERS THEN
      p_Assign_Num := 0 ;
      p_return_sts := 1 ;
      l_return_err := 'BOM_PFI_PVT.Store_Cat_Assign: ' || SQLERRM ;
      raise_application_error (-20000, l_return_err);

END Store_Cat_Assign;

/****************************************************************************/

PROCEDURE Assign_To_Category
( 	p_return_sts		IN OUT NOCOPY NUMBER				,
	p_return_err		IN OUT NOCOPY VARCHAR2			,
	p_Assign_Num		 IN OUT NOCOPY 	BINARY_INTEGER			,
 	p_Cat_Assign_Tbl	 IN OUT NOCOPY 	Category_Assign_Tbl_Type
)
IS
   l_return_sts		NUMBER		:= 0	;
   l_return_err		VARCHAR2(2000)	:= NULL	;
   l_item_id		NUMBER		;
   l_org_id		NUMBER		;
   l_master_org_id	NUMBER		;
   l_pf_item_id		NUMBER		;
   l_concat_segments	VARCHAR2(2000)	:= NULL	;
   l_category_id	NUMBER	 :=  -1	;
   l_stmt_num		NUMBER	 :=  0	;
   v_user_id	VARCHAR2(20) ;
BEGIN
   v_user_id   := fnd_global.user_id;
   p_return_sts := 0 ;

   -- Loop through each recorded item assignment
   --
   FOR l_Assign_Ind IN 1..p_Assign_Num LOOP
   ----------------------------------------
      l_item_id     :=  p_Cat_Assign_Tbl( l_Assign_Ind ).item_id	;
      l_org_id      :=  p_Cat_Assign_Tbl( l_Assign_Ind ).org_id		;
      l_pf_item_id  :=  p_Cat_Assign_Tbl( l_Assign_Ind ).pf_item_id	;

l_stmt_num := 1 ;

   BOM_PFI_PVT.Get_Master_Org_ID
	( 	p_return_sts		=>	l_return_sts	,
		p_return_err		=>	l_return_err	,
		p_org_id		=>	l_org_id	,
		p_master_org_id		=>	l_master_org_id
	);

l_stmt_num := 2 ;

   BOM_PFI_PVT.Get_Category_ID
	( 	p_return_sts		=>	l_return_sts	,
		p_return_err		=>	l_return_err	,
		p_item_id		=>	l_pf_item_id	,
		p_org_id		=>	l_master_org_id	 ,
		p_concat_segments	=>	l_concat_segments ,
		p_category_id		=>	l_category_id
	);

      IF ( l_return_sts = 3 ) THEN
	 p_return_sts := 3 ;
	 FND_MESSAGE.set_name('BOM', 'BOM_PFI_PVT_CAT_ASSIGN');
	 FND_MESSAGE.set_token('CAT', l_concat_segments);
         APP_EXCEPTION.RAISE_EXCEPTION;
      ELSIF ( l_return_sts <> 0 ) THEN
	 p_return_sts := 2 ;
         l_return_err := 'Assign_To_Category: ' || l_return_err ;
	 FND_MESSAGE.set_name('BOM', 'BOM_PFI_PVT_MSG');
	 FND_MESSAGE.set_token('MSG', l_return_err);
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

l_stmt_num := 3 ;

   INSERT INTO MTL_ITEM_CATEGORIES
   (	INVENTORY_ITEM_ID	,
	ORGANIZATION_ID		,
	CATEGORY_SET_ID		,
	CATEGORY_ID		,
	CREATION_DATE		,
	CREATED_BY		,
	LAST_UPDATE_DATE	,
	LAST_UPDATED_BY		,
	LAST_UPDATE_LOGIN
   )
   SELECT
	l_item_id		,
	l_org_id		,
	G_PF_Category_Set_ID	,
	l_category_id		,
	sysdate			,
	v_user_id		,
	sysdate			,
	v_user_id		,
	null
   FROM  dual
   WHERE NOT EXISTS
	( SELECT 'x'
	  FROM   MTL_ITEM_CATEGORIES icat
	  WHERE  icat.INVENTORY_ITEM_ID	= l_item_id
	    AND  icat.ORGANIZATION_ID	= l_org_id
	    AND  icat.CATEGORY_SET_ID	= G_PF_Category_Set_ID
	);

   --------------------------------------
   END LOOP;  -- recorded item assignment

   -- Reset assignment counter so the next execution will start new index count
   --
   p_Assign_Num := 0 ;


EXCEPTION
   WHEN OTHERS THEN
      p_Assign_Num := 0 ;
      IF ( SQLCODE = -20001 ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      ELSE
	 p_return_sts := 4 ;
         l_return_err := 'BOM_PFI_PVT.Assign_To_Category: ' || SQLERRM ;
         raise_application_error (-20000, l_return_err);
      END IF;

END Assign_To_Category;

/****************************************************************************/

PROCEDURE Remove_From_Category
( 	p_return_sts		IN OUT NOCOPY NUMBER		,
	p_return_err		IN OUT NOCOPY VARCHAR2	,
	p_item_id		IN	NUMBER		,
	p_org_id		IN	NUMBER
)
IS
   l_return_sts		NUMBER		:=  0	 ;
   l_return_err		VARCHAR2(2000)  :=  NULL ;
   ITEM_CAT_NOTFOUND	EXCEPTION		 ;
BEGIN
   p_return_sts := 0 ;

   DELETE FROM MTL_ITEM_CATEGORIES
   WHERE  INVENTORY_ITEM_ID = p_item_id
     AND  ORGANIZATION_ID = p_org_id
     AND  CATEGORY_SET_ID = G_PF_Category_Set_ID ;

-- Do not rise exception when item assignment to category is not found.
-- Item could have been removed from the category by the user.
/* IF ( SQL%NOTFOUND ) THEN
      RAISE ITEM_CAT_NOTFOUND;
   END IF;
*/

EXCEPTION
/*
   WHEN ITEM_CAT_NOTFOUND THEN
        p_return_sts := 1 ;
        p_return_err := 'Remove_From_Category: Item assignment not found.' ;
*/
   WHEN OTHERS THEN
        p_return_sts := 2 ;
        l_return_err := 'BOM_PFI_PVT.Remove_From_Category: ' || SQLERRM ;
        raise_application_error (-20000, l_return_err);

END Remove_From_Category;

/****************************************************************************/

PROCEDURE Get_Category_ID
( 	p_return_sts		IN OUT NOCOPY NUMBER		,
	p_return_err		IN OUT NOCOPY VARCHAR2	,
	p_item_id		IN	NUMBER		,
	p_org_id		IN	NUMBER		,
	p_concat_segments	IN OUT NOCOPY VARCHAR2	,
	p_category_id		IN OUT NOCOPY NUMBER
)
IS
   l_return_sts		NUMBER	 :=  0	;
   l_return_err		VARCHAR2(2000)	;
   l_concat_segments	VARCHAR2(2000)	;
   l_stmt_num		NUMBER	 :=  0	;
BEGIN
   p_return_sts := 0 ;

l_stmt_num := 2 ;

   IF FND_FLEX_KEYVAL.validate_ccid
	(	appl_short_name		=>	'INV'				,
	 	key_flex_code		=>	'MSTK'				,
	 	structure_number	=>	BOM_PFI_PVT.G_MSTK_Structure_ID	,
	 	combination_id		=>	p_item_id			,
	 	data_set		=>	p_org_id
	)
   THEN
      l_concat_segments := FND_FLEX_KEYVAL.concatenated_values ;
      p_concat_segments := l_concat_segments ;
   ELSE
      p_return_sts := 2 ;
      p_return_err := 'Get_Category_ID: Table MTL_SYSTEM_ITEMS_B, flexfield MSTK: ' ||
		      FND_FLEX_KEYVAL.error_message ;
      RETURN;
   END IF;

l_stmt_num := 3 ;

   IF FND_FLEX_KEYVAL.validate_segs
	(	operation		=>	'FIND_COMBINATION'		,
		appl_short_name		=>	'INV'				,
	 	key_flex_code		=>	'MCAT'				,
	 	structure_number	=>	BOM_PFI_PVT.G_PF_Structure_ID	,
		concat_segments		=>	l_concat_segments
	)
   THEN
      p_category_id := FND_FLEX_KEYVAL.combination_id ;
   ELSE
      p_return_sts := 3 ;
      p_return_err := 'Get_Category_ID: Table MTL_CATEGORIES_B, flexfield MCAT: ' ||
		      FND_FLEX_KEYVAL.error_message ;
      RETURN;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
        p_return_sts := 4 ;
        p_return_err := 'Get_Category_ID: ' || SQLERRM ;

END Get_Category_ID;

/****************************************************************************/

PROCEDURE Get_Master_Org_ID
( 	p_return_sts		IN OUT NOCOPY NUMBER		,
	p_return_err		IN OUT NOCOPY VARCHAR2	,
	p_org_id		IN NUMBER		,
	p_master_org_id		IN OUT NOCOPY NUMBER
)
IS
   l_return_sts		NUMBER		:=  0	 ;
   l_return_err		VARCHAR2(2000)  :=  NULL ;
   l_master_org_id	NUMBER			 ;
BEGIN

   SELECT MASTER_ORGANIZATION_ID  INTO  l_master_org_id
   FROM  MTL_PARAMETERS
   WHERE  ORGANIZATION_ID = p_org_id ;

   p_master_org_id := l_master_org_id ;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
        l_return_err := to_char( p_org_id );
	FND_MESSAGE.set_name('BOM', 'BOM_PFI_PVT_NOTFOUND');
	FND_MESSAGE.set_token('PROC', 'Get_Master_Org_ID');
	FND_MESSAGE.set_token('ENTITY', 'ORG_ID ' || l_return_err);
        APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
        l_return_err := 'Get_Master_Org_ID:' || SQLERRM ;
        raise_application_error (-20000, l_return_err);

END Get_Master_Org_ID;

/****************************************************************************/

FUNCTION Org_Is_Master
(	p_org_id	IN	NUMBER
)
RETURN	BOOLEAN
IS
   l_return_err		VARCHAR2(2000)	;
   l_master_org_id	NUMBER		;
BEGIN

   SELECT MASTER_ORGANIZATION_ID  INTO  l_master_org_id
   FROM  MTL_PARAMETERS
   WHERE  ORGANIZATION_ID = p_org_id ;

   IF ( l_master_org_id = p_org_id ) THEN
      RETURN  TRUE;
   ELSE
      RETURN  FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RETURN  FALSE;

END Org_Is_Master;

/****************************************************************************/

PROCEDURE Check_PF_Segs
IS
   l_MSI_segs		VARCHAR2(40)	:= NULL ;
   l_PF_segs		VARCHAR2(40)	:= NULL ;

   CURSOR MSI_Struct_Segs IS
        select application_column_name
        from FND_ID_FLEX_SEGMENTS
        where application_id = 401
          and id_flex_code = 'MSTK'
          and id_flex_num = 101
          and enabled_flag = 'Y'
        order by segment_num;

   CURSOR PF_Struct_Segs IS
        select application_column_name
        from FND_ID_FLEX_SEGMENTS
        where application_id = 401
          and id_flex_code = 'MCAT'
          and id_flex_num = G_PF_Structure_ID
          and enabled_flag = 'Y'
        order by segment_num;

BEGIN
   BOM_PFI_PVT.PF_Segs_Status := BOM_PFI_PVT.G_PF_Segs_Status_OK;

   OPEN MSI_Struct_Segs;
   OPEN PF_Struct_Segs;
   LOOP
      FETCH MSI_Struct_Segs into l_MSI_segs;
      FETCH PF_Struct_Segs into l_PF_segs;

      IF ( MSI_Struct_Segs%NOTFOUND and PF_Struct_Segs%NOTFOUND )
      THEN
         EXIT;
      ELSIF ( MSI_Struct_Segs%FOUND and PF_Struct_Segs%FOUND )
      THEN
         IF NOT (l_PF_segs = l_MSI_segs) THEN
            BOM_PFI_PVT.PF_Segs_Status := BOM_PFI_PVT.G_PF_Segs_Status_Mismatch;
            EXIT;
         END IF;
      ELSE
         IF ( l_PF_segs is null ) THEN
            BOM_PFI_PVT.PF_Segs_Status := BOM_PFI_PVT.G_PF_Segs_Status_Undefined;
         ELSE
            BOM_PFI_PVT.PF_Segs_Status := BOM_PFI_PVT.G_PF_Segs_Status_Mismatch;
         END IF;
         EXIT;
      END IF;
   END LOOP;
   CLOSE MSI_Struct_Segs;
   CLOSE PF_Struct_Segs;

   IF ( BOM_PFI_PVT.PF_Segs_Status = BOM_PFI_PVT.G_PF_Segs_Status_Mismatch )
   THEN
      BOM_PFI_PVT.PF_Segs_Status := BOM_PFI_PVT.G_PF_Segs_Status_OK;
      FND_MESSAGE.set_name('INV', 'INV_BOM_PFI_SEGS_MISMATCH');
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

END Check_PF_Segs;

/****************************************************************************/

FUNCTION PF_Segs_Undefined
RETURN	BOOLEAN
IS
BEGIN
   IF ( BOM_PFI_PVT.PF_Segs_Status = BOM_PFI_PVT.G_PF_Segs_Status_Undefined )
   THEN
      BOM_PFI_PVT.PF_Segs_Status := BOM_PFI_PVT.G_PF_Segs_Status_OK;
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

END PF_Segs_Undefined;

/****************************************************************************/

END BOM_PFI_PVT;

/
