--------------------------------------------------------
--  DDL for Package AP_CARD_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CARD_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: apwpcuts.pls 120.4 2006/10/26 15:31:34 pranpaul noship $ */

C_ApplicationID          CONSTANT NUMBER := 601;
SUBTYPE expFeedDists_costCenter     		IS AP_EXPENSE_FEED_DISTS.cost_center%TYPE;

-------------------------------------------------------------------------------

FUNCTION get_combination_id(p_application_short_name 	IN  VARCHAR2,
			    p_key_flex_code	IN  VARCHAR2,
			    p_structure_number	IN  NUMBER,
			    p_validation_date	IN  DATE,
			    p_n_segments	IN  NUMBER,
			    p_segments		IN  fnd_flex_ext.SegmentArray,
                            p_concatSegments    IN  VARCHAR2,
			    p_combination_id OUT NOCOPY NUMBER,
                            p_return_error_message IN  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

-------------------------------------------------------------------------------
FUNCTION validateSession(p_func   IN varchar2 default NULL,
			 p_commit IN boolean default TRUE,
			 p_update IN boolean default TRUE)
RETURN BOOLEAN;

-------------------------------------------------------------------------------
PROCEDURE JumpIntoFunction(p_id	        IN NUMBER,
			   p_mode	IN VARCHAR2,
			   p_url OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------

PROCEDURE ICXSetOrgContext(p_session_id	IN VARCHAR2,
			   p_org_id	IN VARCHAR2);

-------------------------------------------------------------------------------
/*The following procedures have been added for PCARD project.
   Moved the Validate Cost Center procedure and all its dependent
   procedure to AP packages*/

PROCEDURE BUILD_ACCOUNT(
              P_CODE_COMBINATION_ID     IN NUMBER,
              P_COST_CENTER             IN VARCHAR2,
              P_ACCOUNT_SEGMENT_VALUE   IN VARCHAR2,
              P_ERROR_MESSAGE           IN VARCHAR2,
              P_CALLING_SEQUENCE        IN VARCHAR2,
              P_EMPLOYEE_ID             IN NUMBER,
	      P_CCID OUT NOCOPY VARCHAR);
PROCEDURE WF_UTILS(
	      p_desc in VARCHAR,p_out out NOCOPY VARCHAR);
FUNCTION CustomValidateCostCenter(
        p_cs_error              OUT NOCOPY VARCHAR2,
        p_CostCenterValue       IN VARCHAR2,
        p_CostCenterValid       IN OUT NOCOPY BOOLEAN,
        p_employee_id           IN NUMBER) return BOOLEAN;
PROCEDURE ValidateCostCenter(p_costcenter IN  varchar2,
			     p_cs_error     OUT NOCOPY varchar2,
        		     p_employee_id  IN  NUMBER);
FUNCTION COSTCENTERVALID(
	P_COST_CENTER		IN  EXPFEEDDISTS_COSTCENTER,
	P_VALID		 OUT NOCOPY BOOLEAN,
        P_EMPLOYEE_ID           IN  NUMBER
) RETURN BOOLEAN;
FUNCTION GetDependentSegment(
        p_value_set_name        IN     fnd_flex_value_sets.flex_value_set_name%type,
        p_chart_of_accounts_id  IN NUMBER,
        p_dependent_seg_num     OUT NOCOPY  NUMBER)
RETURN BOOLEAN ;
FUNCTION GetCOAofSOB(
	p_chart_of_accounts OUT NOCOPY NUMBER
) RETURN BOOLEAN ;
FUNCTION IsPersonCwk (p_person_id IN NUMBER) return VARCHAR2;


END AP_CARD_UTILITY_PKG;

 

/
