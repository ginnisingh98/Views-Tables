--------------------------------------------------------
--  DDL for Package HR_PERSON_FLEX_LOGIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_FLEX_LOGIC" AUTHID CURRENT_USER AS
/* $Header: hrperlog.pkh 115.10 2003/07/07 18:21:05 asahay noship $ */

FF_Not_Compiled     Exception;
FF_Not_Exist        Exception;

FUNCTION GetABV
  ( p_ABV_formula_id	IN NUMBER
  , p_assignment_id	IN NUMBER
  , p_effective_date	IN DATE
  , p_session_date	IN DATE)
RETURN NUMBER ;

FUNCTION GetABV
  ( p_ABV		IN VARCHAR2
  , p_assignment_id	IN NUMBER
  , p_session_date	IN DATE		default sysdate )
RETURN NUMBER ;

FUNCTION GetABV
  ( p_ABV_formula_id  	IN NUMBER
  , p_ABV				IN VARCHAR2
  , p_assignment_id		IN NUMBER
  , p_effective_date	IN DATE
  , p_session_date		IN DATE )
RETURN NUMBER ;

Function GetAsgWorkerType
(p_AsgWorkerType_formula_id   IN NUMBER
,p_assignment_id              IN NUMBER
,p_effective_date             IN DATE
,p_session_date               IN DATE
) RETURN VARCHAR2 ;

FUNCTION GetTermTypeFormula
  (p_business_group_id   IN NUMBER)
RETURN NUMBER;

FUNCTION GetTermType
  ( p_term_formula_id    IN NUMBER
  , p_leaving_reason 	IN VARCHAR2
  , p_session_date		IN DATE)
RETURN VARCHAR2 ;

FUNCTION GetJobCategory
  ( p_job_id     	IN NUMBER
  , p_job_category 	IN VARCHAR2)
RETURN VARCHAR2 ;

PROCEDURE GetMovementCategory(
 p_organization_id         IN   NUMBER
 ,p_assignment_id          IN   NUMBER
 ,p_period_start_date      IN   DATE
 ,p_period_end_date        IN   DATE
 ,p_movement_type          IN   VARCHAR2
 ,p_assignment_type        IN   VARCHAR2  default 'E'
 ,p_movement_category OUT NOCOPY  VARCHAR2
 );

FUNCTION GetCurNH
    ( p_organization_id    IN NUMBER
    , p_assignment_id      IN VARCHAR2
    , p_report_date        IN DATE)
RETURN VARCHAR2 ;

FUNCTION GetCurNHNew
  ( p_organization_id   IN NUMBER
  , p_assignment_id     IN VARCHAR2
  , p_assignment_type   IN VARCHAR2
  , p_cur_date_from     IN DATE
  , p_cur_date_to       IN DATE)
RETURN VARCHAR2 ;


FUNCTION GetOrgAliasName
	(P_ORGANIZATION_ID  IN NUMBER,
	 P_REPORT_DATE      IN DATE)
RETURN VARCHAR2 ;


PROCEDURE Raise_FF_Not_Exist
( p_formula_id    in Number );

PROCEDURE Raise_FF_Not_Compiled
( p_formula_id    in Number );

FUNCTION GetFormulaTypeID
  (p_formula_type_name       IN VARCHAR2)
RETURN NUMBER;

FUNCTION GetFormulaID
  (p_business_group_id     IN NUMBER
  ,p_formula_name          IN VARCHAR2
  ,p_formula_type          IN VARCHAR2 )
RETURN NUMBER;

FUNCTION HeadCountForCWK
RETURN VARCHAR2;

END HR_PERSON_FLEX_LOGIC;

 

/
