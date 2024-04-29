--------------------------------------------------------
--  DDL for Package CST_PARAMETER_CSTMRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PARAMETER_CSTMRG" AUTHID CURRENT_USER AS
/* $Header: CSTGMRGS.pls 115.4 2003/02/19 21:30:24 weizhou ship $ */



/*
 * Parameter_FormView_CSTMRG
 *
 *   This function is invoked via a form function
 *   and is the entry point into this package.
 *   It creates the HTML parameter page used by
 *   the BIS Gross Margin report.
 */
PROCEDURE Parameter_FormView_CSTMRG( force_display in varchar2 default 'YES');



/*
 * Parameter_ActionView_CSTMRG
 *
 *   This function is invoked when the user clicks
 *   the OK button in the HTML page generated by
 *   Parameter_FormView_CSTMRG.  It will validate
 *   the input parameters and launch the Gross Margin
 *   report.
 */
PROCEDURE Parameter_ActionView_CSTMRG
(
  P_ORG_LEVEL                             NUMBER,
  P_ORGANIZATION_ID                       VARCHAR2 default null,
  P_ORGANIZATION_NAME                     VARCHAR2 default null,
  P_BUSINESS_PLAN                         NUMBER,
  P_GEOGRAPHY_CODE                        VARCHAR2 default null,
  P_GEOGRAPHY_NAME                        VARCHAR2 default null,
  P_SALES_CHANNEL_CODE                    VARCHAR2 default null,
  P_SALES_CHANNEL_NAME                    VARCHAR2 default null,
  P_ITEM_CODE                             VARCHAR2 default null,
  P_ITEM                                  VARCHAR2 default null,
  P_VIEW_BY                               varchar2,
  P_FROM_DATE                             VARCHAR2 default null,
  P_TO_DATE                               VARCHAR2 default null
);



/*
 * Before_Parameter_CSTMRG
 *
 *   This function is called by Parameter_FormView_CSTMRG
 *   to perform initial setups.  It should not be invoked
 *   directly.
 */
PROCEDURE Before_Parameter_CSTMRG;



/*
 * After_Parameter_CSTMRG
 *
 *   This function is called by Parameter_ActionView_CSTMRG
 *   to perform validations.  It should not be invoked
 *   directly.
 */
PROCEDURE After_Parameter_CSTMRG;



END CST_PARAMETER_CSTMRG;

 

/