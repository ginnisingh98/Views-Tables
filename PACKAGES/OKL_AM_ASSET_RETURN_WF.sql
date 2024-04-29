--------------------------------------------------------
--  DDL for Package OKL_AM_ASSET_RETURN_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_ASSET_RETURN_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRRWFS.pls 115.9 2003/03/04 18:19:56 msdokal noship $ */

  PROCEDURE CHECK_REPO_REQUEST (itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE CHECK_RETURN_TYPE  (itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE CHECK_ASSET_RETURN (itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE CHECK_REMK_ASSIGN  (itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE CHECK_ROLE_EXISTS  (itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE POP_REPO_NOTIFY_ATT(itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE POP_REMK_NOTIFY_ATT(itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE NOTIFY_REMK_USER   (itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE VALIDATE_TITLE_RET(  itemtype	IN VARCHAR2,
				                 itemkey  	IN VARCHAR2,
			                 	 actid		IN NUMBER,
			                     funcmode	IN VARCHAR2,
				                 resultout OUT NOCOPY VARCHAR2 );

  PROCEDURE VALIDATE_SHIPPING_INSTR(    itemtype	IN VARCHAR2,
				                        itemkey  	IN VARCHAR2,
			                 	        actid		IN NUMBER,
			                  	        funcmode	IN VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE VALIDATE_ASSET_REPAIR(    itemtype	IN VARCHAR2,
				                        itemkey  	IN VARCHAR2,
			                 	        actid		IN NUMBER,
			                  	        funcmode	IN VARCHAR2,
				                        resultout OUT NOCOPY VARCHAR2);

  PROCEDURE SET_APPROVED_YN(    itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2);

  PROCEDURE POP_ASSET_REPAIR_ATT(    itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2);

  PROCEDURE POPULATE_ITD_ATTS(    itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2);

  PROCEDURE VALIDATE_CONT_PORT (itemtype	IN  VARCHAR2,
				              itemkey  	IN  VARCHAR2,
			                  actid     IN  NUMBER,
			                  funcmode	IN  VARCHAR2,
				              resultout OUT NOCOPY VARCHAR2);

  PROCEDURE POP_CONT_PORT_ATT( itemtype	IN  VARCHAR2,
				              itemkey  	IN  VARCHAR2,
			                  actid     IN  NUMBER,
			                  funcmode	IN  VARCHAR2,
				              resultout OUT NOCOPY VARCHAR2);

  PROCEDURE SET_CP_APPROVED_YN( itemtype	IN  VARCHAR2,
				              itemkey  	IN  VARCHAR2,
			                  actid     IN  NUMBER,
			                  funcmode	IN  VARCHAR2,
				              resultout OUT NOCOPY VARCHAR2);

  PROCEDURE POP_CPE_NOTIFY_ATT( itemtype	IN  VARCHAR2,
				              itemkey  	IN  VARCHAR2,
			                  actid     IN  NUMBER,
			                  funcmode	IN  VARCHAR2,
				              resultout OUT NOCOPY VARCHAR2);

  PROCEDURE NOTIFY_ASS_GRP_USER( itemtype	IN  VARCHAR2,
				              itemkey  	IN  VARCHAR2,
			                  actid     IN  NUMBER,
			                  funcmode	IN  VARCHAR2,
				              resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CHECK_ITD_REQUEST( itemtype	IN  VARCHAR2,
				              itemkey  	IN  VARCHAR2,
			                  actid     IN  NUMBER,
			                  funcmode	IN  VARCHAR2,
				              resultout OUT NOCOPY VARCHAR2);

  PROCEDURE CHECK_PROFILE_RECIPIENT( itemtype	IN  VARCHAR2,
				              itemkey  	IN  VARCHAR2,
			                  actid     IN  NUMBER,
			                  funcmode	IN  VARCHAR2,
				              resultout OUT NOCOPY VARCHAR2);

END OKL_AM_ASSET_RETURN_WF;

 

/
