--------------------------------------------------------
--  DDL for Package GMF_ALLOC_PROCESS_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_ALLOC_PROCESS_PRIVATE" AUTHID CURRENT_USER AS
/* $Header: gmfalcps.pls 115.2 2002/11/11 00:28:51 rseshadr ship $ */

   /*********************************************************************************
   *  FUNCTION
   *    get_company_acct_masks
   *
   *  DESCRIPTION
   *     Retrieves the masks of accounting units and accounts.
   *  INPUT PARAMETERS
   *     v_co_code
   *
   *  OUTPUT PARAMETERS
   *     P_deli_acct_mask
   *     P_deli_au_mask :=
   *     P_deli_comp :=
   *     P_deli_au_len :
   *     P_deli_acct_len
   *     P_deli_key_mask
   *
   *  RETURNS
   *           0  =  Sucessful
   *          -1  =  No Segments found
   *          -2  =  No delimeter found
   *          -3  =  No  Account unit segments found.
   *  HISTORY
   *     sukarna Reddy                12/15/97       Converted from jpl to PLSQL
   *     R.Sharath Kumar              10/30/2002     Bug# 2641405  Added NOCOPY hint
   ************************************************************************************/

   P_deli_au_len 	      	NUMBER(10)    DEFAULT 0;	/* sotres AU length*/
   P_deli_acct_len         	NUMBER(10)    DEFAULT 0;	/* stores accts length*/
   P_deli_comp  	      	VARCHAR2(4)   DEFAULT NULL;	/* stores company delimeter*/
   P_deli_key_mask 	      	VARCHAR2(500) DEFAULT NULL;	/* stores complete mask for key*/
   P_deli_au_mask 	      	gl_accu_mst.acctg_unit_no%TYPE  DEFAULT NULL;  	/* stores mask for AU*/
   P_deli_acct_mask       	gl_acct_mst.acct_no%TYPE DEFAULT NULL;
   P_of_segment_delimeter   VARCHAR2(1);

   FUNCTION get_company_acct_masks(V_co_code IN VARCHAR2) RETURN NUMBER;

   FUNCTION format_string (v_string IN OUT NOCOPY VARCHAR2, v_mask IN VARCHAR2) RETURN VARCHAR2;

 END GMF_ALLOC_PROCESS_PRIVATE;

 

/
