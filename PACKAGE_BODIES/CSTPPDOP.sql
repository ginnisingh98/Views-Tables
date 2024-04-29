--------------------------------------------------------
--  DDL for Package Body CSTPPDOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPDOP" AS
/* $Header: CSTPDOPB.pls 120.1 2006/01/20 03:06:26 skayitha noship $ */

FUNCTION validate_post_to_GL (
		p_org_id	IN	NUMBER,
		p_legal_entity	IN	NUMBER,
		p_cost_type_id	IN	NUMBER,
		p_options	IN	NUMBER
		)
/* ****************************************************************************	*/
/* Option = 1: IN Params Reqd: p_legal_entity, p_cost_type_id, options		*/
/* 	Description: a> If another Org having the same set of books posts to	*/
/*			Gl, then return FALSE 					*/
/*		     b> If another LE-CT combination having the same set of 	*/
/*			books has transfer to GL, then return FALSE		*/
/*		     C> If both the above conditions fail, then return TRUE	*/
/*										*/
/* Option = 2: IN Params Reqd: p_org_id, options				*/
/*	Description: a> If another LE-CT combination having the same set of 	*/
/*			books posts to GL, the return FALSE			*/
/*		     b> If above condition fails, the return TRUE		*/
/* **************************************************************************** */


RETURN	BOOLEAN		IS
	ret_num		NUMBER;
	dummy		NUMBER;
BEGIN
	ret_num		:= 0;
	dummy		:= 0;

    IF(p_options = 1) THEN

	select	count(1)
	into 	dummy
	from
        	CST_LE_COST_TYPES CLCT,
        	CST_ACCT_INFO_V OOD,
        	MTL_PARAMETERS MP
	where
        	clct.set_of_books_id = ood.LEDGER_ID
	AND     ood.LEGAL_ENTITY = p_legal_entity
	AND     ood.organization_id IN (    SELECT  ccga.organization_id
       		                            FROM    cst_cost_group_assignments ccga,
                                         	    cst_cost_groups ccg
                                    	    WHERE   ccg.legal_entity = p_legal_entity
                                            AND     ccga.cost_group_id = ccg.cost_group_id )
	AND     clct.legal_entity  = p_legal_entity
	AND     clct.cost_type_id  = p_cost_type_id
	AND	clct.primary_cost_method > 2
	AND     mp.organization_id = ood.organization_id
	AND     mp.general_ledger_update_code <> 3
	AND     ROWNUM < 2 ;

	IF(NVL(dummy,0) <> 0) THEN
		ret_num := 1;
	ELSE
		ret_num := 0;
	END IF;

	IF(ret_num = 1) THEN
		return FALSE;
	END IF;

	dummy	:= 0;
	ret_num	:= 0;

	SELECT  count(*)
	INTO	dummy
	FROM    cst_le_cost_types clct
	WHERE   clct.legal_entity = p_legal_entity
	AND     clct.cost_type_id <> p_cost_type_id
	AND	clct.set_of_books_id = (SELECT	clct1.set_of_books_id
					FROM	cst_le_cost_types clct1
					WHERE	clct1.cost_type_id = p_cost_type_id
					AND	clct1.legal_entity = p_legal_entity
					AND	clct.primary_cost_method > 2)
	AND     clct.post_to_gl = 'Y';

        IF(NVL(dummy,0)<> 0) THEN
                ret_num := 1;
        ELSE
                ret_num := 0;
        END IF;

        IF(ret_num = 1) THEN
                return FALSE;
        ELSE
                return TRUE;
        END IF;


   END IF; /* Option = 1 */


  IF (p_options = 2) THEN

	ret_num := 0;
	dummy	:= 0;

	SELECT	count(1)
	INTO	dummy
	FROM
        	cst_le_cost_types clct,
        	 CST_ACCT_INFO_V ood,
        	mtl_parameters mp
	WHERE
        	clct.set_of_books_id = ood.LEDGER_ID
	AND     ood.organization_id  = p_org_id
	AND     ood.organization_id  = mp.organization_id
	AND     clct.legal_entity    = (     SELECT  distinct ccg.legal_entity
       		                             FROM    cst_cost_group_assignments ccga,
       		                                     cst_cost_groups ccg
       		                             WHERE   ccga.organization_id = p_org_id
       		                             AND     ccga.cost_group_id = ccg.cost_group_id )
	AND     clct.post_to_gl = 'Y'
	AND     clct.primary_cost_method > 2
	AND     ROWNUM < 2;


        IF(NVL(dummy,0)<> 0) THEN
                ret_num := 1;
	ELSE
		ret_num := 0;
	END IF;

        IF(ret_num = 1) THEN
                return FALSE;
        ELSE
                return TRUE;
        END IF;

   ELSE
	return FALSE;
   END IF; /* Option = 2 */

EXCEPTION
	WHEN OTHERS THEN
		return FALSE;

END validate_post_to_GL;


END CSTPPDOP;

/
