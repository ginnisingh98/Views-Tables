--------------------------------------------------------
--  DDL for Package AR_FLEXBUILDER_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_FLEXBUILDER_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: ARFLBUPS.pls 120.3 2006/09/09 05:53:12 rkader ship $ */


PROCEDURE CALL_UPGRADED_FLEX ( ITEMTYPE		IN VARCHAR2
                            , ITEMKEY 		IN VARCHAR2
			    , ACTID   		IN NUMBER
			    , FUNCMODE  	IN VARCHAR2
                            , RESULT OUT NOCOPY VARCHAR2 );

END;



 

/
