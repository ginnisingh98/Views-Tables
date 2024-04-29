--------------------------------------------------------
--  DDL for Package IGC_CC_APPROVAL_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_APPROVAL_PROCESS" AUTHID CURRENT_USER AS
/* $Header: IGCCAPPS.pls 120.6.12010000.2 2008/08/04 14:49:09 sasukuma ship $ */

global_budgetary_control_on BOOLEAN := FALSE;
global_po_entries_created  BOOLEAN := TRUE;

PROCEDURE Preparer_Can_Approve
( p_api_version         IN      NUMBER	,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER	 := FND_API.G_VALID_LEVEL_FULL	,
  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER  ,
  x_msg_data            OUT NOCOPY     VARCHAR2,
  p_org_id	        IN	NUMBER  ,
  p_cc_state	        IN	VARCHAR2,
  p_cc_type             IN	VARCHAR2,
  x_result              OUT NOCOPY     VARCHAR2
);

PROCEDURE Approved_By_Preparer
 ( p_api_version	IN	NUMBER
 , p_init_msg_list	IN	VARCHAR2
 , p_commit		IN  	VARCHAR2
 , p_validation_level	IN	NUMBER
 , p_return_status	OUT NOCOPY	VARCHAR2
 , p_msg_count		OUT NOCOPY	NUMBER
 , p_msg_data		OUT NOCOPY	VARCHAR2
 , p_cc_header_id	IN	NUMBER
 , p_org_id		IN	NUMBER
 , p_sob_id		IN	NUMBER
 , p_cc_state		IN	VARCHAR2
 , p_cc_type		IN	VARCHAR2
 , p_cc_preparer_id	IN	NUMBER
 , p_cc_owner_id	IN	NUMBER
 , p_cc_current_owner	IN	NUMBER
 , p_cc_apprvl_status	IN	VARCHAR2
 , p_cc_encumb_status	IN	VARCHAR2
 , p_cc_ctrl_status	IN	VARCHAR2
 , p_cc_version_number	IN	NUMBER
 , p_cc_notes		IN	VARCHAR2
 , p_acct_date          IN      DATE
 ) ;


END IGC_CC_APPROVAL_PROCESS;

/
