--------------------------------------------------------
--  DDL for Package Body EDW_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ITEMS_PKG" AS
/* $Header: ENIITEMB.pls 115.4 2004/01/30 21:44:36 sbag noship $  */

PROCEDURE initialize_parents;

TYPE parent_org_r_t IS RECORD (
  parent_org NUMBER,
  child_org NUMBER
);

TYPE parent_org_t_t is TABLE OF parent_org_r_t INDEX BY BINARY_INTEGER;
parent_org_t parent_org_t_t;

g_initialized number := 0;

Function Item_Org_FK(
        p_inventory_item_id             in NUMBER,
        p_organization_id               in NUMBER,
        p_item_description              in varchar2 DEFAULT null,
        p_item_category                 in varchar2 DEFAULT null,
        p_instance_code					in varchar2 DEFAULT null)
                                        return VARCHAR2 IS

  l_instance_code  edw_local_instance.instance_code%TYPE;
  l_item_category  mtl_categories_kfv.category_id%TYPE;

  cursor c1 is
  select instance_code
  from edw_local_instance;

  cursor c2 is
  select category_id
  from mtl_categories_kfv
  where concatenated_segments = p_item_category;

BEGIN

  IF p_organization_id = -1 THEN

    return 'NA_EDW';

  END IF;

  OPEN c2;
  FETCH c2 INTO l_item_category;
  CLOSE c2;

  if p_instance_code is null then

	OPEN c1;
	FETCH c1 INTO l_instance_code;
	CLOSE c1;

  else

    l_instance_code := p_instance_code;

  end if;

    if p_inventory_item_id is null and p_item_description is not null
	  and p_organization_id is not null then

	  return (p_item_description||'-'||l_item_category||'-'||
		p_organization_id||'-'||l_instance_code||'-ONETIME-IORG');

    else

      return (p_inventory_item_id||'-'||p_organization_id||'-'||l_instance_code||'-IORG');

    end if;

EXCEPTION

  when others then
  	if c1%ISOPEN then
      CLOSE c1;
    end if;

	if c2%ISOPEN then
	  CLOSE c2;
	end if;

END Item_Org_FK;

Function Item_Org_FK(
        p_inventory_item_id             in NUMBER,
        p_organization_id               in NUMBER,
        p_item_description              in varchar2 DEFAULT null,
        p_item_category_id                 in NUMBER DEFAULT null,
        p_instance_code					in varchar2 DEFAULT null)
                                        return VARCHAR2 IS

  l_instance_code  edw_local_instance.instance_code%TYPE;

  cursor c1 is
  select instance_code
  from edw_local_instance;

BEGIN

  if p_organization_id = -1 then

    return 'NA_EDW';

  end if;

  if p_instance_code is null then

	OPEN c1;
	FETCH c1 INTO l_instance_code;
	CLOSE c1;

  else

	l_instance_code := p_instance_code;

  end if;

    if p_inventory_item_id is null and p_item_description is not null
	  and p_organization_id is not null then

	  return (p_item_description||'-'||p_item_category_id||'-'||
		p_organization_id||'-'||l_instance_code||'-ONETIME-IORG');

	else

      return (p_inventory_item_id||'-'||p_organization_id||'-'||l_instance_code||'-IORG');

    end if;

EXCEPTION

  when others then
  	if c1%ISOPEN then
      CLOSE c1;
    end if;

END Item_Org_FK;


Function Item_Rev_FK(
        p_inventory_item_id             in NUMBER,
        p_organization_id               in NUMBER,
        p_revision               	    in VARCHAR2,
        p_instance_code                 in VARCHAR2 := null)
                                        return VARCHAR2 IS

  l_instance_code  edw_local_instance.instance_code%TYPE;

  cursor c1 is
  select instance_code
  from edw_local_instance;

BEGIN

  if p_instance_code is null then

	OPEN c1;
	FETCH c1 INTO l_instance_code;
	CLOSE c1;

    return (p_revision||'-'||p_inventory_item_id||'-'||p_organization_id||'-'||l_instance_code);

  else

	return (p_revision||'-'||p_inventory_item_id||'-'||p_organization_id||'-'||p_instance_code);

  end if;


EXCEPTION

  when others then
  	if c1%ISOPEN then
      CLOSE c1;
  end if;
END Item_Rev_FK;

FUNCTION category_fk(
        p_functional_area       IN NUMBER,
        p_control               IN NUMBER,
        p_category_id           IN NUMBER,
        p_instance_code         IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS

  l_instance_code  edw_local_instance.instance_code%TYPE;

  CURSOR c1 IS
  SELECT instance_code
  FROM edw_local_instance;

BEGIN

  IF p_instance_code IS NULL THEN

	OPEN c1;
	FETCH c1 INTO l_instance_code;
	CLOSE c1;
  ELSE /* Bugfix for 3289525 */
	l_instance_code := p_instance_code;
  END IF;

  RETURN(to_char(p_control)||'-'||to_char(p_category_id) || '-' || l_instance_code || '-PCAT');

EXCEPTION

  WHEN OTHERS THEN

    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;

    RAISE;

END Category_FK;


FUNCTION GET_PROD_GRP_FK(
    p_item_id         in  NUMBER,
    p_organization_id in  NUMBER,
    p_instance_code   in  VARCHAR2 )
RETURN VARCHAR2 IS

  CURSOR c_get_ids IS
         SELECT TO_NUMBER(MC.SEGMENT1) INTEREST_TYPE_ID,
                TO_NUMBER(MC.SEGMENT2) PRIMARY_INTEREST_CODE_ID,
                TO_NUMBER(MC.SEGMENT3) SECONDARY_INTEREST_CODE_ID
           FROM MTL_ITEM_CATEGORIES MIC,
                MTL_CATEGORIES_B     MC,
                FND_ID_FLEX_STRUCTURES FIFS
          WHERE FIFS.ID_FLEX_CODE = 'MCAT'
            AND FIFS.APPLICATION_ID = 401
            AND FIFS.ID_FLEX_STRUCTURE_CODE = 'SALES_CATEGORIES'
            AND MC.STRUCTURE_ID = FIFS.ID_FLEX_NUM
            AND MIC.CATEGORY_SET_ID = 5
            AND MIC.CATEGORY_ID = MC.CATEGORY_ID
            AND MIC.INVENTORY_ITEM_ID = p_item_id
            AND MIC.ORGANIZATION_ID = p_organization_id ;

v_int_type_id  NUMBER := NULL;
v_prim_code_id NUMBER := NULL;
v_secn_code_id NUMBER := NULL;
v_secn_code_fk VARCHAR2(240) := 'NA_EDW';
v_instance_code VARCHAR2(240) := 'NA_EDW' ;

BEGIN
     IF (p_item_id IS NOT NULL and
         p_organization_id IS NOT NULL )
     THEN
          OPEN c_get_ids;
          FETCH c_get_ids INTO  v_int_type_id, v_prim_code_id,
                               v_secn_code_id ;
          CLOSE c_get_ids;
          IF v_secn_code_id IS NOT NULL
          THEN
              v_secn_code_fk :=  v_secn_code_id || '-' || p_instance_code
                                          || '-SECN_CODE' ;
          ELSIF v_prim_code_id IS NOT NULL
          THEN
              v_secn_code_fk :=  v_prim_code_id || '-' || p_instance_code
                                     || '-PRIM_CODE-PCTG' ;
          ELSIF v_int_type_id IS NOT NULL
          THEN
              v_secn_code_fk :=  v_int_type_id || '-' || p_instance_code ||
                                       '-INTR_TYPE-PLIN' ;
          END IF;
     END IF;

     RETURN(v_secn_code_fk);
EXCEPTION
     WHEN OTHERS THEN
          raise;
END GET_PROD_GRP_FK;

FUNCTION GET_ITEM_FK(
    p_item_id           in NUMBER,
    p_inv_org_id        in NUMBER,
    p_interest_type_id  in NUMBER,
    p_primary_code_id   in NUMBER,
    p_secondary_code_id in NUMBER,
    p_instance_code     in VARCHAR2 )
RETURN VARCHAR2 IS

   v_item_fk VARCHAR2(240) := 'NA_EDW';

BEGIN

     IF (p_item_id IS NOT NULL and
         p_inv_org_id IS NOT NULL )
     THEN
          v_item_fk := p_item_id || '-' || p_inv_org_id || '-' ||
                         p_instance_code || '-IORG' ;
     ELSIF  p_secondary_code_id IS NOT NULL
     THEN
          v_item_fk := p_secondary_code_id  || '-' || p_instance_code
                              || '-SECN_CODE-PGRP';
     ELSIF  p_primary_code_id IS NOT NULL
     THEN
          v_item_fk := p_primary_code_id || '-' || p_instance_code ||
                         '-PRIM_CODE-PCTG' ;
     ELSIF  p_interest_type_id IS NOT NULL
     THEN
          v_item_fk := p_interest_type_id || '-' || p_instance_code ||
                            '-INTR_TYPE-PLIN' ;
     END IF;

     RETURN(v_item_fk);
EXCEPTION
     WHEN OTHERS THEN
          raise;
END GET_ITEM_FK;

PROCEDURE INITIALIZE_PARENTS IS

CURSOR parent_organizations_c IS
SELECT organization_id, master_organization_id
FROM mtl_parameters;

parent_organizations_r parent_organizations_c%ROWTYPE;

l_parent parent_org_r_t;

BEGIN

OPEN parent_organizations_c;

LOOP

  FETCH parent_organizations_c INTO parent_organizations_r;

  EXIT WHEN parent_organizations_c%NOTFOUND;

  l_parent.parent_org := parent_organizations_r.master_organization_id;
  l_parent.child_org := parent_organizations_r.organization_id;

  parent_org_t(parent_organizations_r.organization_id) := l_parent;

  IF parent_organizations_r.organization_id = parent_organizations_r.master_organization_id THEN

    parent_org_t(parent_organizations_r.organization_id).parent_org := NULL;

  END IF;

END LOOP;

CLOSE parent_organizations_c;

EXCEPTION

  WHEN OTHERS THEN
    IF parent_organizations_c%ISOPEN THEN
      CLOSE parent_organizations_c;
    END IF;

END INITIALIZE_PARENTS;

FUNCTION GET_MASTER_PARENT(
  p_organization_id IN NUMBER) RETURN NUMBER
IS

l_current_parent NUMBER := 0;

BEGIN

  IF g_initialized = 0 THEN

    initialize_parents;
    g_initialized := 1;

  END IF;

  l_current_parent := parent_org_t(p_organization_id).parent_org;

  IF l_current_parent IS NULL THEN

    RETURN p_organization_id;

  ELSE

    l_current_parent := get_master_parent(l_current_parent);

  END IF;

  RETURN l_current_parent;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN NULL;

END GET_MASTER_PARENT;

END EDW_ITEMS_PKG;

/
