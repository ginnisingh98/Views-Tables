--------------------------------------------------------
--  DDL for Package Body BOM_REVISIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_REVISIONS" AS
/* $Header: BOMREVSB.pls 120.4.12010000.3 2009/12/21 09:19:24 rvalsan ship $ */

/* --------------------------- RAISE_REVISION_ERROR ------------------------
   NAME
    RAISE_REVISION_ERROR - raises generic error message
 DESCRIPTION
    for sql error failures, places the SQLERRM error on the message stack

 REQUIRES
    func_name   PROCEDURE_name
    stmt_num	statement number

 OUTPUT

 NOTES
 ---------------------------------------------------------------------------*/
PROCEDURE RAISE_REVISION_ERROR (
    func_name   VARCHAR2,
    stmt_num	NUMBER
)
IS
    err_text	VARCHAR2(2000);
BEGIN
    err_text := func_name || '(' || stmt_num || ')' || SQLERRM;
    FND_MESSAGE.SET_NAME('BOM', 'BOM_SQL_ERR');
    FND_MESSAGE.SET_TOKEN('ENTITY', err_text);
    APP_EXCEPTION.RAISE_EXCEPTION;
/*EXCEPTION
    WHEN OTHERS THEN
	NULL;*/		-- BUG 4919190
END RAISE_REVISION_ERROR;

/* --------------------------- RAISE_NO_REV_ERROR ------------------------
   NAME
    RAISE_NO_REV_ERROR - raises generic error message
 DESCRIPTION
    for sql error failures, places the SQLERRM error on the message stack

 REQUIRES
    org_id	organization_id
    part_id	item id
    rev_date	revision date

 OUTPUT

 NOTES
 ---------------------------------------------------------------------------*/
PROCEDURE RAISE_NO_REV_ERROR (
    org_id	NUMBER,
    part_id	NUMBER,
    rev_date	DATE
) IS
    part_number	VARCHAR2(40);
BEGIN
	SELECT substrb(ITEM_NUMBER, 1, 40)
	INTO   part_number
	FROM   MTL_ITEM_FLEXFIELDS
	WHERE  ORGANIZATION_ID = org_id
	AND    INVENTORY_ITEM_ID = part_id;

/*
** return message that is no valid rev for item
** Name: BOM_GET_REV
** EFF_DATE: rev_date
** ITEM_NUMBER: select from mtl_item_flexfields
*/

	FND_MESSAGE.SET_NAME('BOM', 'BOM_GET_REV');
	FND_MESSAGE.SET_TOKEN('ITEM_NUMBER', part_number);
	FND_MESSAGE.SET_TOKEN('EFF_DATE', fnd_date.date_to_displaydt(rev_date));
	APP_EXCEPTION.RAISE_EXCEPTION;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RAISE_REVISION_ERROR (func_name => 'RAISE_NO_REV_ERROR',
			      stmt_num => 1);

END RAISE_NO_REV_ERROR;

/* ------------------------------ GET_REVISION_DETAILS --------------------------
   NAME
    GET_REVISION_DETAILS - retrieve item revision,revision label,revision id for a date
 DESCRIPTION
    retrieve teh current revision for teh given date

 REQUIRES
    type	"PART" - item revision
		"PROCESS" - routing revision
    eco_status  "ALL" - all ECOs
		"EXCLUDE_HOLD" - exclude pending revisions from ECOs
				 with HOLD status
		"EXCLUDE_OPEN_HOLD" - exclude pending revisions from ECOs
				 with HOLD or OPEN status
                "EXCLUDE_ALL"   -  Exclude all revisions except the Implemented
    examine_type "ALL" - all revisions
		"IMPL_ONLY" - only implemented revisions
		"PEND_ONLY" - only unimplemented revisions
    org_id	organization id
    item_id     item id
    rev_date    date for which revision desired
 OUTPUT
    itm_rev		revision
    itm_rev_label	revision label
    itm_rev_id		revision id
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/
PROCEDURE GET_REVISION_DETAILS(
	eco_status		IN VARCHAR2 DEFAULT 'ALL',
	examine_type		IN VARCHAR2 DEFAULT 'ALL',
	org_id			IN NUMBER,
	item_id			IN NUMBER,
	rev_date		IN DATE,
	itm_rev			 IN OUT NOCOPY  VARCHAR2,
	itm_rev_label		 IN OUT NOCOPY  VARCHAR2,
	itm_rev_id		 IN OUT NOCOPY  NUMBER
)
IS
    stmt_num    NUMBER;

    CURSOR ECO_STATUS_ITEM_REV IS
	SELECT REVISION,REVISION_LABEL,REVISION_ID
        FROM   MTL_ITEM_REVISIONS_B MIR, ENG_REVISED_ITEMS ERI
        WHERE  MIR.INVENTORY_ITEM_ID = item_id
        AND    MIR.ORGANIZATION_ID = org_id
        AND    MIR.EFFECTIVITY_DATE  <= rev_date  --Bug 3020310
        AND    MIR.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID(+)
        AND   (
                 (eco_status = 'EXCLUDE_HOLD'
                 AND  NVL(ERI.STATUS_TYPE,0) NOT IN (2)
                 )
                 OR
                 (eco_status = 'EXCLUDE_OPEN_HOLD'
                 AND  NVL(ERI.STATUS_TYPE,0) NOT IN (1,2)
                 )
                  OR
                (eco_status = 'EXCLUDE_ALL'
                 AND  NVL(ERI.STATUS_TYPE,0) IN (0,6)
                )
              )
         ORDER BY MIR.EFFECTIVITY_DATE DESC, MIR.REVISION DESC;

    CURSOR NO_ECO_ITEM_REV IS
       SELECT REVISION,REVISION_LABEL,REVISION_ID
       FROM   MTL_ITEM_REVISIONS_B MIR
       WHERE  INVENTORY_ITEM_ID = item_id
       AND    ORGANIZATION_ID = org_id
       AND    MIR.EFFECTIVITY_DATE  <= rev_date  --Bug 3020310
       AND    ( (examine_type = 'ALL')
                 OR
		(examine_type = 'IMPL_ONLY'
                     AND IMPLEMENTATION_DATE IS NOT NULL
                )
                 OR
		(examine_type = 'PEND_ONLY'
                     AND IMPLEMENTATION_DATE IS NULL
                )
              )
        ORDER BY EFFECTIVITY_DATE DESC, REVISION DESC;

BEGIN
    IF (eco_status = 'EXCLUDE_HOLD' OR eco_status = 'EXCLUDE_OPEN_HOLD'
		OR eco_status = 'EXCLUDE_ALL' ) THEN   -- Bug #4038025
    	OPEN ECO_STATUS_ITEM_REV;
	stmt_num := 1;

    	FETCH ECO_STATUS_ITEM_REV INTO itm_rev,itm_rev_label,itm_rev_id;

    	CLOSE ECO_STATUS_ITEM_REV;

    ELSE
	OPEN NO_ECO_ITEM_REV;
	stmt_num := 2;

	FETCH NO_ECO_ITEM_REV INTO itm_rev,itm_rev_label,itm_rev_id;

    	CLOSE NO_ECO_ITEM_REV;

    END IF;
   EXCEPTION
     WHEN OTHERS THEN
     NULL;

END GET_REVISION_DETAILS;

/* ------------------------------ GET_ITEM_REVISION_LABEL_FN --------------------------
   NAME
    GET_ITEM_REVISION_LABEL_FN - retrieve item revision for a date
 DESCRIPTION
    retrieve teh current revision for teh given date

 REQUIRES
    type	"PART" - item revision
		"PROCESS" - routing revision
    eco_status  "ALL" - all ECOs
		"EXCLUDE_HOLD" - exclude pending revisions from ECOs
				 with HOLD status
		"EXCLUDE_OPEN_HOLD" - exclude pending revisions from ECOs
				 with HOLD or OPEN status
                "EXCLUDE_ALL"   -  Exclude all revisions except the Implemented
    examine_type "ALL" - all revisions
		"IMPL_ONLY" - only implemented revisions
		"PEND_ONLY" - only unimplemented revisions
    org_id	organization id
    item_id     item id
    rev_date    date for which revision desired
 OUTPUT
    itm_rev_label	revision label
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/


FUNCTION GET_ITEM_REVISION_LABEL_FN(
	eco_status		IN VARCHAR2 DEFAULT 'ALL',
	examine_type		IN VARCHAR2 DEFAULT 'ALL',
	org_id			IN NUMBER,
	item_id			IN NUMBER,
	rev_date		IN DATE
)
RETURN VARCHAR2 IS
	itm_rev 	VARCHAR2(3);
	itm_rev_label	VARCHAR2(80);
	itm_rev_id	NUMBER;
BEGIN
	GET_REVISION_DETAILS(
		eco_status => eco_status,
		examine_type => examine_type,
		org_id => org_id,
		item_id => item_id,
		rev_date => rev_date,
		itm_rev	=> itm_rev,
		itm_rev_label => itm_rev_label ,
		itm_rev_id => itm_rev_id
		);

RETURN 	itm_rev_label;

EXCEPTION
     WHEN OTHERS THEN
     RETURN NULL;

END GET_ITEM_REVISION_LABEL_FN;



/* ------------------------------ GET_ITEM_REVISION --------------------------
   NAME
    GET_ITEM_REVISION - retrieve item revision for a date
 DESCRIPTION
    retrieve teh current revision for teh given date

 REQUIRES
    type	"PART" - item revision
		"PROCESS" - routing revision
    eco_status  "ALL" - all ECOs
		"EXCLUDE_HOLD" - exclude pending revisions from ECOs
				 with HOLD status
		"EXCLUDE_OPEN_HOLD" - exclude pending revisions from ECOs
				 with HOLD or OPEN status
                "EXCLUDE_ALL"   -  Exclude all revisions except the Implemented
    examine_type "ALL" - all revisions
		"IMPL_ONLY" - only implemented revisions
		"PEND_ONLY" - only unimplemented revisions
    org_id	organization id
    item_id     item id
    rev_date    date for which revision desired
 OUTPUT
    itm_rev		revision
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/
PROCEDURE GET_ITEM_REVISION(
	eco_status		IN VARCHAR2 DEFAULT 'ALL',
	examine_type		IN VARCHAR2 DEFAULT 'ALL',
	org_id			IN NUMBER,
	item_id			IN NUMBER,
	rev_date		IN DATE,
	itm_rev			 IN OUT NOCOPY  VARCHAR2
)
IS
    stmt_num    NUMBER;

    CURSOR ECO_STATUS_ITEM_REV IS
	SELECT REVISION
        FROM   MTL_ITEM_REVISIONS_B MIR, ENG_REVISED_ITEMS ERI
        WHERE  MIR.INVENTORY_ITEM_ID = item_id
        AND    MIR.ORGANIZATION_ID = org_id
        AND    MIR.EFFECTIVITY_DATE  <= rev_date  --Bug 3020310
        AND    MIR.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID(+)
        AND   (
                 (eco_status = 'EXCLUDE_HOLD'
                 AND  NVL(ERI.STATUS_TYPE,0) NOT IN (2)
                 )
                 OR
                 (eco_status = 'EXCLUDE_OPEN_HOLD'
                 AND  NVL(ERI.STATUS_TYPE,0) NOT IN (1,2)
                 )
                  OR
                (eco_status = 'EXCLUDE_ALL'
                 AND  NVL(ERI.STATUS_TYPE,0) IN (0,6)
                )
              )
         ORDER BY MIR.EFFECTIVITY_DATE DESC, MIR.REVISION DESC;

    CURSOR NO_ECO_ITEM_REV IS
       SELECT REVISION
       FROM   MTL_ITEM_REVISIONS_B MIR
       WHERE  INVENTORY_ITEM_ID = item_id
       AND    ORGANIZATION_ID = org_id
       AND    MIR.EFFECTIVITY_DATE  <= rev_date  --Bug 3020310
       AND    ( (examine_type = 'ALL')
                 OR
		(examine_type = 'IMPL_ONLY'
                     AND IMPLEMENTATION_DATE IS NOT NULL
                )
                 OR
		(examine_type = 'PEND_ONLY'
                     AND IMPLEMENTATION_DATE IS NULL
                )
              )
        ORDER BY EFFECTIVITY_DATE DESC, REVISION DESC;

BEGIN
/*Bug 7692735: Changed below if condition to add last condition for EXCLUDE_ALL*/
    IF (eco_status = 'EXCLUDE_HOLD' OR eco_status = 'EXCLUDE_OPEN_HOLD' OR eco_status = 'EXCLUDE_ALL') THEN
    	OPEN ECO_STATUS_ITEM_REV;
	stmt_num := 1;

    	FETCH ECO_STATUS_ITEM_REV INTO itm_rev;

    	IF ECO_STATUS_ITEM_REV%NOTFOUND THEN
    	    CLOSE ECO_STATUS_ITEM_REV;
	    RAISE_NO_REV_ERROR (
			org_id => org_id,
			part_id => item_id,
			rev_date => rev_date);
    	END IF;
    	CLOSE ECO_STATUS_ITEM_REV;

    ELSE
	OPEN NO_ECO_ITEM_REV;
	stmt_num := 2;
    	FETCH NO_ECO_ITEM_REV INTO itm_rev;

    	IF NO_ECO_ITEM_REV%NOTFOUND THEN
    	    CLOSE NO_ECO_ITEM_REV;
	    RAISE_NO_REV_ERROR (
			org_id => org_id,
			part_id => item_id,
			rev_date => rev_date);
    	END IF;
    	CLOSE NO_ECO_ITEM_REV;

    END IF;

END GET_ITEM_REVISION;

/* ------------------------------ GET_ITEM_REVISION_FN --------------------------
   NAME
    GET_ITEM_REVISION_FN - retrieve item revision for a date , if no revision defined, return null instead
 DESCRIPTION
    retrieve teh current revision for teh given date

 REQUIRES
    type	"PART" - item revision
		"PROCESS" - routing revision
    eco_status  "ALL" - all ECOs
		"EXCLUDE_HOLD" - exclude pending revisions from ECOs
				 with HOLD status
		"EXCLUDE_OPEN_HOLD" - exclude pending revisions from ECOs
				 with HOLD or OPEN status
    examine_type "ALL" - all revisions
		"IMPL_ONLY" - only implemented revisions
		"PEND_ONLY" - only unimplemented revisions
    org_id	organization id
    item_id     item id
    rev_date    date for which revision desired
 OUTPUT
    itm_rev		revision
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/
FUNCTION GET_ITEM_REVISION_FN(
	eco_status		IN VARCHAR2 DEFAULT 'ALL',
	examine_type		IN VARCHAR2 DEFAULT 'ALL',
	org_id			IN NUMBER,
	item_id			IN NUMBER,
	rev_date		IN DATE
)
RETURN VARCHAR2 IS
    stmt_num    NUMBER;
    itm_rev     VARCHAR2(3);

    CURSOR ECO_STATUS_ITEM_REV IS
	SELECT REVISION
        FROM   MTL_ITEM_REVISIONS_B MIR, ENG_REVISED_ITEMS ERI
        WHERE  MIR.INVENTORY_ITEM_ID = item_id
        AND    MIR.ORGANIZATION_ID = org_id
        AND    MIR.EFFECTIVITY_DATE <= rev_date
        AND    MIR.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID(+)
        AND   (
                 (eco_status = 'EXCLUDE_HOLD'
                 AND  NVL(ERI.STATUS_TYPE,0) NOT IN (2)
                 )
                 OR
                 (eco_status = 'EXCLUDE_OPEN_HOLD'
                 AND  NVL(ERI.STATUS_TYPE,0) NOT IN (1,2)
                 )
                 /*BUG 9214280 Added the or condition*/
 	         OR
 	         (eco_status = 'EXCLUDE_ALL'
 	          AND  NVL(ERI.STATUS_TYPE,0) IN (0,6)
 	         )
 	         /*End of BUG 9214280*/
              )
         ORDER BY MIR.EFFECTIVITY_DATE DESC, MIR.REVISION DESC;

    CURSOR NO_ECO_ITEM_REV IS
       SELECT REVISION
       FROM   MTL_ITEM_REVISIONS_B MIR
       WHERE  INVENTORY_ITEM_ID = item_id
       AND    ORGANIZATION_ID = org_id
       AND    MIR.EFFECTIVITY_DATE <= rev_date
       AND    ( (examine_type = 'ALL')
                 OR
		(examine_type = 'IMPL_ONLY'
                     AND IMPLEMENTATION_DATE IS NOT NULL
                )
                 OR
		(examine_type = 'PEND_ONLY'
                     AND IMPLEMENTATION_DATE IS NULL
                )
              )
        ORDER BY EFFECTIVITY_DATE DESC, REVISION DESC;

BEGIN
    IF (eco_status = 'EXCLUDE_HOLD' OR eco_status = 'EXCLUDE_OPEN_HOLD'
         OR eco_status = 'EXCLUDE_ALL') THEN
    	OPEN ECO_STATUS_ITEM_REV;
	stmt_num := 1;

    	FETCH ECO_STATUS_ITEM_REV INTO itm_rev;
    	IF ECO_STATUS_ITEM_REV%NOTFOUND THEN
    	    CLOSE ECO_STATUS_ITEM_REV;
	    RETURN NULL;
    	END IF;
    	CLOSE ECO_STATUS_ITEM_REV;
        RETURN itm_rev;
    ELSE
	OPEN NO_ECO_ITEM_REV;
	stmt_num := 2;
    	FETCH NO_ECO_ITEM_REV INTO itm_rev;

    	IF NO_ECO_ITEM_REV%NOTFOUND THEN
    	    CLOSE NO_ECO_ITEM_REV;
	    RETURN NULL;
    	END IF;
    	CLOSE NO_ECO_ITEM_REV;
        RETURN itm_rev;
    END IF;

END GET_ITEM_REVISION_FN;

/* ------------------------------ GET_ITEM_REVISION_ID_FN --------------------------
   NAME
    GET_ITEM_REVISION_FN - retrieve item revision for a date , if no revision defined, return null instead
 DESCRIPTION
    retrieve teh current revision for teh given date

 REQUIRES
    type	"PART" - item revision
		"PROCESS" - routing revision
    eco_status  "ALL" - all ECOs
		"EXCLUDE_HOLD" - exclude pending revisions from ECOs
				 with HOLD status
		"EXCLUDE_OPEN_HOLD" - exclude pending revisions from ECOs
				 with HOLD or OPEN status
    examine_type "ALL" - all revisions
		"IMPL_ONLY" - only implemented revisions
		"PEND_ONLY" - only unimplemented revisions
    org_id	organization id
    item_id     item id
    rev_date    date for which revision desired
 OUTPUT
    itm_rev		revision_id
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/
FUNCTION GET_ITEM_REVISION_ID_FN(
	eco_status		IN VARCHAR2 DEFAULT 'ALL',
	examine_type		IN VARCHAR2 DEFAULT 'ALL',
	org_id			IN NUMBER,
	item_id			IN NUMBER,
	rev_date		IN DATE
)
RETURN NUMBER IS
    stmt_num    NUMBER;
    itm_rev     VARCHAR2(3);
    revision_id NUMBER;

    CURSOR ECO_STATUS_ITEM_REV IS
	SELECT REVISION_ID
        FROM   MTL_ITEM_REVISIONS_B MIR, ENG_REVISED_ITEMS ERI
        WHERE  MIR.INVENTORY_ITEM_ID = item_id
        AND    MIR.ORGANIZATION_ID = org_id
        AND    MIR.EFFECTIVITY_DATE <= rev_date
        AND    MIR.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID(+)
        AND   (
                 (eco_status = 'EXCLUDE_HOLD'
                 AND  NVL(ERI.STATUS_TYPE,0) NOT IN (2)
                 )
                 OR
                 (eco_status = 'EXCLUDE_OPEN_HOLD'
                 AND  NVL(ERI.STATUS_TYPE,0) NOT IN (1,2)
                 )
              )
         ORDER BY MIR.EFFECTIVITY_DATE DESC, MIR.REVISION DESC;

    CURSOR NO_ECO_ITEM_REV IS
       SELECT REVISION_ID
       FROM   MTL_ITEM_REVISIONS_B MIR
       WHERE  INVENTORY_ITEM_ID = item_id
       AND    ORGANIZATION_ID = org_id
       AND    MIR.EFFECTIVITY_DATE <= rev_date
       AND    ( (examine_type = 'ALL')
                 OR
		(examine_type = 'IMPL_ONLY'
                     AND IMPLEMENTATION_DATE IS NOT NULL
                )
                 OR
		(examine_type = 'PEND_ONLY'
                     AND IMPLEMENTATION_DATE IS NULL
                )
              )
        ORDER BY EFFECTIVITY_DATE DESC, REVISION DESC;

BEGIN
    IF (eco_status = 'EXCLUDE_HOLD' OR eco_status = 'EXCLUDE_OPEN_HOLD') THEN
    	OPEN ECO_STATUS_ITEM_REV;
	stmt_num := 1;

    	FETCH ECO_STATUS_ITEM_REV INTO revision_id;
    	IF ECO_STATUS_ITEM_REV%NOTFOUND THEN
    	    CLOSE ECO_STATUS_ITEM_REV;
	    RETURN NULL;
    	END IF;
    	CLOSE ECO_STATUS_ITEM_REV;
        RETURN revision_id;
    ELSE
	OPEN NO_ECO_ITEM_REV;
	stmt_num := 2;
    	FETCH NO_ECO_ITEM_REV INTO revision_id;

    	IF NO_ECO_ITEM_REV%NOTFOUND THEN
    	    CLOSE NO_ECO_ITEM_REV;
	    RETURN NULL;
    	END IF;
    	CLOSE NO_ECO_ITEM_REV;
        RETURN revision_id;
    END IF;

END GET_ITEM_REVISION_ID_FN;

/* --------------------------- GET_ROUTING_REVISION ------------------------
   NAME
    GET_ROUTING_REVISION - retrieve routing revision for a date
 DESCRIPTION
    retrieve teh current revision for teh given date

 REQUIRES
    org_id	organization id
    item_id     item id
    rev_date    date for which revision desired
 OUTPUT
    itm_rev		revision
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/
PROCEDURE GET_ROUTING_REVISION(
	eco_status		IN VARCHAR2 DEFAULT 'ALL',  -- BUG 3940863
	org_id			IN NUMBER,
	item_id			IN NUMBER,
	rev_date		IN DATE,
	itm_rev			 IN OUT NOCOPY  VARCHAR2,
        examine_type            IN VARCHAR2 DEFAULT 'ALL'  -- BUG 3779027
)
IS

    stmt_num    NUMBER;

    -- Added Cursor for  BUG 3940863
    CURSOR ECO_STATUS_RTG_REV IS
	SELECT PROCESS_REVISION
        FROM   MTL_RTG_ITEM_REVISIONS MIR, ENG_REVISED_ITEMS ERI
        WHERE  MIR.INVENTORY_ITEM_ID = item_id
        AND    MIR.ORGANIZATION_ID = org_id
        AND    MIR.EFFECTIVITY_DATE  <= rev_date  --Bug 3020310
        AND    MIR.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID(+)
        AND   (
                 (eco_status = 'EXCLUDE_HOLD'
                 AND  NVL(ERI.STATUS_TYPE,0) NOT IN (2)
                 )
                 OR
                 (eco_status = 'EXCLUDE_OPEN_HOLD'
                 AND  NVL(ERI.STATUS_TYPE,0) NOT IN (1,2)
                 )
                 OR					-- BUG 4127493
                (eco_status = 'EXCLUDE_ALL'
                 AND  NVL(ERI.STATUS_TYPE,0) IN (0,6)
		)
              )
         ORDER BY MIR.EFFECTIVITY_DATE DESC, MIR.PROCESS_REVISION DESC;


    CURSOR RTG_REV IS
	SELECT PROCESS_REVISION
	FROM   MTL_RTG_ITEM_REVISIONS
	WHERE  INVENTORY_ITEM_ID = item_id
	AND    ORGANIZATION_ID = org_id
--	AND    trunc(EFFECTIVITY_DATE) <= trunc(rev_date)  -- changed for bug 2631052
	AND    EFFECTIVITY_DATE <= rev_date
        AND    ( (examine_type = 'ALL')                    -- BUG 3779027
                 OR
                 (examine_type = 'IMPL_ONLY'
                    AND IMPLEMENTATION_DATE IS NOT NULL
                 )
                 OR
                 (examine_type = 'PEND_ONLY'
                    AND IMPLEMENTATION_DATE IS NULL
                 )
               )
	ORDER BY EFFECTIVITY_DATE DESC, PROCESS_REVISION DESC;

BEGIN

    -- Added IF conditions for BUG 3940863
    IF (eco_status = 'EXCLUDE_HOLD' OR eco_status = 'EXCLUDE_OPEN_HOLD'
           OR eco_status = 'EXCLUDE_ALL') THEN		-- BUG 4127493
    	OPEN ECO_STATUS_RTG_REV;
	stmt_num := 1;
    	FETCH ECO_STATUS_RTG_REV INTO itm_rev;
    	  IF ECO_STATUS_RTG_REV%NOTFOUND THEN
    	    CLOSE ECO_STATUS_RTG_REV;
	    RAISE_NO_REV_ERROR (
			org_id => org_id,
			part_id => item_id,
			rev_date => rev_date);
    	  END IF;
    	CLOSE ECO_STATUS_RTG_REV;
    ELSE
        OPEN RTG_REV;
	stmt_num := 2;
        FETCH RTG_REV INTO itm_rev;
          IF RTG_REV%NOTFOUND THEN
    	    CLOSE RTG_REV;
	    RAISE_NO_REV_ERROR (
			org_id => org_id,
			part_id => item_id,
			rev_date => rev_date);
          END IF;
        CLOSE RTG_REV;
    END IF;


END GET_ROUTING_REVISION;

/* ------------------------------- GET_REVISION ---- ------------------------
   NAME
    GET_REVISION - retrieve item/routing revision for a date
 DESCRIPTION
    retrieve teh current revision for teh given date

 REQUIRES
    type	"PART" - item revision
		"PROCESS" - routing revision
    eco_status  "ALL" - all ECOs
		"EXCLUDE_HOLD" - exclude pending revisions from ECOs
				 with HOLD status
		"EXCLUDE_OPEN_HOLD" - exclude pending revisions from ECOs
				 with HOLD or OPEN status
                "EXCLUDE_ALL"   -  Exclude all revisions except the Implemented
    examine_type "ALL" - all revisions
		"IMPL_ONLY" - only implemented revisions
		"PEND_ONLY" - only unimplemented revisions
    org_id	organization id
    item_id     item id
    rev_date    date for which revision desired
 OUTPUT
    itm_rev		revision
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/
PROCEDURE GET_REVISION(
	type			IN VARCHAR2 DEFAULT 'PART',
	eco_status		IN VARCHAR2 DEFAULT 'ALL',
	examine_type		IN VARCHAR2 DEFAULT 'ALL',
	org_id			IN NUMBER,
	item_id			IN NUMBER,
	rev_date		IN DATE,
	itm_rev			 IN OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    IF (type = 'PART') THEN
	GET_ITEM_REVISION (
		eco_status,
		examine_type,
		org_id,
		item_id,
		rev_date,
		itm_rev);
    ELSE
	GET_ROUTING_REVISION (
		eco_status,    -- BUG 3940863
		org_id,
		item_id,
		rev_date,
		itm_rev,
                examine_type            -- BUG 3779027
                );
    END IF;
END GET_REVISION;


/* ------------------------------- COMPARE_REVISION ---------------------------
   NAME
    COMPARE_REVISION - compare 2 revisions
 DESCRIPTION
    compare 2 revisions

 REQUIRES
    rev1	revision 1
    rev2	revision 2
 OUTPUT
 RETURNS
    0 if rev1 = rev2
    1 if rev1 > rev2
    2 if rev1 < rev2
 NOTES
 ---------------------------------------------------------------------------*/
FUNCTION COMPARE_REVISION(
	rev1			IN  VARCHAR2,
	rev2			IN  VARCHAR2
) RETURN INTEGER
IS
BEGIN
    IF ((rev1 is NULL OR rev1 = '') and
        (rev2 is NULL OR rev2 = '')) THEN
	return(0);
    END IF;

    IF rev1 = rev2 THEN
	RETURN (0);
    END IF;

    IF (rev1 IS NULL OR rev1 = FND_API.G_MISS_CHAR) THEN
	RETURN(2);
    ELSIF (rev2 IS NULL OR rev2 = FND_API.G_MISS_CHAR) THEN
	RETURN(1);
    ELSIF (rev1 > rev2) THEN
	RETURN(2);
    ELSE
	RETURN(1);
    END IF;

END COMPARE_REVISION;

/* ------------------------------- GET_REV_DATE ---- ------------------------
   NAME
    GET_REV_DATE - retrieve date for given revision
 DESCRIPTION
    retrieve revision start date for given revision

 REQUIRES
    type	"PART" - item revision
		"PROCESS" - routing revision
    org_id	organization id
    item_id     item id
    itm_rev		revision
 OUTPUT
    rev_date    effecitive date of revision
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/
PROCEDURE GET_REV_DATE (
	type			IN VARCHAR2 DEFAULT 'PART',
	org_id			IN NUMBER,
	item_id			IN NUMBER,
	itm_rev			IN VARCHAR2,
	rev_date		 IN OUT NOCOPY  DATE
)
IS
    CURSOR ITEM_REV IS
        SELECT  EFFECTIVITY_DATE
        FROM    MTL_ITEM_REVISIONS_B
        WHERE   INVENTORY_ITEM_ID = item_id
        AND     REVISION = itm_rev
        AND     ORGANIZATION_ID = org_id;

    CURSOR RTG_REV IS
        SELECT  EFFECTIVITY_DATE
        FROM    MTL_RTG_ITEM_REVISIONS
        WHERE   INVENTORY_ITEM_ID = item_id
        AND     PROCESS_REVISION = itm_rev
        AND     ORGANIZATION_ID = org_id;

BEGIN
    IF (type = 'PART') THEN
	OPEN ITEM_REV;
	FETCH ITEM_REV INTO rev_date;
	IF (ITEM_REV%NOTFOUND) THEN
	    CLOSE ITEM_REV;
	    FND_MESSAGE.SET_NAME('BOM', 'BOM_GET_REVDATE');
	    FND_MESSAGE.SET_TOKEN('REVISION', itm_rev);
	    APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
	CLOSE ITEM_REV;
    ELSE /* IF (type = PROCESS) THEN */
	OPEN RTG_REV;
	FETCH RTG_REV INTO rev_date;
	IF (ITEM_REV%NOTFOUND) THEN
	    CLOSE RTG_REV;
	    FND_MESSAGE.SET_NAME('BOM', 'BOM_GET_REVDATE');
	    FND_MESSAGE.SET_TOKEN('REVISION', itm_rev);
	    APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
	CLOSE RTG_REV;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	RAISE_REVISION_ERROR (
		func_name => 'GET_REV_DATE',
		stmt_num  => 1);
END GET_REV_DATE;

/* ------------------------------- GET_HIGH_DATE ---- ------------------------
   NAME
    GET_HIGH_DATE - retreive the high date of the revision
 DESCRIPTION
    retrieve the high date of the revision.  For the greatest rev, high
    date is greater of sysdate, effective_date for the revision

 REQUIRES
    type	"PART" - item revision
		"PROCESS" - routing revision
    org_id	organization id
    item_id     item id
    eco_status  "ALL" - all ECOs
		"EXCLUDE_HOLD" - exclude pending revisions from ECOs
				 with HOLD status
		"EXCLUDE_OPEN_HOLD" - exclude pending revisions from ECOs
				 with HOLD or OPEN status
                "EXCLUDE_ALL"   -  Exclude all revisions except the Implemented
 OUTPUT
    itm_rev		revision
    rev_date    high date
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/
PROCEDURE GET_HIGH_DATE (
	type			IN VARCHAR2 DEFAULT 'PART',
	org_id			IN NUMBER,
	item_id			IN NUMBER,
	eco_status		IN VARCHAR2,
	itm_rev			IN VARCHAR2,
	rev_date	        IN OUT NOCOPY DATE
)
IS
    stmt_num	INTEGER;
    l_rev_date  DATE;
    l_item_name MTL_SYSTEM_ITEMS_VL.CONCATENATED_SEGMENTS%TYPE;

BEGIN
    IF (type = 'PART') THEN
        IF (eco_status = 'EXCLUDE_HOLD' OR
                 eco_status = 'EXCLUDE_OPEN_HOLD' OR
                  eco_status  = 'EXCLUDE_ALL') THEN
	    stmt_num := 1;
            SELECT MIN(A.EFFECTIVITY_DATE - 60/(60*60*24))
                 INTO   l_rev_date
                 FROM   MTL_ITEM_REVISIONS_B A
                 WHERE  A.INVENTORY_ITEM_ID = item_id
                 AND    A.ORGANIZATION_ID = org_id
                 AND    A.EFFECTIVITY_DATE >
                           (SELECT EFFECTIVITY_DATE
                            FROM   MTL_ITEM_REVISIONS_B
                            WHERE  INVENTORY_ITEM_ID = item_id
                            AND    ORGANIZATION_ID = org_id
                            AND    REVISION = itm_rev
                           )
                 AND    NOT EXISTS
                          ( SELECT 'X'
                            FROM   ENG_REVISED_ITEMS B
                            WHERE  A.REVISED_ITEM_SEQUENCE_ID =
                                       B.REVISED_ITEM_SEQUENCE_ID
                            AND
                            (
                               (eco_status = 'EXCLUDE_HOLD'
                                  AND  B.STATUS_TYPE = 2
                               )
                               OR
                               (eco_status = 'EXCLUDE_OPEN_HOLD'
                                  AND  B.STATUS_TYPE IN (1,2)
                               )
                               OR
                              (eco_status = 'EXCLUDE_ALL'
                                  AND  B.STATUS_TYPE = 6
                               )
                            )
                          );
            ELSE
		stmt_num := 2;
                 SELECT MIN(EFFECTIVITY_DATE - 60/(60*60*24))
                 INTO   l_rev_date
                 FROM   MTL_ITEM_REVISIONS_B
                 WHERE  INVENTORY_ITEM_ID = item_id
                 AND    ORGANIZATION_ID = org_id
                 AND    EFFECTIVITY_DATE >
                           (SELECT EFFECTIVITY_DATE
                            FROM   MTL_ITEM_REVISIONS_B
                            WHERE  INVENTORY_ITEM_ID = item_id
                            AND    ORGANIZATION_ID = org_id
                            AND    REVISION = itm_rev
                           );
	    END IF;
    ELSE
	stmt_num := 3;
	SELECT MIN(EFFECTIVITY_DATE - 1/(60*60*24))
        INTO   l_rev_date
        FROM   MTL_RTG_ITEM_REVISIONS
        WHERE  INVENTORY_ITEM_ID = item_id
        AND    ORGANIZATION_ID = org_id
        AND    EFFECTIVITY_DATE >
               (SELECT EFFECTIVITY_DATE
                FROM   MTL_RTG_ITEM_REVISIONS
                WHERE  INVENTORY_ITEM_ID = item_id
                AND    ORGANIZATION_ID = org_id
                AND    PROCESS_REVISION = itm_rev);
/*
	SELECT MIN(EFFECTIVITY_DATE - 60/(60*60*24))  -- changed for bug 2631052
        INTO   l_rev_date
        FROM   MTL_RTG_ITEM_REVISIONS
        WHERE  INVENTORY_ITEM_ID = item_id
        AND    ORGANIZATION_ID = org_id
        AND    trunc(EFFECTIVITY_DATE) >
               (SELECT trunc(EFFECTIVITY_DATE)
                FROM   MTL_RTG_ITEM_REVISIONS
                WHERE  INVENTORY_ITEM_ID = item_id
                AND    ORGANIZATION_ID = org_id
                AND    PROCESS_REVISION = itm_rev);
*/
    END IF;

    IF l_rev_date is NULL THEN
/*
** implies that rev is the last rev.  So, if today < eff_date, then
** return eff_date, else return today
*/

 	IF (type = 'PART') THEN
	    stmt_num := 4;
            SELECT GREATEST(EFFECTIVITY_DATE,SYSDATE)
            INTO   l_rev_date
            FROM   MTL_ITEM_REVISIONS_B
            WHERE  INVENTORY_ITEM_ID = item_id
            AND    ORGANIZATION_ID = org_id
            AND    REVISION = itm_rev;
	ELSE
	    stmt_num := 5;
            SELECT GREATEST(EFFECTIVITY_DATE,SYSDATE)
            INTO   l_rev_date
            FROM   MTL_RTG_ITEM_REVISIONS
            WHERE  INVENTORY_ITEM_ID = item_id
            AND    ORGANIZATION_ID = org_id
            AND    PROCESS_REVISION = itm_rev;
	END IF;
    END IF;

    rev_date := l_rev_date;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
/*
** display message to say item rev not valid
** Name: MFG_NOT_VALID
** ENTITY: itm_rev
	FND_MESSAGE.SET_NAME('INV', 'INV_NOT_VALID');
	FND_MESSAGE.SET_TOKEN('ENTITY', itm_rev);
	APP_EXCEPTION.RAISE_EXCEPTION;
*/
    -- bug:2120090 Raise meaningful error as Revision does not exist.
    -- Get the Item Name from Id
    SELECT  msivl.CONCATENATED_SEGMENTS
    INTO    l_item_name
    FROM    MTL_SYSTEM_ITEMS_VL msivl
    WHERE   msivl.INVENTORY_ITEM_ID = item_id
    AND     msivl.ORGANIZATION_ID   = org_id;

    FND_MESSAGE.SET_NAME('BOM', 'BOM_REVISION_DOESNOT_EXIST');
    FND_MESSAGE.SET_TOKEN('REVISION', itm_rev);
    FND_MESSAGE.SET_TOKEN('ASSEMBLY_ITEM_NAME', l_item_name);

    APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN OTHERS THEN
	RAISE_REVISION_ERROR (
		func_name => 'GET_HIGH_DATE',
		stmt_num  => stmt_num);
END GET_HIGH_DATE;

/* ---------------------------- GET_HIGH_REV_DATE ---- ------------------------
   NAME
    GET_HIGH_REV_DATE - retrieve highest rev and its high date
 DESCRIPTION
    retrievehighest revsion adn its high date

 REQUIRES
    type	"PART" - item revision
		"PROCESS" - routing revision
    examine_type "ALL" - all revisions
		"IMPL_ONLY" - only implemented revisions
		"PEND_ONLY" - only unimplemented revisions
    org_id	organization id
    item_id     item id
 OUTPUT
    rev_date    high date for revision
    itm_rev		highest revision
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/
PROCEDURE GET_HIGH_REV_DATE(
	type			IN VARCHAR2 DEFAULT 'PART',
	examine_type		IN VARCHAR2 DEFAULT 'ALL',
	org_id			IN NUMBER,
	item_id			IN NUMBER,
	rev_date		 IN OUT NOCOPY  DATE,
	itm_rev			 IN OUT NOCOPY  VARCHAR2
)
IS
    l_rev	MTL_ITEM_REVISIONS_B.REVISION%TYPE;

    CURSOR ITEM_REV IS
       SELECT REVISION
       FROM   MTL_ITEM_REVISIONS_B
       WHERE  INVENTORY_ITEM_ID = item_id
       AND    ORGANIZATION_ID = org_id
       AND    (
                (examine_type = 'ALL')
                OR
		(examine_type = 'IMPL_ONLY'
                   AND IMPLEMENTATION_DATE IS NOT NULL
                )
                OR
	 	(examine_type = 'PEND_ONLY'
                   AND IMPLEMENTATION_DATE IS NULL
                )
              )
       ORDER BY EFFECTIVITY_DATE DESC, REVISION DESC;

    CURSOR RTG_REV IS
       SELECT PROCESS_REVISION
       FROM   MTL_RTG_ITEM_REVISIONS
       WHERE  INVENTORY_ITEM_ID = item_id
       AND    ORGANIZATION_ID = org_id
       AND    (
                (examine_type = 'ALL')
                OR
		(examine_type = 'IMPL_ONLY'
                   AND IMPLEMENTATION_DATE IS NOT NULL
                )
                OR
	 	(examine_type = 'IMPL_AND_PEND'
                   AND IMPLEMENTATION_DATE IS NULL
                )
              )
       ORDER BY EFFECTIVITY_DATE DESC, PROCESS_REVISION DESC;

BEGIN
    IF (type = 'PART') THEN
	OPEN ITEM_REV;
	FETCH ITEM_REV INTO l_rev;
	IF ITEM_REV%NOTFOUND THEN
	    CLOSE ITEM_REV;
	    FND_MESSAGE.SET_NAME('BOM', 'BOM_GET_REV_DATE');
	    APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
	CLOSE ITEM_REV;
    ELSE
	OPEN RTG_REV;
	FETCH RTG_REV INTO l_rev;
	IF RTG_REV%NOTFOUND THEN
	    CLOSE RTG_REV;
	    FND_MESSAGE.SET_NAME('BOM', 'BOM_GET_REV_DATE');
	    APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
	CLOSE RTG_REV;

    END IF;

    itm_rev	:= l_rev;

    GET_HIGH_DATE(
	type		=> type,
	org_id		=> org_id,
	item_id		=> item_id,
	eco_status	=> 'ALL',
	itm_rev		=> l_rev,
	rev_date	=> rev_date);

EXCEPTION
    WHEN OTHERS THEN
	RAISE_REVISION_ERROR (
		func_name => 'GET_HIGH_REV_DATE',
		stmt_num  => 1);
END GET_HIGH_REV_DATE;

FUNCTION GET_ITEM_REV_HIGHDATE(
        p_revision_id  IN NUMBER) RETURN DATE
IS
  l_date DATE;
BEGIN

  SELECT high_date INTO l_date FROM mtl_item_rev_highdate_v WHERE revision_id = p_revision_id;
  return l_date;

  EXCEPTION WHEN OTHERS THEN
    return null;
END;


END BOM_REVISIONS;

/
