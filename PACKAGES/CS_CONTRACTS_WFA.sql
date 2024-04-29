--------------------------------------------------------
--  DDL for Package CS_CONTRACTS_WFA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONTRACTS_WFA" AUTHID CURRENT_USER as
/* $Header: csctwfas.pls 115.0 99/07/16 08:55:51 porting ship  $ */
	PROCEDURE Selector
	(
		itemtype     	IN VARCHAR2,
           	itemkey      	IN VARCHAR2,
           	actid        	IN NUMBER,
           	funmode      	IN VARCHAR2,
           	result		OUT VARCHAR2
	);

	PROCEDURE Initialize_Request
	(
		itemtype     	IN VARCHAR2,
           	itemkey      	IN VARCHAR2,
           	actid        	IN NUMBER,
           	funmode      	IN VARCHAR2,
           	result		OUT VARCHAR2
	);

	PROCEDURE Select_Approver
	(
		itemtype	IN VARCHAR2,
		itemkey  	IN VARCHAR2,
		actid		IN NUMBER,
		funcmode	IN VARCHAR2,
		result		OUT VARCHAR2
	);

  	PROCEDURE Approve_Contract
	(
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funmode	     	IN VARCHAR2,
		result    	OUT VARCHAR2
	);

  	PROCEDURE Reject_Contract
	(
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funmode	     	IN VARCHAR2,
		result    	OUT VARCHAR2
	);

  	PROCEDURE Initialize_Errors
	(
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funmode	     	IN VARCHAR2,
		result    	OUT VARCHAR2
	);
	l_pkg_name	VARCHAR2(80) := 'CS_CONTRACTS_WFA';

END CS_CONTRACTS_WFA;

 

/
