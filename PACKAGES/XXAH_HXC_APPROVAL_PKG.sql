--------------------------------------------------------
--  DDL for Package XXAH_HXC_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_HXC_APPROVAL_PKG" 
/****************************************************************
 * Copyright Oracle Netherlands 2009
 *
 * PACKAGE       : XXAH_HXC_APPROVAL_PKG
 * DESCRIPTION   : Package with functions for customized
 *                 time approval HXCEMP workflow.
 * AUTHOR        : Kevin Bouwmeester
 *                 kevin.bouwmeester@oracle.com
 * CREATION DATE : 03-DEC-2009
 * HISTORY       : version 1.0 - 03-DEC-2009 - genesis
 *
 ****************************************************************/
IS

PROCEDURE approval_needed
( p_itemtype  IN VARCHAR2
, p_itemkey   IN VARCHAR2
, p_actid     IN NUMBER
, p_funcmode  IN VARCHAR2
, p_resultout IN OUT NOCOPY VARCHAR2
);

PROCEDURE approve_timecards
( p_errbuf         IN OUT VARCHAR2  -- OUTPUT LOG
, p_retcode        IN OUT VARCHAR2  -- 0=SUCCESS, 1=WARNING, 2=ERROR
, p_pm_person_id   IN NUMBER
, p_from_date      IN VARCHAR2
);

END XXAH_HXC_APPROVAL_PKG;
 

/
