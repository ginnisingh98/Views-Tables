--------------------------------------------------------
--  DDL for Package IGS_AD_ACT_ASSESSMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_ACT_ASSESSMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADD1S.pls 120.2 2006/04/12 03:05:35 akadam noship $ */
/* ------------------------------------------------------------------------------------------------------------------------
  ||  Created By : Stammine
  ||  Created On : 18-Nov-2004
  ||  Purpose : Import ACT Assessment Details Process
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
 ---------------------------------------------------------------------------------------------------------------------------*/
   --*****************************************************************************
  -- GLOBAL VARIABLES AND CONSTANTS
  --
G_SSN_Person_Id_Type IGS_PE_PERSON_ID_TYP.PERSON_ID_TYPE%TYPE;
G_ACT_Person_Id_Type IGS_PE_PERSON_ID_TYP.PERSON_ID_TYPE%TYPE;
G_Score_Source_id    IGS_AD_CODE_CLASSES.CODE_ID%TYPE;
G_Transcript_Source  IGS_AD_CODE_CLASSES.CODE_ID%TYPE;
G_Grading_Scale      IGS_AD_CODE_CLASSES.CODE_ID%TYPE;
G_Unit_Difficulty    IGS_AD_CODE_CLASSES.CODE_ID%TYPE;
 --*****************************************************************************

/* This function is used to generate the batch_id into the ASSESSMENT Table through SQL Loader Process */
FUNCTION get_batch_id RETURN NUMBER;


/* This function checks the Required setups for importing the data From ACT data store to Interface Tables.
   Returns the Error code 2 if the Required setup is not met.
   Returns 1 if the Required setup is met.
   This function also set the global variables to respective values requried while inserting into Interface Tables. */

FUNCTION  Check_Setups (
                  p_ACT_Batch_Id     IN IGS_AD_ACT_ASSESSMENTS.ACT_BATCH_ID%type,
		  p_Reporting_Year   IN IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
                  p_Test_Type        IN IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		  p_Test_Date        IN IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
		  p_ACT_Id           IN IGS_AD_ACT_ASSESSMENTS.act_identifier%type)
		  RETURN NUMBER;

/* This Procedure  Import the Act Data into the OSS tables.
   Process Stores the ACT Data into Interface tables and
   call the Import Process to import data from Interface tables to OSS functional Tables. */

PROCEDURE Insert_ACT_to_Interface (
                  ERRBUF             OUT NOCOPY VARCHAR2,
		  RETCODE            OUT NOCOPY NUMBER,
		  p_ACT_Batch_Id     IN IGS_AD_ACT_ASSESSMENTS.ACT_BATCH_ID%type,
		  p_Source_Type_Id   IN NUMBER,
                  p_Match_Set_Id     IN NUMBER,
		  p_Reporting_Year   IN IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
                  p_Test_Type        IN IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		  p_Test_Date        IN IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
		  p_ACT_Id           IN IGS_AD_ACT_ASSESSMENTS.ACT_IDENTIFIER%type,
          P_ADDR_USAGE_CD    IN IGS_AD_ADDRUSAGE_INT_ALL.SITE_USE_CODE%type) ;

END IGS_AD_ACT_ASSESSMENTS_PKG;

 

/
