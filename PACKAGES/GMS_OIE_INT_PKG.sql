--------------------------------------------------------
--  DDL for Package GMS_OIE_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_OIE_INT_PKG" AUTHID CURRENT_USER AS
-- $Header: gmsoieis.pls 115.10 2002/11/26 12:28:52 srkotwal noship $

SUBTYPE		gms_awardNum	IS gms_awards_all.award_number%TYPE;
SUBTYPE		gms_awardId	IS gms_awards_all.award_id%TYPE;
SUBTYPE		gms_awardName	IS gms_awards_all.award_short_name%TYPE;

-------------------------------------------------------------------
-- Name: RaiseException
-- Desc: common routine for handling unrecoverrable(database) errors
-- Params: 	p_calling_squence - the name of the caller function
--		p_debug_info - additional error message
--		p_set_name - fnd message name
--		p_params - fnd message parameters
-------------------------------------------------------------------
PROCEDURE RaiseException(
	p_calling_sequence 	IN VARCHAR2,
	p_debug_info		IN VARCHAR2 DEFAULT '',
	p_set_name		IN VARCHAR2 DEFAULT NULL,
	p_params		IN VARCHAR2 DEFAULT ''
);


  FUNCTION GetAwardNumber(
	  		p_award_id		IN	gms_awardId,
	  		p_award_number  	OUT NOCOPY	gms_awardNum
  ) RETURN BOOLEAN;
----------
-------------------------------------------------------------------
-- Name: GetAwardInfo
-- Desc: This function returns TRUE or FALSE depending on whether
--       Award_ID and Award_Name are found for a given Award_Number
-- Params:      p_award_number - IN parameter for award_number
--              p_award_id - OUT NOCOPY param for Award_ID
--              p_award_name - OUT NOCOPY param for Award_Number
-------------------------------------------------------------------

  FUNCTION GetAwardInfo(
	  		p_award_number	IN	gms_awardNum,
	  		p_award_id 	OUT NOCOPY	gms_awardId,
	  		p_award_name  	OUT NOCOPY	gms_awardName
  ) RETURN BOOLEAN;
----------
-------------------------------------------------------------------
-- Name: GetAwardID
-- Desc: This function returns TRUE or FALSE depending on whether
--       Award_ID is found for a given Award_Number
-- Params:      p_Award_number - IN param for Award_Number
--              p_award_id - OUT NOCOPY param for Award_ID
-------------------------------------------------------------------

  FUNCTION GetAwardID(
	  		p_award_number	IN	gms_awardNum,
	  		p_award_id 	OUT NOCOPY	gms_awardId
  ) RETURN BOOLEAN;
 ----------
 -------------------------------------------------------------------
 -- Name: IsSponsoredProject
 -- Desc: This function returns TRUE or FALSE depending on whether
 --       a given project is sponsored
 -- Params:      p_project_num - IN param for Project_Number
 --              p_sponsored_flag - OUT NOCOPY param for Sponsored_Flag
 --                                 valid values are 'N' and 'Y'
 -------------------------------------------------------------------

  FUNCTION  IsSponsoredProject(
 	  	p_project_num		IN  	varchar2,
	  	p_sponsored_flag	OUT NOCOPY 	varchar2
  ) RETURN BOOLEAN;
----------
-------------------------------------------------------------------
-- Name: IsGrantsEnabled
-- Desc: This function returns TRUE or FALSE depending on whether
--       Grants Accounting is implemented
-- Params:      None
-------------------------------------------------------------------

  FUNCTION  IsGrantsEnabled RETURN BOOLEAN;
----------
-------------------------------------------------------------------
-- Name: IsAwardValid
-- Desc: This function returns TRUE or FALSE depending on whether
--       a given award_number is valid
-- Params:      p_Award_number - IN param for Award_Number
-------------------------------------------------------------------

  FUNCTION IsAwardValid(
		p_award_number		IN	gms_awardNum
  )RETURN BOOLEAN;
----------
-------------------------------------------------------------------
-- Name: AwardFundingProject
-- Desc: This function returns TRUE or FALSE depending on whether
--       Award is funding the project and/or task
-- Params:      p_award_id - IN param for Award_ID
--              p_project_id - IN param for Project_ID
--              p_task_id - IN param for Task_ID
-------------------------------------------------------------------

  FUNCTION AwardFundingProject (
		  	p_award_id	IN	NUMBER,
		  	p_project_id	IN	NUMBER,
		  	p_task_id	IN	NUMBER
  ) RETURN BOOLEAN;
----------
-------------------------------------------------------------------
-- Name: DoGrantsValidation
-- Desc: This function returns TRUE or FALSE depending on whether
--       validation for the data passes or not
-- Params:
--              p_project_id            - IN param for Project_ID
--              p_task_id               - IN param for Task_ID
--              p_award_id              - IN param for Award_ID
--              p_Award_number          - IN param for Award_Number
--              p_expenditure_type      - IN param for Expenditre_Type
--              p_expenditure_item_date - IN param for Expenditure_Item_Date
--              p_calling_module        - IN param for Calling_Module, hard coded to 'GMS-OIE'
--              p_err_msg               - OUT NOCOPY param for Error Message. Give the actual error
-------------------------------------------------------------------
  FUNCTION DoGrantsValidation ( p_project_id         IN NUMBER,
                           	p_task_id            IN NUMBER,
                           	p_award_id           IN NUMBER,
                           	p_award_number       IN VARCHAR2,
                           	p_expenditure_type   IN VARCHAR2,
                           	p_expenditure_item_date IN DATE,
                           	p_calling_module     IN VARCHAR2,
			   	p_err_msg		OUT NOCOPY VARCHAR2
			   ) RETURN BOOLEAN ;
----------
-------------------------------------------------------------------
-- Name: CreateACGenADL
-- Desc: This function returns number for Award_Set_ID. This award_set_id
--       is used for Account Generation purposes
-- Params:
--              p_award_id      - IN param for Award_ID
--              p_project_id    - IN param for Project_ID
--              p_task_id       - IN param for Task_ID
-------------------------------------------------------------------
FUNCTION CreateACGenADL(p_award_id	IN	NUMBER,
			p_project_id	IN	NUMBER,
			p_task_id	IN	NUMBER)
  RETURN NUMBER;
----------
-------------------------------------------------------------------
-- Name: DeleteACGenADL
-- Desc: This function returns Boolean, signifying whether the ADL created for
-- Account Generation process has been deleted.
--
-- Params:
--              p_award_set_id  - IN param for Award_Set_ID
-------------------------------------------------------------------
FUNCTION DeleteACGenADL(p_award_set_id	IN	NUMBER)
  RETURN BOOLEAN;
----------
-------------------------------------------------------------------
-- Name: CREATE_AWARD_DISTRIBUTIONS
-- Desc: This procedure creates the ADLs for the Invoices that are
--       successfully imported to Payables and updates the award_id
--       column in ap_invoice_distribution_lines table with the
--       award_set_id value.
--
-- Params:      p_invoice_id - IN PL/SQL table of Invoice_IDs.
--              p_source - IN param for source (SelfServie for OIE
--                         Oracle Project Accounting for PA Exp Rep etc)
-------------------------------------------------------------------

TYPE invoice_id_tab is table of number index by binary_integer;

PROCEDURE CREATE_AWARD_DISTRIBUTIONS( p_invoice_id IN gms_oie_int_pkg.invoice_id_tab);
----------
-------------------------------------------------------------------
-- Name: GMS_ENABLED
-- Desc: This is a wrapper procedure used in Invoice Import process
--       to check whether Grants Accounting is implemented.
--       This procedure calls gms_install.enable function. Function call
--       is not directly supported as the build requires sqlcheck=syntax
--       and the function call requires : sqlcheck=semantics.
--
-- Params:      p_enabled  - OUT.
--              Returns 0 - if Grants Accounting is not enabled.
--              Returns 1 - if Grants Accouting is enabled
-------------------------------------------------------------------

PROCEDURE GMS_ENABLED ( p_gms_enabled	out NOCOPY	number);

----------
END GMS_OIE_INT_PKG;

 

/
