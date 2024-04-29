--------------------------------------------------------
--  DDL for Package Body PO_CATEGORIES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CATEGORIES_SV1" AS
/* $Header: POXPICTB.pls 120.0.12000000.1 2007/01/16 23:03:11 appldev ship $ */

/*================================================================

  FUNCTION NAME: 	val_item_category_id()

==================================================================*/
 FUNCTION val_item_category_id(x_category_id      IN NUMBER,
                               x_item_id          IN NUMBER,
                               x_organization_id  IN NUMBER) RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* first find out the default category_set_id for function_area of
      "PURCHASING", then validate if X_category_id belong to the X_item
    */

   SELECT count(*)
     INTO x_temp
     FROM mtl_item_categories mic,
          mtl_categories mcs
    WHERE mic.category_id = mcs.category_id
      AND mic.category_set_id = (SELECT category_set_id
                                   FROM mtl_default_category_sets
                                  WHERE functional_area_id = 2 /* 2=purchasing*/)
      AND mic.category_id = x_category_id
      AND mic.inventory_item_id = x_item_id
      AND mic.organization_id = x_organization_id
      AND sysdate < nvl(mcs.disable_date, sysdate+1)
      AND mcs.enabled_flag = 'Y';

   IF x_temp = 0 THEN
      RETURN FALSE;   /* validation fails */
   ELSE
      RETURN TRUE;    /* validation succeeds */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_item_category_id', x_progress, sqlcode);
        raise;
 END val_item_category_id;

/*================================================================

  FUNCTION NAME: 	derive_category_id()

==================================================================*/
FUNCTION  derive_category_id(X_category IN VARCHAR2)
return NUMBER IS

X_progress        varchar2(3)     := NULL;
X_category_id_v   number          := NULL;
ret_code          NUMBER         :=  0;
x_category_set_id number;
x_err_text        VARCHAR2(2000);
x_structure_id    number;
x_category_id     number;

BEGIN

 X_progress := '010';

 /* bug 609728 added join to mcs and mdcs to get the default category_set and structure_id */
/*Bug1730946
  Bcos of a performance issue  splitting the below query
  and calling the BOM api to achieve the same functionality.

  get the category_id from mtl_categories_kfv based on x_category
 SELECT category_id
   INTO X_category_id_v
   FROM mtl_categories_kfv mck, mtl_category_sets mcs, mtl_default_category_sets mdcs
  WHERE concatenated_segments = X_category
    AND mck.structure_id = mcs.structure_id
    AND mcs.category_set_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 2;
BUG 1760539
  THE PERFORMANCE WITH THE BOM API WAS NOT GOOD EITHER AND SO
  USING THE FLEX API INSTEAD
   ret_code := INVPUOPI.mtl_pr_parse_flex_name

*/
   select structure_id
   into   x_structure_id
   from   mtl_default_category_sets mdcs,mtl_category_sets_b mcsb
   where  mdcs.functional_area_id = 2  /* 2 = Purchasing */
   and    mdcs.category_set_id = mcsb.category_set_id;

  ret_code := FND_FLEX_EXT.GET_CCID('INV', 'MCAT', x_structure_id, to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'),x_category);

            IF (( ret_code is not null) and (ret_code <> 0 )) THEN
               X_category_id_v := ret_code;
            ELSE
               X_category_id_v := null;
            END IF;


 RETURN X_category_id_v;

EXCEPTION
   When no_data_found then
        RETURN NULL;
   When others then
        po_message_s.sql_error('derive_category_id',X_progress, sqlcode);
        raise;

END derive_category_id;

/*================================================================

  FUNCTION NAME: 	get_default_purch_category_id()

==================================================================*/
FUNCTION  get_default_purch_category_id return NUMBER IS

   X_progress     varchar2(3)     := NULL;
   X_category_id  number;

BEGIN

   X_progress := '010';
   /* get the default category_id */

   SELECT	 mcs.default_category_id
   INTO		 X_category_id
   FROM		 mtl_category_sets mcs,
		 mtl_default_category_sets mdcs
   WHERE	 mdcs.functional_area_id = 2  /* 2= purchasing */
   AND		 mdcs.category_set_id = mcs.category_set_id;

   RETURN X_category_id;

EXCEPTION
   When no_data_found then
        RETURN NULL;
   When others then
        po_message_s.sql_error('get_default_purch_category_id',
                    X_progress, sqlcode);
        raise;

END get_default_purch_category_id;

/*================================================================

  FUNCTION NAME:        get_default_purch_category_id()

==================================================================*/
 FUNCTION val_category_id(x_category_id      IN NUMBER)
 RETURN BOOLEAN IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer := 0;
-- Bug# 3129778
   x_validate_flag   mtl_category_sets_v.validate_flag%TYPE;

 BEGIN
   x_progress := '010';

   /** validate and make sure x_category_id is a valid category
   within the default category set for Purchasing. **/
   /* Bug# 3129778,  We will check if the Purchasing Category set
   has 'Validate flag' ON. If Yes, we will validate the Category
   to exist in the 'Valid Category List'. If No, we will just validate
   if the category is Enable and Active */

   BEGIN
     SELECT validate_flag
     INTO x_validate_flag
     FROM mtl_category_sets_v
     WHERE category_set_id=
                (SELECT   category_set_id
                 FROM     mtl_default_category_sets
                 WHERE    functional_area_id = 2   /*** purchasing ***/
                ) ;
   EXCEPTION
     when others then
         NULL;
   END;

  IF x_validate_flag = 'Y' then

     SELECT count(*)
     INTO x_temp
     FROM mtl_categories_vl mcs,
          mtl_category_set_valid_cats mcsvc
    WHERE mcs.category_id = x_category_id
      AND mcs.category_id = mcsvc.category_id
      AND mcsvc.category_set_id =
                (SELECT   category_set_id
                 FROM     mtl_default_category_sets
                 WHERE    functional_area_id = 2   /*** purchasing ***/
                )
      AND sysdate < nvl(mcs.disable_date, sysdate+1)
      AND mcs.enabled_flag = 'Y';

      IF x_temp = 0 THEN
          RETURN FALSE;   /* validation fails */
      ELSE
          RETURN TRUE;    /* validation succeeds */
      END IF;

   ELSE

     SELECT count(*)
     INTO x_temp
     FROM mtl_categories_vl mcs
    WHERE mcs.category_id = x_category_id
      AND sysdate < nvl(mcs.disable_date, sysdate+1)
      AND mcs.enabled_flag = 'Y';

      IF x_temp = 0 THEN
          RETURN FALSE;   /* validation fails */
      ELSE
          RETURN TRUE;    /* validation succeeds */
      END IF;

   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_category_id', x_progress, sqlcode);
        raise;
 END val_category_id;

END PO_CATEGORIES_SV1;

/
