--------------------------------------------------------
--  DDL for Package HZ_BES_BO_TRACKING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BES_BO_TRACKING_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBOTVS.pls 120.0 2005/07/29 00:01:56 smattegu noship $ */

/*
 PROCEDURE create_bot
 Scope: This is the public procedure that is called by other teams to populate BOT

 DESCRIPTION
   This creates child, parent entries in BOT.
 Input Parameters
  p_init_msg_list       Initialize message stack
  p_CHILD_BO_CODE       Child entity BO code. validated by HZ_BUSINESS_OBJECTS lookup type
  P_CHILD_TBL_NAME      Child entity database table name
  p_CHILD_ID            Child identifier,
  p_child_opr_flag      Operation performed on child record - I for insert and U for update.
	P_CHILD_UPDATE_DT     Child entity record last update date,
  p_PARENT_BO_CODE      Parent entity BO code. validated by HZ_BUSINESS_OBJECTS lookup type
  P_PARENT_TBL_NAME     Parent entity database table name
  p_PARENT_ID           Parent identifier,
  p_parent_opr_flag     Operation performed on parent record - I for insert and U for update.
  p_GPARENT_BO_CODE     Grand Parent entity BO code. validated by HZ_BUSINESS_OBJECTS lookup type
  P_GPARENT_TBL_NAME    Grand Parent entity database table name
  p_GPARENT_ID          Grand Parent identifier

 Output Parameters
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2


 Validations:

1.	 Mandatory Input parameters are:
	  p_init_msg_list
	  P_CHILD_TBL_NAME
	  p_CHILD_ID
	  p_child_opr_flag
		P_CHILD_UPDATE_DT
	  P_PARENT_TBL_NAME
	  p_PARENT_ID

2. If the entity table name is in the following list, ensure that the
	   grand parent info is passed. Otherwise, error out.
	   a. RA_CUST_RECEIPT_METHODS
	   b. IBY_FNDCPT_PAYER_ASSGN_INSTR_V
	   c. HZ_PER_PROFILES_EXT_VL
	   d. HZ_PARTY_SITES_EXT_VL
	   e. HZ_ORG_PROFILES_EXT_VL
	   f. HZ_LOCATIONS_EXT_VL

 Called by:
	 1. This procedure is called by iPayment team to populate the BOT with
	    bank assignment (child), Customer Account (parent), party(grand parent).
	 2. This procedure is also called by TCA Extensibility EOs for
	    Org, Person, Localtion and PS.
	 In both cases, this procedure will write two records into BOT.
	 First record will have child, parent info.
	 Second record will have parent info as child info and grand parent record as parent info in BOT.

 Example:	iPayement APIs populating BOT by calling this procedure
 create_bot(
  p_CHILD_BO_CODE       => NULL,
  P_CHILD_TBL_NAME      => 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V',
  p_CHILD_ID            => <VALUE for instr_assignment_id >,
  p_child_opr_flag      => <'I' or 'U'>,
	P_CHILD_UPDATE_DT     => <last_update_date of instrument_assignment_rec>,
  p_PARENT_BO_CODE      => <'CUST_ACCT' or 'CUST_ACCT_SITE_USE'>,
	-- based on whether instrument is a child of cust_acct or acct_site_use
  P_PARENT_TBL_NAME     => <'HZ_CUST_SITE_USES_ALL' or 'HZ_CUST_ACCOUNTS'>,
  p_PARENT_ID           => <value of ACCT_SITE_USE_ID or CUST_ACCOUNT_ID  >,
  p_parent_opr_flag     => NULL,
  p_GPARENT_BO_CODE     => <'ORG_CUST' or 'PERSON_CUST'>,
  -- based on party type of the party for which the customer account is associated with.
  P_GPARENT_TBL_NAME     => 'HZ_PARTIES',
  p_GPARENT_ID           => <value of party_id for which the customer account is associated with>,
  x_return_status       => x_ret_status,
  x_msg_count           => xmsg_ct,
  x_msg_data            => xmsg_data
);

*/
PROCEDURE create_bot(
  p_init_msg_list       IN  VARCHAR2 := fnd_api.g_false,
  p_CHILD_BO_CODE       IN VARCHAR2,
  P_CHILD_TBL_NAME      IN VARCHAR2,
  p_CHILD_ID            IN NUMBER,
  p_child_opr_flag      IN VARCHAR2,
	P_CHILD_UPDATE_DT     IN DATE,
  p_PARENT_BO_CODE      IN VARCHAR2,
  P_PARENT_TBL_NAME     IN VARCHAR2,
  p_PARENT_ID            IN NUMBER,
  p_parent_opr_flag      IN VARCHAR2,
  p_GPARENT_BO_CODE      IN VARCHAR2,
  P_GPARENT_TBL_NAME     IN VARCHAR2,
  p_GPARENT_ID            IN NUMBER,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2
);
END HZ_BES_BO_TRACKING_PVT;

 

/
