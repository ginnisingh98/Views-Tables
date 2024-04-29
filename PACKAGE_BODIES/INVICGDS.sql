--------------------------------------------------------
--  DDL for Package Body INVICGDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVICGDS" AS
/* $Header: INVICGDB.pls 120.2 2005/10/18 03:44:14 swshukla ship $ */

PROCEDURE inv_update_item_desc(
inv_item_id                 IN    NUMBER   DEFAULT  NULL,
org_id                      IN    NUMBER   DEFAULT  NULL,
first_elem_break            IN    NUMBER   DEFAULT  30,
use_name_as_first_elem      IN    VARCHAR2 DEFAULT  'N',
delimiter                   IN    VARCHAR2 DEFAULT  NULL,
show_all_delim              IN    VARCHAR2 DEFAULT  'Y'
)
IS

  delim_val          VARCHAR2(1);
  new_description    VARCHAR2(240);
  new_error_text     VARCHAR2(240);
  counter            NUMBER;
  desc_control_level NUMBER;
  master_org_id_val  NUMBER;

  /* This cursor gets all child item rows for a given III and org*/

  CURSOR get_item_rows(iii NUMBER, org NUMBER) IS
    SELECT inventory_item_id, organization_id--, description
      FROM mtl_system_items_B MSI
     WHERE (MSI.inventory_item_id = iii OR iii IS NULL)
       AND (MSI.organization_id = org OR org IS NULL)
       AND MSI.ITEM_CATALOG_GROUP_ID is NOT NULL;

  /* This cursor gets all child item rows for a given III and master org
     Note: it also returns the master org row;  a master org is its own child*/
/*
  CURSOR get_child_item_rows(iii NUMBER, m_org NUMBER) IS
    SELECT inventory_item_id, organization_id, description
      FROM mtl_system_items_VL MSI
     WHERE MSI.inventory_item_id = NVL(iii, MSI.inventory_item_id)
       AND MSI.item_catalog_group_id is NOT NULL
       AND MSI.organization_id in (SELECT organization_id
                                     FROM mtl_parameters mp
                                    WHERE mp.master_organization_id = m_org);
*/
  CURSOR get_child_item_rows(iii NUMBER, m_org NUMBER) IS
    SELECT inventory_item_id, organization_id
      FROM mtl_system_items_B MSI
     WHERE MSI.inventory_item_id = iii
       AND EXISTS (SELECT NULL
                     FROM mtl_parameters mp
                    WHERE mp.master_organization_id = m_org
		      AND MSI.organization_id = mp.organization_id);


  l_INSTALLED_FLAG  VARCHAR2(1);

BEGIN

  -- Identify the current session language as Base ('B') or Installed ('I')
  --
  select INSTALLED_FLAG
  into   l_INSTALLED_FLAG
  from  FND_LANGUAGES
  where  LANGUAGE_CODE = userenv('LANG');

 /*Get the delimiter if needed..will have to do this only once
   now and pass the value to the inv_get_icg_desc procedure*/

 IF (delimiter is NULL) THEN
  SELECT FT.concatenated_segment_delimiter INTO delim_val
  FROM fnd_id_flex_structures FT
  WHERE FT.ID_FLEX_CODE = 'MICG'
    AND FT.APPLICATION_ID = 401;
  ELSE
    delim_val := delimiter;
  END IF;

 counter := 1;
 FOR gir in get_item_rows(inv_item_id, org_id) LOOP

       INVICGDS.inv_get_icg_desc(gir.inventory_item_id,
				 first_elem_break,
				 use_name_as_first_elem,
				 delim_val,
				 show_all_delim,
				 new_description,
				 new_error_text);

        SELECT mp.master_organization_id INTO master_org_id_val
        FROM  mtl_parameters mp
        WHERE mp.organization_id = gir.organization_id;

        SELECT mia.control_level INTO desc_control_level
        FROM  mtl_item_attributes mia
        WHERE attribute_name = 'MTL_SYSTEM_ITEMS.DESCRIPTION';

    IF master_org_id_val = gir.organization_id THEN

          IF desc_control_level = 1 THEN  /*item level: update all children*/

             FOR  gcir in get_child_item_rows( gir.inventory_item_id,
                                               gir.organization_id )
             LOOP

		UPDATE  mtl_system_items_B  MSI
		SET
                   MSI.description = decode(l_INSTALLED_FLAG,'B', new_description, MSI.description)
		WHERE MSI.inventory_item_id = gcir.inventory_item_id
		  AND MSI.organization_id = gcir.organization_id;

  --
  -- R11.5 MLS
  --
  update MTL_SYSTEM_ITEMS_TL
  set
     DESCRIPTION = new_description
--  ,  LAST_UPDATE_DATE  =  l_sysdate
--  ,  LAST_UPDATED_BY   =  user_id
--  ,  LAST_UPDATE_LOGIN =  login_id
  ,  SOURCE_LANG = userenv('LANG')
  where  INVENTORY_ITEM_ID = gcir.inventory_item_id
    and  ORGANIZATION_ID = gcir.organization_id
    and  userenv('LANG') in (LANGUAGE, SOURCE_LANG) ;

             END LOOP;

          ELSIF desc_control_level = 2 THEN

		UPDATE  mtl_system_items_B  MSI
		   SET
                      MSI.description = decode(l_INSTALLED_FLAG,'B', new_description, MSI.description)
		 WHERE MSI.inventory_item_id = gir.inventory_item_id
		   AND MSI.organization_id = gir.organization_id;

  --
  -- R11.5 MLS
  --
  update MTL_SYSTEM_ITEMS_TL
  set
     DESCRIPTION = new_description
--  ,  LAST_UPDATE_DATE  =  l_sysdate
--  ,  LAST_UPDATED_BY   =  user_id
--  ,  LAST_UPDATE_LOGIN =  login_id
  ,  SOURCE_LANG = userenv('LANG')
  where  INVENTORY_ITEM_ID = gir.inventory_item_id
    and  ORGANIZATION_ID = gir.organization_id
    and  userenv('LANG') in (LANGUAGE, SOURCE_LANG) ;

          ELSE
                null; /*error in control level*/

          END IF;

    ELSIF master_org_id_val <>  gir.organization_id THEN /*child org*/

          IF desc_control_level = 1 THEN  /*item level:do nothing */
                NULL;

          ELSIF desc_control_level = 2 THEN

		UPDATE  mtl_system_items_B  MSI
		   SET
                      MSI.description = decode(l_INSTALLED_FLAG,'B', new_description, MSI.description)
		 WHERE MSI.inventory_item_id = gir.inventory_item_id
		   AND MSI.organization_id = gir.organization_id;

  --
  -- R11.5 MLS
  --
  update MTL_SYSTEM_ITEMS_TL
  set
     DESCRIPTION = new_description
--  ,  LAST_UPDATE_DATE  =  l_sysdate
--  ,  LAST_UPDATED_BY   =  user_id
--  ,  LAST_UPDATE_LOGIN =  login_id
  ,  SOURCE_LANG = userenv('LANG')
  where  INVENTORY_ITEM_ID = gir.inventory_item_id
    and  ORGANIZATION_ID = gir.organization_id
    and  userenv('LANG') in (LANGUAGE, SOURCE_LANG) ;

          ELSE
                null; /*error in control level*/
          END IF;

    END IF;

    /* Intermittent commit logic*/
    counter := counter + 1;
    IF counter > 100 THEN
       commit;
       counter :=1;
    END IF;

 END LOOP;

 commit;

EXCEPTION
  WHEN NO_DATA_FOUND then
    null;

  WHEN others THEN
    rollback;  /*Note: the rows already commited will still remain
                No error mechanism.
                No place holder to return SQLCODE or SQLERRM
                The design called for a bare-bones mass update script
                runnable from the SQL> prompt
              */

END inv_update_item_desc;


FUNCTION inv_fn_get_icg_desc(
inv_item_id                 IN    NUMBER,
first_elem_break            IN    NUMBER   DEFAULT 30,
use_name_as_first_elem      IN    VARCHAR2 DEFAULT 'N',
delimiter                   IN    VARCHAR2 DEFAULT NULL,
show_all_delim              IN    VARCHAR2 DEFAULT 'Y',
show_error_flag             IN    VARCHAR2 DEFAULT 'Y'
) return VARCHAR2 IS

descr     VARCHAR2(240);
desc_err  VARCHAR2(240);
dummy_err VARCHAR2(240);
errtxt    VARCHAR2(240);

BEGIN
errtxt := NULL;

INVICGDS.inv_get_icg_desc(inv_item_id,
			  first_elem_break,
			  use_name_as_first_elem,
			  delimiter,
			  show_all_delim,
			  descr,
			  errtxt);

 IF (errtxt IS NOT NULL) then
                              /*Some error has occured somewhere in
                              **the inv_get_icg_desc call
                              ** Show error if the flag is Y
                              */
  IF (show_error_flag = 'Y') THEN
     return(errtxt);
  ELSE
     return(NULL);
  END IF;
 ELSE
  return(descr);
 END IF;

EXCEPTION
 WHEN OTHERS THEN
  IF (show_error_flag = 'Y') THEN
    dummy_err := 'INVICGDS(2):'||SQLCODE||':'||substrb(SQLERRM, 1,30)||errtxt ;
    desc_err := substr( dummy_err, 1, 240);
    return(desc_err);
  ELSE
    return(NULL);
  END IF;

END inv_fn_get_icg_desc;


PROCEDURE inv_get_icg_desc(
inv_item_id                 IN    NUMBER,
first_elem_break            IN    NUMBER   DEFAULT 30,
use_name_as_first_elem      IN    VARCHAR2 DEFAULT 'N',
delimiter                   IN    VARCHAR2 DEFAULT NULL,
show_all_delim              IN    VARCHAR2 DEFAULT 'Y',
description_for_item       OUT    NOCOPY VARCHAR2,
error_text                 IN OUT    NOCOPY VARCHAR2
) IS
icg_id_val     NUMBER;
c_desc_el_values VARCHAR2(240);
icg_desc_or_name VARCHAR2(240);
dummyerr         VARCHAR2(500);
delim_val        VARCHAR2(1);
l1               NUMBER;
l2               NUMBER;
LEN1             NUMBER;
LEN2             NUMBER;
excess1          NUMBER;
excess2          NUMBER;

l_inv_debug_level NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452

BEGIN
   /*First of all check to see if the item has an ICG defined for it
   **There is no point in proceeding further if there is no ICG for the item
   */
   BEGIN
	 SELECT item_catalog_group_id INTO icg_id_val
	   FROM mtl_system_items_B MSI
	  WHERE MSI.inventory_item_id = inv_item_id
	    AND rownum =1;
	  /*added rownum clause because this stmt may return more than one
	    identical rows*/
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
         description_for_item := NULL;
         error_text := NULL;
         raise NO_DATA_FOUND; /* to be handled by enclosing block*/
       WHEN OTHERS THEN
         dummyerr:= error_text|| ' INVICGDS(3-1): '||SQLCODE||':'
                                                ||substrb(SQLERRM,1,30);
         error_text := substr(dummyerr, 1, 240);
   END;

c_desc_el_values := NULL;
icg_desc_or_name := NULL;

INVICGDS.inv_concat_desc_values(
                   inv_item_id,
                   icg_id_val,
                   delimiter,
                   show_all_delim,
                   c_desc_el_values,
                   error_text);

IF  (use_name_as_first_elem = 'Y') THEN
    SELECT MICGK.concatenated_segments into icg_desc_or_name
      FROM mtl_item_catalog_groups_kfv MICGK
     WHERE MICGK.item_catalog_group_id = icg_id_val;

ELSIF (use_name_as_first_elem = 'N') THEN
    SELECT MICG.description into icg_desc_or_name
      FROM mtl_item_catalog_groups MICG
     WHERE MICG.item_catalog_group_id = icg_id_val;
ELSE
 error_text:= error_text||' INVICGDS(3-2): use_name_as_first_elem should be Y/N';
 /*Error in parameter*/
END IF;

IF (delimiter is NULL) THEN
  SELECT FT.concatenated_segment_delimiter INTO delim_val
  FROM fnd_id_flex_structures FT
  WHERE FT.ID_FLEX_CODE = 'MICG'
    AND FT.APPLICATION_ID = 401;
  ELSE
    delim_val := delimiter;
  END IF;


IF (icg_desc_or_name is not NULL) THEN

 l1:= length(icg_desc_or_name);
 LEN1:= first_elem_break;
 excess1:= LEN1 - l1;
 l2:= length(c_desc_el_values);
 LEN2:= 240 - LEN1;
 excess2:= LEN2 - l2;

    IF l_inv_debug_level IN(101, 102) THEN
       INVPUTLI.info('info'||l1|| ' '||LEN1 || ' '|| excess1);
       INVPUTLI.info('info'||l2|| ' '|| LEN2|| ' '|| excess2);
    END IF;

 IF (l1 = LEN1 OR  l2 = LEN2) THEN
   icg_desc_or_name := substr(icg_desc_or_name, 1, least(LEN1, l1));
   c_desc_el_values := substr(c_desc_el_values, 1, least(LEN2, l2));
 ELSIF (l1 > LEN1 AND l2 < LEN2) THEN
   icg_desc_or_name := substr(icg_desc_or_name, 1, least(LEN1 + excess2 , l1));
 ELSIF (l1 < LEN1 AND l2 > LEN2) THEN
   c_desc_el_values := substr(c_desc_el_values, 1, least(LEN2 + excess1 , l2));
 ELSIF (l1 > LEN1 AND l2 > LEN2) THEN
   icg_desc_or_name := substr(icg_desc_or_name, 1, LEN1);
   c_desc_el_values := substr(c_desc_el_values, 1, LEN2);
 ELSE
     /*(l1 < LEN1 AND l2 < LEN2) do nothing*/
   null;
 END IF;

  description_for_item := icg_desc_or_name||c_desc_el_values;

ELSE  /*icg_desc_or_name is null
        assign c_desc_el_values to description_for_item
        but take out the leading delimiter */

  description_for_item := substr(c_desc_el_values, 2, 240);

END IF;

<<get_out>>
NULL;

EXCEPTION
 WHEN NO_DATA_FOUND THEN NULL;
 /*This basically handles the subblock returned no_data_found
   We found that using user defined exception did not work (pl/sql bug?)
   The first select stmt is the one MOST likely to get caught in
   no_data_found.
   If data found there the other selects are pretty much guaranteed
   to work okay
 */

 WHEN OTHERS THEN
  dummyerr:= error_text|| ' INVICGDS(3-3): '||SQLCODE||':'
                         ||substrb(SQLERRM,1,30);
  error_text := substr(dummyerr, 1, 240);

END inv_get_icg_desc;


PROCEDURE inv_concat_desc_values(
   inv_item_id                  IN  NUMBER,
   icg_id                       IN  NUMBER,
   delimiter                    IN  VARCHAR2 DEFAULT NULL,
   show_all_delim               IN  VARCHAR2 DEFAULT 'Y',
   concat_desc                  OUT NOCOPY VARCHAR2,
   err_text                     IN OUT NOCOPY VARCHAR2
 ) IS

  c_desc      VARCHAR2(240);
  dummyerr    VARCHAR2(500);
  delim_val   VARCHAR2(1);
  first_elem_val  NUMBER;

  CURSOR get_desc_elem( iii NUMBER) IS
    SELECT element_name, element_value, element_sequence
      FROM mtl_descr_element_values MDEV
     WHERE MDEV.inventory_item_id = iii
       AND MDEV.default_element_flag = 'Y'
       ORDER BY element_sequence;

  CURSOR get_not_null_desc_elem( iii NUMBER) IS
    SELECT element_name, element_value, element_sequence
      FROM mtl_descr_element_values MDEV
     WHERE MDEV.inventory_item_id = iii
       AND MDEV.default_element_flag = 'Y'
       AND MDEV.element_value is not NULL
       ORDER BY element_sequence;

BEGIN

    IF (delimiter is NULL) THEN
      SELECT FT.concatenated_segment_delimiter INTO delim_val
        FROM fnd_id_flex_structures FT
       WHERE FT.ID_FLEX_CODE = 'MICG'
         AND FT.APPLICATION_ID = 401;
    ELSE
       delim_val := delimiter;
    END IF;

    c_desc := delim_val;   /*Initialize c_desc to delimiter*/

     first_elem_val := 1;

     IF  (show_all_delim = 'Y') then
       FOR  gde IN get_desc_elem(inv_item_id) LOOP
            if first_elem_val = 1 then
              c_desc := delim_val||gde.element_value;
              first_elem_val := 0;
            else
              c_desc := c_desc||delim_val||gde.element_value;
            end if;
      END LOOP;

     ELSIF (show_all_delim = 'N') then
       /*Same logic as above but with a different cursor*/
       FOR  gde IN get_not_null_desc_elem(inv_item_id) LOOP
            if first_elem_val = 1 then
              c_desc := delim_val||gde.element_value;
              first_elem_val := 0;
            else
              c_desc := c_desc||delim_val||gde.element_value;
            end if;
      END LOOP;

      ELSE
      c_desc:= 'Error: show_all_delim in inv_concat_desc_values should be Y/N';

      END IF;
    concat_desc := c_desc;

EXCEPTION
 WHEN OTHERS THEN
 dummyerr := err_text||'INVICGDS(4):'||SQLCODE||':'||substrb(SQLERRM, 1,30);
 err_text := substr(dummyerr, 1, 240);

END inv_concat_desc_values;


END INVICGDS;

/
