--------------------------------------------------------
--  DDL for Package Body ZX_TCM_COMPOUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TCM_COMPOUND_PKG" AS
/* $Header: zxtaxgroupmigb.pls 120.22 2006/12/27 20:38:51 svaze ship $ */
L_MULTI_ORG_FLAG FND_PRODUCT_GROUPS.MULTI_ORG_FLAG%TYPE;
L_ORG_ID	 NUMBER(15);
  PROCEDURE  load_tax_relations IS
  BEGIN

  INSERT ALL
  -- branch
  -- check for same regime, it could be two diff intos
  -- check if both are branches
  WHEN (same_branch='Y') THEN
  INTO zx_tax_relations_t
   (parent_tax_code_id ,
    parent_tax_code ,
    parent_regime_code ,
    parent_precedence ,
    child_tax_code_id  ,
    child_tax_code,
    child_regime_code ,
    child_precedence ,
    branch_flag           ,
    tax_group_id,
    tax_group_code,
    parent_taxable_basis,
    child_taxable_basis,
    content_owner_id,
    parent_tax,
	child_tax,
    org_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
	)
 VALUES (
   parent_tax_code_id,
   parent_tax_code,
   parent_regime_code,
   parent_precedence,
   child_tax_code_id,
   child_tax_code,
   child_regime_code,
   child_precedence,
   branch_flag,
   rel_tax_group_id,
   tax_group_code,
   parent_taxable_basis,
   child_taxable_basis,
   content_owner_id,
   parent_tax,
   child_tax,
   org_id,
   created_by,
   creation_date,
   last_updated_by,
   last_update_date
   )
  -- no branch but compunded
  -- group with no tax decimal precedence
  WHEN (same_branch='N' AND
  NOT EXISTS ( SELECT 'Y'
             FROM ar_tax_group_codes_all group_compound
			 WHERE group_compound.tax_group_id = rel_tax_group_id
			 AND trunc (group_compound.compounding_precedence) <> group_compound.compounding_precedence
            )
      ) THEN
  INTO zx_tax_relations_t
   (parent_tax_code_id ,
    parent_tax_code ,
    parent_regime_code ,
    parent_precedence ,
    child_tax_code_id  ,
    child_tax_code,
    child_regime_code ,
    child_precedence ,
    branch_flag           ,
    tax_group_id,
    tax_group_code,
    parent_taxable_basis,
	child_taxable_basis,
    content_owner_id,
    parent_tax,
	child_tax,
    org_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
	 )
   VALUES (
    parent_tax_code_id,
    parent_tax_code,
    parent_regime_code,
    parent_precedence,
    child_tax_code_id,
    child_tax_code,
    child_regime_code,
    child_precedence,
    branch_flag,
    rel_tax_group_id,
    tax_group_code,
    parent_taxable_basis,
    child_taxable_basis,
    content_owner_id,
    parent_tax,
    child_tax,
    org_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date)
  SELECT a.tax_group_code_id group_code_id,
       a.tax_group_id rel_tax_group_id,
       grp.tax_code tax_group_code,
       a.tax_code_id parent_tax_code_id,
       b.tax_group_code_id child_group_code,
	   b.tax_code_id child_tax_code_id,
     CASE WHEN (b.compounding_precedence <> trunc(b.compounding_precedence) ) THEN 'Y'
          WHEN (a.compounding_precedence <> trunc(a.compounding_precedence) ) THEN 'Y'
     ELSE 'N'
	 END branch_flag,
	  CASE WHEN b.compounding_precedence <> trunc(b.compounding_precedence) THEN
	        CASE WHEN (trunc(a.compounding_precedence) <> trunc(b.compounding_precedence)) THEN
	             'N'
	            ELSE 'Y'
	        END

	        WHEN a.compounding_precedence <> trunc(a.compounding_precedence) THEN
	        CASE WHEN (trunc(a.compounding_precedence) <> trunc(b.compounding_precedence)) THEN
	             'N'
	             ELSE 'Y'
	        END
	       ELSE 'N'
	  END same_branch,
     a.compounding_precedence parent_precedence,
     b.compounding_precedence child_precedence,
     CASE WHEN (b.compounding_precedence > a.compounding_precedence) THEN
	        a.tax_code_id
     END parent_code_id,
     bb.tax_code child_tax_code,
     aa.tax_code parent_tax_code,
     --rega.tax_type parent_regime_code,
     rega.tax_regime_code parent_regime_code, --Bug 5691957

     --regb.tax_type child_regime_code,
     regb.tax_regime_code child_regime_code, --Bug 5691957

     aa.taxable_basis parent_taxable_basis,
     bb.taxable_basis child_taxable_basis,
     ptp.party_tax_profile_id content_owner_id,
     aa.tax_code parent_tax,
 	 bb.tax_code child_tax,
     decode(l_multi_org_flag,'N',l_org_id,a.org_id) org_id,
     fnd_global.user_id created_by,
     sysdate creation_date ,
     fnd_global.user_id last_updated_by,
     sysdate last_update_date
    FROM  ar_tax_group_codes_all a,
        ar_tax_group_codes_all b,
        ar_vat_tax_all_b aa,
        ar_vat_tax_all_b bb,
       zx_tax_priorities_t rega,
       zx_tax_priorities_t regb,
       zx_party_tax_profile ptp,
        ar_vat_tax_all_b grp
     WHERE decode(l_multi_org_flag,'N',l_org_id,a.org_id) = decode(l_multi_org_flag,'N',l_org_id,b.org_id)
       AND decode(l_multi_org_flag,'N',l_org_id,a.org_id) = decode(l_multi_org_flag,'N',l_org_id,aa.org_id)
       AND  decode(l_multi_org_flag,'N',l_org_id,b.org_id) = decode(l_multi_org_flag,'N',l_org_id,bb.org_id)
       AND a.tax_group_id=b.tax_group_id
       AND (b.compounding_precedence > a.compounding_precedence)
       AND ptp.party_type_code ='OU'
       AND ptp.party_id=decode(l_multi_org_flag,'N',l_org_id,aa.org_id)
-- lookup condition to get tax info
       AND aa.vat_tax_id = a.tax_code_id
       AND bb.vat_tax_id = b.tax_code_id
       AND aa.tax_type = rega.tax_type
       AND decode(l_multi_org_flag,'N',l_org_id,aa.org_id)  =  rega.org_id
       AND bb.tax_type = regb.tax_type
       AND decode(l_multi_org_flag,'N',l_org_id,bb.org_id)  =  regb.org_id
       AND rega.regime_or_tax_flag ='R'
       AND regb.regime_or_tax_flag ='R'
       AND decode(l_multi_org_flag,'N',l_org_id,grp.org_id)= decode(l_multi_org_flag,'N',l_org_id,b.org_id)
       AND grp.vat_tax_id = b.tax_group_id
       ORDER BY 3,4,6,7;


 -- remove conflicting groups
 -- logic is to assume duplicate rows by having a calculated id
  DELETE FROM zx_tax_relations_t d
  WHERE d.ROWID IN
   ( SELECT min(a.ROWID)
     FROM zx_tax_relations_t a,
	      zx_tax_relations_t b
     WHERE a.org_id = b.org_id
	 AND a.parent_tax_code = b.child_tax_code
     AND b.parent_tax_code = a.child_tax_code
     GROUP BY a.parent_tax_code_id + a.child_tax_code_id, a.tax_group_id+b.tax_group_id);


--  this works when there is one parent only.
      INSERT INTO zx_compound_errors_t(
      tax_group_id ,
      tax_group_code,
	  error_number,
      error_message)
      SELECT  tax_group_id, grp.tax_code group_code,
	           ROWNUM, 'Conflicting priority group '
      FROM  ar_vat_tax_all grp,
           (SELECT min(a.tax_group_id) tax_group_id
            FROM zx_tax_relations_t a
                , zx_tax_relations_t b
            WHERE a.org_id = b.org_id
		AND a.parent_tax_code = b.child_tax_code
            AND b.parent_tax_code = a.child_tax_code
            GROUP BY a.tax_group_id+b.tax_group_id )
      WHERE tax_group_id = grp.vat_tax_id;

    DELETE FROM zx_tax_relations_t d
    WHERE d.tax_group_id IN
    ( SELECT min(a.tax_group_id)
      FROM zx_tax_relations_t a, zx_tax_relations_t b
      WHERE a.org_id = b.org_id
	  AND a.parent_tax_code = b.child_tax_code
      AND b.parent_tax_code = a.child_tax_code
      GROUP BY a.tax_group_id+b.tax_group_id);

 END load_tax_relations;


  PROCEDURE  load_regime_list IS

  BEGIN
 /*
   SELECT ALL THE posible tax TYPES AND THE ar organizations that can be used TO DEFINE taxes
   these regimes will be used IN THE load tax procees TO provide THE regime FOR THE taxes.
   also initialize regime precedence.
 */

  INSERT ALL INTO
  zx_tax_priorities_t (
    regime_or_tax_flag ,
    tax_regime_code ,
    regime_precedence,
    org_id,
    tax_type,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date )
  VALUES (
    tax_regime_flag,
    tax_regime_code ,
    precedence,
    org_id,
    tax_type,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date )
    SELECT 'R' tax_regime_flag,
      --zx_migrate_util.get_country(temp_regime.org_id) || '_' || temp_regime.tax_type tax_regime_code,
     CASE WHEN temp_regime.tax_type <> 'SALES_TAX' then  --Bug 5691957
	  	      Zx_Migrate_Util.Get_Country(temp_regime.Org_Id)||'-Tax'
     ELSE

               Zx_Migrate_Util.GET_TAX_REGIME(
  		  temp_regime.tax_type,
  		  temp_regime.org_id)
      END   tax_regime_code ,
      ROWNUM precedence,
      decode(l_multi_org_flag,'N',l_org_id,temp_regime.org_id)  org_id,
      temp_regime.tax_type tax_type,
      fnd_global.user_id created_by,
      sysdate creation_date ,
      fnd_global.user_id last_updated_by,
      sysdate last_update_date
   FROM
    (SELECT UNIQUE DECODE(l_multi_org_flag,'N',l_org_id,org_id) org_id , tax_type
     FROM ar_vat_tax_all_b ) temp_regime;

  END load_regime_list;


/***********************************

*/
  PROCEDURE  load_tax_list IS

  BEGIN

  INSERT ALL INTO
  zx_tax_priorities_t (
    regime_or_tax_flag ,
    tax_id   ,
    tax_code  ,
    tax_precedence ,
    tax_regime_code ,
    regime_precedence,
    tax_type,
    group_flag,
    org_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date)
  VALUES (
    tax_regime_flag,
    parent_tax  ,
    parent_tax_code ,
    precedence,
    tax_regime_code,
    NULL,
    tax_type,
	group_flag,
	org_id,
	fnd_global.user_id,
    sysdate ,
    fnd_global.user_id ,
    sysdate )
 -- select taxes (in a group) that have a precedence and give an initial of 1
 SELECT UNIQUE 'T' tax_regime_flag,
       reg.tax_regime_code tax_regime_code,
       a.tax_code_id parent_tax,
       aa.tax_code parent_tax_code,
       decode (a.compounding_precedence,NULL,0,1) precedence,
       aa.tax_type tax_type,
       'Y' group_flag,
       decode(l_multi_org_flag,'N',l_org_id,aa.org_id) org_id
    FROM  ar_tax_group_codes_all a,
          ar_vat_tax_all_b aa,
         zx_tax_priorities_t reg
       WHERE  aa.vat_tax_id = a.tax_code_id
       AND aa.tax_type = reg.tax_type
       AND decode(l_multi_org_flag,'N',l_org_id,aa.org_id)  =  reg.org_id
       AND decode(l_multi_org_flag,'N',l_org_id,aa.org_id)  =  decode(l_multi_org_flag,'N',l_org_id,a.org_id)
       AND NOT EXISTS (
       SELECT 'Y', tax_code_id
       FROM ar_tax_group_codes_all dup_tax
       WHERE dup_tax.tax_code_id = a.tax_code_id
       AND  dup_tax.compounding_precedence IS NULL)
       UNION ALL
-- select taxes with no precedence and give and initial of zero
-- those are taxes with no relations to other taxes
-- those should be the first taxes selected.
 SELECT UNIQUE 'T' tax_regime_flag,
       reg.tax_regime_code tax_regime_code,
       a.tax_code_id parent_tax,
 	   aa.tax_code parent_tax_code,
 	   0 precedence,
       aa.tax_type tax_type,
       'N' group_flag,
       decode(l_multi_org_flag,'N',l_org_id,aa.org_id) org_id
  FROM  ar_tax_group_codes_all a,
          ar_vat_tax_all_b aa,
         zx_tax_priorities_t reg
       WHERE aa.vat_tax_id = a.tax_code_id
       AND  a.compounding_precedence IS NULL
       AND aa.tax_type = reg.tax_type
       AND decode(l_multi_org_flag,'N',l_org_id,aa.org_id)  =  reg.org_id
	   AND decode(l_multi_org_flag,'N',l_org_id,aa.org_id)  =  decode(l_multi_org_flag,'N',l_org_id,a.org_id);

  END load_tax_list;


/***********************************/

  PROCEDURE  set_precedences IS

    precedence_count   NUMBER;
    old_regime         VARCHAR2(30);
    old_org_id         NUMBER;
    current_regime     VARCHAR2(30);
    current_org_id     NUMBER;

    v_parent_precedence  NUMBER;
    v_child_precedence   NUMBER;
    v_aux_precedence     NUMBER;
    v_aux_reg_precedence     NUMBER;

    v_parent_rel_precedence  NUMBER;
    v_child_rel_precedence   NUMBER;

    v_child_tax          NUMBER;
    v_parent_tax          NUMBER;

    v_child_org          NUMBER;
    v_parent_org         NUMBER;

    v_child_regime        VARCHAR2(30);
    v_parent_regime       VARCHAR2(30);

    v_parent_reg_precedence  NUMBER;
    v_child_reg_precedence   NUMBER;

    v_child_tax_rowid       UROWID;
    v_parent_tax_rowid      UROWID;

    v_child_reg_rowid       UROWID;
    v_parent_reg_rowid      UROWID;

/* cursors to set the taxes priorities */
   CURSOR c_set_priorities IS
    SELECT org_id, tax_regime_code
    FROM zx_tax_priorities_t
    WHERE regime_or_tax_flag ='T'
    FOR UPDATE OF tax_precedence
    ORDER BY tax_regime_code,org_id,tax_precedence; --Bug 4524324

   CURSOR c_fix_tax_priorities IS
    SELECT org_id, tax_precedence, tax_id, ROWID
    FROM zx_tax_priorities_t
    WHERE regime_or_tax_flag ='T'
    ORDER BY tax_regime_code,tax_precedence;


   CURSOR c_get_taxes_relation IS
    SELECT org_id, parent_regime_code, parent_precedence, parent_tax_code_id,
	       child_regime_code, child_precedence
    FROM zx_tax_relations_t
    WHERE child_tax_code_id = v_child_tax
	AND   org_id = v_child_org;


   CURSOR c_get_parent_priority IS
    SELECT tax_precedence, ROWID
    FROM zx_tax_priorities_t
    WHERE tax_id = v_parent_tax
    AND   org_id = v_parent_org;

/* cursors to set the regimes priorities */

  CURSOR c_get_parent_reg_prece IS
    SELECT tax_precedence, ROWID
    FROM zx_tax_priorities_t
    WHERE regime_or_tax_flag ='R'
    AND tax_regime_code = v_parent_regime;

  CURSOR c_get_child_reg_prece IS
    SELECT tax_precedence, ROWID
    FROM zx_tax_priorities_t
    WHERE regime_or_tax_flag ='R'
    AND tax_regime_code = v_child_regime;

  BEGIN
    old_regime:='OLD';
    old_org_id:=-1;

 /* initialize taxes priorities per content owner (org id) and regime */
    OPEN c_set_priorities;
    LOOP
     FETCH c_set_priorities INTO current_org_id, current_regime;
     EXIT WHEN c_set_priorities%NOTFOUND;

     IF (old_regime <> current_regime OR old_org_id <> current_org_id) THEN
       old_regime:=current_regime;
       old_org_id:=current_org_id;
       precedence_count:=0;
     END IF;

      precedence_count:=precedence_count+1;

      UPDATE zx_tax_priorities_t
      SET tax_precedence = precedence_count
      WHERE CURRENT OF c_set_priorities;

    END LOOP;

    CLOSE c_set_priorities;

/* sort the taxes using the relationship_t table as a helper  */

    OPEN c_fix_tax_priorities;
    LOOP
     FETCH c_fix_tax_priorities INTO v_child_org, v_child_precedence, v_child_tax, v_child_tax_rowid;
     EXIT WHEN c_fix_tax_priorities%NOTFOUND;

       OPEN c_get_taxes_relation;
   /* find if the tax appears as child tax in the relations table, and compare precedence to parent */

      LOOP
        FETCH c_get_taxes_relation INTO v_parent_org, v_parent_regime, v_parent_rel_precedence,
      		                         v_parent_tax, v_child_regime, v_child_rel_precedence;
        EXIT WHEN c_get_taxes_relation%NOTFOUND;

--  dbms_output.put_line('parent tax code ' || to_char(v_parent_tax) || ' child tax code ' || to_char(v_child_tax));

        IF (v_parent_regime = v_child_regime AND v_parent_org = v_child_org ) THEN
          OPEN c_get_parent_priority;
          FETCH c_get_parent_priority INTO v_parent_precedence, v_parent_tax_rowid;

--  dbms_output.put_line('parent precedence' || v_parent_precedence || ' child precedence ' || v_child_precedence );

          IF (v_parent_precedence > v_child_precedence) THEN
          -- switch initialized precendeces
            v_aux_precedence := v_parent_precedence;
            v_parent_precedence := v_child_precedence;
            v_child_precedence := v_aux_precedence;

           UPDATE zx_tax_priorities_t
           SET tax_precedence = v_parent_precedence
           WHERE ROWID = v_parent_tax_rowid;

           UPDATE zx_tax_priorities_t
           SET tax_precedence = v_child_precedence
           WHERE ROWID = v_child_tax_rowid;

          END IF;

          CLOSE c_get_parent_priority;
       ELSE  -- different regimes
       -- switch regime precedences if needed.
       -- we use the precedence of taxes as a helper to sort the regimes precedence.

         OPEN c_get_parent_reg_prece;
         OPEN c_get_child_reg_prece;
         FETCH c_get_parent_reg_prece INTO v_parent_reg_precedence, v_parent_reg_rowid;
         FETCH c_get_child_reg_prece INTO v_child_reg_precedence, v_child_reg_rowid;

         IF (v_parent_reg_precedence > v_child_reg_precedence ) THEN

--   dbms_output.put_line('parent regime prece' || v_parent_reg_precedence || ' child regime prece ' || v_child_reg_precedence );

            v_aux_reg_precedence := v_parent_reg_precedence;
            v_parent_reg_precedence := v_child_reg_precedence;
            v_child_reg_precedence := v_aux_reg_precedence;

           UPDATE zx_tax_priorities_t
           SET tax_precedence = v_parent_reg_precedence
           WHERE ROWID = v_parent_reg_rowid;

           UPDATE zx_tax_priorities_t
           SET tax_precedence = v_child_reg_precedence
           WHERE ROWID = v_child_reg_rowid;

         END IF;

         CLOSE c_get_parent_reg_prece;
         CLOSE c_get_child_reg_prece;

       END IF;  -- compare regimes

       END LOOP;

       CLOSE c_get_taxes_relation;

  END LOOP;

  CLOSE c_fix_tax_priorities;

  END set_precedences;

/* main program: calls procedures in order */
  PROCEDURE main IS

  BEGIN



    DELETE zx_tax_relations_t;
    DELETE zx_tax_priorities_t;
    DELETE zx_compound_errors_t;
    COMMIT;

    load_regime_list;
    load_tax_list;
    load_tax_relations;
    set_precedences;

 EXCEPTION
 WHEN OTHERS THEN
    arp_util_tax.debug('Exception in constructor of Tax Group Migration '||sqlerrm);

  END main;
  begin

   SELECT NVL(MULTI_ORG_FLAG,'N')  INTO L_MULTI_ORG_FLAG FROM
    FND_PRODUCT_GROUPS;

    IF L_MULTI_ORG_FLAG  = 'N' THEN

          FND_PROFILE.GET('ORG_ID',L_ORG_ID);

                 IF L_ORG_ID IS NULL THEN
                   arp_util_tax.debug('MO: Operating Units site level profile option value not set , resulted in Null Org Id');
                 END IF;
    ELSE
         L_ORG_ID := NULL;
    END IF;
   EXCEPTION
   WHEN OTHERS THEN
    arp_util_tax.debug('Exception in constructor of tax group migration  '||sqlerrm);

  END zx_tcm_compound_pkg;

/
