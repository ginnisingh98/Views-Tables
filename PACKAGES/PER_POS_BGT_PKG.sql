--------------------------------------------------------
--  DDL for Package PER_POS_BGT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_BGT_PKG" AUTHID CURRENT_USER AS
/* $Header: pebgt03t.pkh 115.0 99/07/17 18:47:22 porting ship $ */
--
/* PROCEDURE GET_HOLDERS: Calculates the number of people holding
   a position and returns the holders name and emp no if only one
   else returns an appropriate message if number of holders is zero
   or greater than one to X_HOLDER_NAME.
*/
procedure get_holders(X_POSITION_ID NUMBER,
                      X_ORGANIZATION_ID   NUMBER,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_NO_OF_HOLDERS    IN OUT VARCHAR2,
                      X_HOLDER_NAME      IN OUT VARCHAR2,
                      X_HOLDER_EMP_NO    IN OUT VARCHAR2) ;
/* PROCEDURE GET_BUDGET_VALUE: Returns the budgeted value for the position.
*/
PROCEDURE GET_BUDGET_VALUE(X_BUDGET_VALUE IN OUT NUMBER,
                           X_BUDGET_VALUE_ID IN OUT NUMBER,
                           X_POSITION_ID NUMBER,
                           X_BUDGET_VERSION_ID NUMBER,
                           X_TIME_PERIOD_ID NUMBER) ;
/* PROCEDURE GET_PERIOD_START: Returns the count as of the start date for the
			       selected period.
*/
--
--
-- Changed datatype from VARCHAR2 to DATE for X_START_DATE.  PASHUN. 31-10-1997.
-- BUG : 572545.
--
--
PROCEDURE GET_PERIOD_START(X_PERIOD_START IN OUT NUMBER,
                        X_POSITION_ID NUMBER,
                        X_BUSINESS_GROUP_ID NUMBER,
                        X_START_DATE DATE,
                        X_UNIT VARCHAR2) ;
/* PROCEDURE GET_PERIOD_END: Returns the count as of the end date for the
			     selected period
*/
--
--
-- Changed datatype from VARCHAR2 to DATE for X_END_DATE.  PASHUN.  31-10-1997.
-- BUG : 572545.
--
--
PROCEDURE GET_PERIOD_END(X_PERIOD_END IN OUT NUMBER,
                        X_POSITION_ID NUMBER,
                        X_BUSINESS_GROUP_ID NUMBER,
                        X_END_DATE DATE,
                        X_UNIT VARCHAR2) ;
/* PROCEDURE GET_STARTERS: Calculates the number of persons attaining
                           a position within a period.
*/
--
--
-- Changed datatype from VARCHAR2 to DATE for X_END_DATE and  X_START_DATE.
-- PASHUN.  31-10-1997. BUG : 572545.
--
--
PROCEDURE GET_STARTERS(X_STARTERS IN OUT NUMBER,
                       X_POSITION_ID NUMBER,
                       X_BUSINESS_GROUP_ID NUMBER,
                       X_START_DATE DATE,
                       X_END_DATE DATE,
                       X_UNIT VARCHAR2) ;
/* PROCEDURE GET_LEAVERS: Calculates the number of persons leaving
                          a position within a period.
*/
--
--
-- Changed datatype from VARCHAR2 to DATE for X_START_DATE and X_END_DATE.
-- PASHUN.  31-10-1997. BUG : 572545.
--
--
PROCEDURE GET_LEAVERS(X_LEAVERS IN OUT NUMBER,
                      X_POSITION_ID NUMBER,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_START_DATE DATE,
                      X_END_DATE DATE,
                      X_UNIT VARCHAR2) ;
/* PROCEDURE POPULATE_FIELDS: Calls all the other procedures within
                              the package allowing for only one
                              server side trip.
*/
--
--
-- Changed datatype from VARCHAR2 to DATE for X_START_DATE and X_END_DATE.
-- PASHUN.  31-10-1997. BUG : 572545.
--
--
PROCEDURE POPULATE_FIELDS(X_VARIANCE IN OUT NUMBER,
                          X_LEAVERS IN OUT NUMBER,
                          X_STARTERS IN OUT NUMBER,
                          X_PERIOD_END IN OUT NUMBER,
                          X_PERIOD_START IN OUT NUMBER,
                          X_BUDGET_VALUE IN OUT NUMBER,
                          X_BUDGET_VALUE_ID IN OUT NUMBER,
                          X_POSITION_ID NUMBER,
                          X_BUSINESS_GROUP_ID NUMBER,
                          X_START_DATE DATE,
                          X_END_DATE DATE,
                          X_UNIT VARCHAR2,
                          X_BUDGET_VERSION_ID NUMBER,
                          X_TIME_PERIOD_ID NUMBER) ;
END PER_POS_BGT_PKG;

 

/
