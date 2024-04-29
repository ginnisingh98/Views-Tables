--------------------------------------------------------
--  DDL for Package BOM_REVISIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_REVISIONS" AUTHID CURRENT_USER AS
/* $Header: BOMREVSS.pls 120.1 2005/06/21 02:59:14 appldev ship $ */

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
    examine_type "ALL" - all revisions
		"IMPL_ONLY" - only implemented revisions
		"PEND_ONLY" - only unimplemented revisions
    org_id	organization id
    item_id     item id

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
);

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
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(GET_ITEM_REVISION_FN,WNDS,WNPS);

/* ------------------------------ GET_ITEM_REVISION_ID_FN --------------------------
   NAME
    GET_ITEM_REVISION_ID_FN - retrieve item revision for a date , if no revision defined, return null instead
 DESCRIPTION
    retrieve teh current revision for teh given date

 REQUIRES
    type        "PART" - item revision
                "PROCESS" - routing revision
    eco_status  "ALL" - all ECOs
                "EXCLUDE_HOLD" - exclude pending revisions from ECOs
                                 with HOLD status
                "EXCLUDE_OPEN_HOLD" - exclude pending revisions from ECOs
                                 with HOLD or OPEN status
    examine_type "ALL" - all revisions
                "IMPL_ONLY" - only implemented revisions
                "PEND_ONLY" - only unimplemented revisions
    org_id      organization id
    item_id     item id
    rev_date    date for which revision desired
 OUTPUT
    itm_rev             revision
 RETURNS

 NOTES
 ---------------------------------------------------------------------------*/
FUNCTION GET_ITEM_REVISION_ID_FN(
        eco_status              IN VARCHAR2 DEFAULT 'ALL',
        examine_type            IN VARCHAR2 DEFAULT 'ALL',
        org_id                  IN NUMBER,
        item_id                 IN NUMBER,
        rev_date                IN DATE
) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(GET_ITEM_REVISION_ID_FN,WNDS,WNPS);

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
) RETURN INTEGER;

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
);

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
	rev_date		 IN OUT NOCOPY  DATE
);

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
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(GET_ITEM_REVISION_LABEL_FN,WNDS,WNPS);



/* ------------------------------ GET_REVISION_DETAILS --------------------------
   NAME
    GET_REVISION_DETAILS - retrieve item revision for a date
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
);
PRAGMA RESTRICT_REFERENCES(GET_REVISION_DETAILS,WNDS,WNPS);


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
);

FUNCTION GET_ITEM_REV_HIGHDATE(
 	p_revision_id  IN NUMBER) RETURN DATE;

PRAGMA RESTRICT_REFERENCES(GET_ITEM_REV_HIGHDATE,WNDS,WNPS);

END BOM_REVISIONS;

 

/
