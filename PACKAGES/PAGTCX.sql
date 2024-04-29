--------------------------------------------------------
--  DDL for Package PAGTCX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAGTCX" AUTHID CURRENT_USER AS
  /* $Header: PAXTGTCS.pls 120.4 2006/07/29 11:40:26 skannoji noship $ */
  /*#
   * Oracle Projects provides a package that contains the procedure that you can modify to implement
   * the summmary validation extension for an expenditure.
   * @rep:scope public
   * @rep:product PA
   * @rep:lifecycle active
   * @rep:displayname Summary Validation Extension
   * @rep:compatibility S
   * @rep:category BUSINESS_ENTITY PA_PROJECT
   * @rep:category BUSINESS_ENTITY PA_LABOR_COST
   * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
   */

   /*#
    * Procedure that can be modified to implement the summary validation extension.
    * @param P_Timecard_Table The entire timecard in PL/SQL table format (used when the extension is called from Oracle Time and Labor)
    * @rep:paraminfo {@rep:required}
    * @param P_Module Application calling this extension (for example, OTL for Oracle Time and Labor)
    * @rep:paraminfo {@rep:required}
    * @param X_Expenditure_Id The internal identifier of the expenditure
    * @rep:paraminfo {@rep:required}
    * @param X_Incurred_By_Person_Id The identifier of the employee who submitted the expenditure
    * @rep:paraminfo {@rep:required}
    * @param X_Expenditure_End_Date The ending date of the expenditure period
    * @rep:paraminfo {@rep:required}
    * @param X_Exp_Class_Code Identifier of the expenditure type( OT for timesheets or OE for expense reports)
    * @rep:paraminfo {@rep:required}
    * @param X_Status Status indicating whether an error occurred. The valid values are =0 (Success), <0 OR >0 (Application Error)
    * @rep:paraminfo {@rep:required}
    * @param X_comment Comment to be passed back to employee submitting expenditure
    * @rep:paraminfo {@rep:required}
    * @param P_Action_Code The action being performed in when calling extension(For OIT only)
    * @rep:paraminfo {@rep:required}
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Summary Validation Extension
    * @rep:compatibility S
    */

   dummy Pa_Otc_Api.Timecard_Table;

  PROCEDURE  Summary_Validation_Extension (
               P_Timecard_Table             IN Pa_Otc_Api.Timecard_Table DEFAULT PAGTCX.dummy
            ,  P_Module                     IN VARCHAR2 DEFAULT NULL
            ,  X_expenditure_id             IN NUMBER DEFAULT NULL
            ,  X_incurred_by_person_id      IN NUMBER
            ,  X_expenditure_end_date       IN DATE
            ,  X_exp_class_code             IN VARCHAR2
            ,  X_status                     OUT NOCOPY VARCHAR2
            ,  X_comment                    OUT NOCOPY VARCHAR2
            ,  P_Action_Code                IN VARCHAR2 DEFAULT NULL ); /*Added for Bug#3036106 */

END  PAGTCX;
 

/
