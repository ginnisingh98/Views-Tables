--------------------------------------------------------
--  DDL for Package EDR_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_STANDARD" AUTHID CURRENT_USER AS
/* $Header: EDRSTNDS.pls 120.3.12000000.1 2007/01/18 05:55:38 appldev ship $

/* Global Variables */

G_SIGNATURE_STATUS varchar2(80):=NULL; -- Global variable which hold the status of workflow ('APPROVED','REJECTED')

/* Global Record Groups */

Type eventDetails is record(
                     event_name varchar2(240),
                     event_key  varchar2(240),
                     key_type   varchar2(40)
                    );
Type eventQuery is table of eventDetails index by binary_integer;

Type RuleInputvalues is record(
                     input_name   varchar2(240),
                     input_value  varchar2(240)
                    );
Type ameRuleinputvalues is table of ruleInputvalues index by binary_integer;



/* signature Status. This Procedure returns signature status for a given event.
   The status is for the latest event happened and has values 'PENDING','COMPLETE','ERROR' */
PROCEDURE PSIG_STATUS
	(
	p_event 	in         varchar2,
	p_event_key	in         varchar2,
      P_status    out NOCOPY varchar2
	) ;

/* signature Requirement. This Procedure returns signature requireemnt for a given event.
   The status is boolean ('TRUE','FALSE') */

PROCEDURE PSIG_REQUIRED
	(
	   p_event 	       in	      varchar2,
	   p_event_key	 in         varchar2,
         P_status        out NOCOPY boolean
	) ;

/* eRecord Requirement. This Procedure returns eRecord Requirement for a given event.
   The status is boolean ('TRUE','FALSE') */

PROCEDURE EREC_REQUIRED
	(
	   p_event 	    in         varchar2,
	   p_event_key  in         varchar2,
         P_status     out NOCOPY boolean
	) ;

/* This function will be called from forms before calling the Transaction Query form */

FUNCTION PSIG_QUERY(p_eventQuery EDR_STANDARD.eventQuery) return number;

/* This procedure will be called to get AME input variable for a given transaction*/

-- Bug 3214495 : Start

/* This is deprecated API. plz use GET_AMERULE_INPUT_VARIABLES */

 PROCEDURE GET_AMERULE_INPUT_VALUES(ameapplication     IN         varchar2,
                                    ameruleid          IN         NUMBER,
                                    amerulename        IN         VARCHAR2,
                                    ameruleinputvalues OUT NOCOPY EDR_STANDARD.ameruleinputvalues) ;


/* This is the procedure that will take Transaction id as input instead of application Name */

PROCEDURE GET_AMERULE_INPUT_VARIABLES(transactiontypeid  IN VARCHAR2,
                                      ameruleid          IN         NUMBER,
                                      amerulename        IN         VARCHAR2,
                                      ameruleinputvalues OUT NOCOPY EDR_STANDARD.ameruleinputvalues) ;


-- Bug 3214495 : End

-- --------------------------------------
-- API name     : DISPLAY_DATE
-- Type         : Public
-- Pre-reqs     : None
-- Function     : convert a date to string
-- Parameters
-- IN   :       p_date_in      DATE       date to be displayed
-- OUT  :       p_date_out     VARCHAR2   date in server timezone in display date format
-- Versions     : 1.0
-- ---------------------------------------
/* This Funcitons Returns a display date format */
  PROCEDURE DISPLAY_DATE(P_DATE_IN  IN         DATE ,
                         P_DATE_OUT OUT NOCOPY Varchar2) ;


-- --------------------------------------
-- API name     : DISPLAY_DATE_ONLY
-- Type         : Public
-- Pre-reqs     : None
-- Function     : convert a date to string
-- Parameters
-- IN   :       p_date_in      DATE       date to be displayed
-- OUT  :       p_date_out     VARCHAR2   date in server timezone in display date format
-- Versions     : 1.0   7-Nov-03
-- ---------------------------------------
/* This Funcitons Returns a display date format only  */
  PROCEDURE DISPLAY_DATE_ONLY(P_DATE_IN  IN         DATE ,
                         P_DATE_OUT OUT NOCOPY Varchar2) ;

-- --------------------------------------
-- API name     : DISPLAY_TIME_ONLY
-- Type         : Public
-- Pre-reqs     : None
-- Function     : convert a date to string
-- Parameters
-- IN   :       p_date_in      DATE       date to be displayed
-- OUT  :       p_date_out     VARCHAR2   time in server timezone in display date format
-- Versions     : 1.0   7-Nov-03
-- ---------------------------------------
/* This Funcitons Returns a display date format only  */
  PROCEDURE DISPLAY_TIME_ONLY(P_DATE_IN  IN         DATE ,
                         P_DATE_OUT OUT NOCOPY Varchar2) ;


/* This function will compare audit values and return true or false based on the the results */
 FUNCTION COMPARE_AUDITVALUES(P_TABLE_NAME IN VARCHAR2,
                              P_COLUMN     IN VARCHAR2,
                              P_PKNAME     IN VARCHAR2,
                              P_PKVALUE    IN VARCHAR2
                             )
             return varchar2;
PROCEDURE FIND_WF_NTF_RECIPIENT(P_ORIGINAL_RECIPIENT IN VARCHAR2,
                                P_MESSAGE_TYPE IN VARCHAR2,
                                P_MESSAGE_NAME IN VARCHAR2,
                                P_RECIPIENT IN OUT NOCOPY VARCHAR2,
                                P_NTF_ROUTING_COMMENTS IN OUT NOCOPY VARCHAR2,
                                P_ERR_CODE OUT NOCOPY varchar2,
                                P_ERR_MSG  OUT NOCOPY varchar2);

/*******************************************************************************
*****  This procedure returns single Descriptive flex field prompt          ****
*****  It accepts                                                           ****
*****    Application ID -- Descriptive Flexed Field owner Application       ****
*****    DESC_FLEX_DEF_NAME -- Name of the Flex Definition                  ****
*****    DESC_FLEX_CONTEXT  -- Flex Definition context(ATTRIBUTE_CATEGORY)  ****
*****    COLUMN_NAME        -- Attribute Column Name (ATTRIBUTE1 ...)       ****
*****    PROMPT_TYPE        -- Allowed Values LEFT OR ABOVE based on        ****
*****                          prompt type we return value from one of the  ****
*****                          following field                              ****
*****                          LEFT -->  FORM_LEFT_PROMPT                   ****
*****                          ABOVE --> FORM_ABOVE_PROMPT                  ****
*****    COLUMN_PROMPT      -- Returns Prompt for Column Name passed        ****
********************************************************************************/

PROCEDURE GET_DESC_FLEX_SINGLE_PROMPT(P_APPLICATION_ID     IN NUMBER,
                                      P_DESC_FLEX_DEF_NAME IN VARCHAR2,
                                      P_DESC_FLEX_CONTEXT  IN VARCHAR2,
                                      P_COLUMN_NAME        IN VARCHAR2,
                                      P_PROMPT_TYPE        IN VARCHAR2 DEFAULT 'LEFT',
                                      P_COLUMN_PROMPT      OUT NOCOPY VARCHAR2);


/*******************************************************************************
*****  This procedure returns all 30 Descriptive flex field prompt          ****
*****  It accepts                                                           ****
*****    Application ID -- Descriptive Flexed Field owner Application       ****
*****    DESC_FLEX_DEF_NAME -- Name of the Flex Definition                  ****
*****    DESC_FLEX_CONTEXT  -- Flex Definition context(ATTRIBUTE_CATEGORY)  ****
*****    PROMPT_TYPE        -- Allowed Values LEFT OR ABOVE based on        ****
*****                          prompt type we return value from one of the  ****
*****                          following field                              ****
*****                          LEFT -->  FORM_LEFT_PROMPT                   ****
*****                          ABOVE --> FORM_ABOVE_PROMPT                  ****
*****    COLUMN1_PROMPT      -- Returns Prompt for Column Name passed       ****
*****    ....... COLUMN30_PROMPT                                            ****
********************************************************************************/

PROCEDURE GET_DESC_FLEX_ALL_PROMPTS(P_APPLICATION_ID     IN NUMBER,
                                    P_DESC_FLEX_DEF_NAME IN VARCHAR2,
                                    P_DESC_FLEX_CONTEXT  IN VARCHAR2,
                                    P_PROMPT_TYPE        IN VARCHAR2 DEFAULT 'LEFT',
                                    P_COLUMN1_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN2_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN3_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN4_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN5_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN6_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN7_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN8_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN9_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN10_NAME      IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN11_NAME      IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN12_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN13_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN14_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN15_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN16_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN17_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN18_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN19_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN20_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN21_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN22_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN23_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN24_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN25_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN26_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN27_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN28_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN29_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN30_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN1_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN2_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN3_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN4_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN5_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN6_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN7_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN8_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN9_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN10_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN11_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN12_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN13_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN14_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN15_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN16_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN17_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN18_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN19_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN20_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN21_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN22_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN23_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN24_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN25_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN26_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN27_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN28_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN29_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN30_PROMPT    OUT NOCOPY VARCHAR2);

 --Bug 4501520 :rvsingh: start
/*******************************************************************************
*****  This procedure returns all 30 Descriptive flex field values          ****
*****  It accepts                                                           ****
*****    Application ID -- Descriptive Flexed Field owner Application       ****
*****    DESC_FLEX_DEF_NAME -- Name of the Flex Definition                  ****
*****    DESC_FLEX_CONTEXT  -- Flex Definition context(ATTRIBUTE_CATEGORY)  ****
*****    P_COLUMN1_NAME ..P_COLUMN30_NAME     --  Name of the columns       ****
*****    P_COLUMN1_ID_VAL ..P_COLUMN30_ID_VAL -- ID or values of columns passed*
*****                          if the id is passed  then corresponding value****
*****                             else                                      ****
*****                               value is returned                       ****
*****    COLUMN1_VAL      -- Returns value for Column Name passed           ****
*****    ....... COLUMN30_VAL                                               ****
********************************************************************************/

PROCEDURE GET_DESC_FLEX_ALL_VALUES(P_APPLICATION_ID     IN NUMBER,
                                    P_DESC_FLEX_DEF_NAME IN VARCHAR2,
                                    P_DESC_FLEX_CONTEXT  IN VARCHAR2,
                                    P_COLUMN1_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN2_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN3_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN4_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN5_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN6_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN7_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN8_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN9_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN10_NAME      IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN11_NAME      IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN12_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN13_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN14_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN15_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN16_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN17_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN18_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN19_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN20_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN21_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN22_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN23_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN24_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN25_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN26_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN27_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN28_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN29_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN30_NAME       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN1_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN2_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN3_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN4_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN5_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN6_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN7_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN8_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN9_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN10_ID_VAL      IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN11_ID_VAL      IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN12_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN13_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN14_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN15_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN16_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN17_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN18_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN19_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN20_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN21_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN22_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN23_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN24_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN25_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN26_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN27_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN28_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN29_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN30_ID_VAL       IN VARCHAR2 DEFAULT NULL,
                                    P_COLUMN1_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN2_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN3_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN4_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN5_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN6_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN7_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN8_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN9_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN10_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN11_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN12_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN13_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN14_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN15_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN16_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN17_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN18_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN19_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN20_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN21_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN22_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN23_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN24_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN25_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN26_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN27_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN28_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN29_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN30_VAL    OUT NOCOPY VARCHAR2);

 --Bug 4501520 :rvsingh: end
/*******************************************************************************
*****  This procedure returns Lookup code meaning                           ****
*****  It accepts                                                           ****
*****   LOOKUP_TYPE and LOOKUP CODE as in parameter and Returns MEANING     ****
*****   as out parameter.  This uses FND_LOOKUPS View                       ****
********************************************************************************/

PROCEDURE GET_MEANING(P_LOOKUP_TYPE IN VARCHAR2,
                      P_LOOKUP_CODE IN VARCHAR2,
                      P_MEANING     OUT NOCOPY VARCHAR2);

/*******************************************************************************
*****  This procedure returns USER RESPONSE                                 ****
*****  It accepts                                                           ****
*****   LOOKUP_TYPE and PSIG_STATUS as in parameter and Returns RESPONSE     ****
*****   as out parameter.  This uses FND_LOOKUPS View                       ****
********************************************************************************/
-- Bug 4865689 :start
PROCEDURE GET_USER_RESPONSE(P_LOOKUP_TYPE IN VARCHAR2,
                      P_PSIG_STATUS IN VARCHAR2,
                      P_RESPONSE     OUT NOCOPY VARCHAR2);

-- Bug 4865689 :end
/**** It is a simplied version wrapped over PSIG_QUERY for Java api ***/

PROCEDURE PSIG_QUERY_ONE (p_event_name 	IN FND_TABLE_OF_VARCHAR2_255,
			  p_event_key  	IN FND_TABLE_OF_VARCHAR2_255,
			  o_query_id	OUT NOCOPY NUMBER );
end edr_STANDARD;

 

/
