--------------------------------------------------------
--  DDL for Package OKS_CT_EVENTS_WFA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CT_EVENTS_WFA" AUTHID CURRENT_USER AS
/* $Header: OKSCTEVS.pls 120.0 2005/05/25 17:55:35 appldev noship $ */

PROCEDURE SELECTOR
	(
		itemtype     	IN VARCHAR2,
           	itemkey      	IN VARCHAR2,
           	actid        	IN NUMBER,
           	funcmode      	IN VARCHAR2,
           	result		OUT NOCOPY VARCHAR2
	);

	PROCEDURE GET_VALUES
	(
		itemtype     	IN VARCHAR2,
           	itemkey      	IN VARCHAR2,
           	actid        	IN NUMBER,
           	funcmode      	IN VARCHAR2,
           	result		OUT NOCOPY VARCHAR2
	);

	PROCEDURE CREATE_SR
	(
		itemtype	IN VARCHAR2,
		itemkey  	IN VARCHAR2,
		actid		IN NUMBER,
		funcmode	IN VARCHAR2,
		result		OUT NOCOPY VARCHAR2
	);

  	PROCEDURE VALIDATE_RECEIVER
	(
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funcmode	IN VARCHAR2,
		result    	OUT NOCOPY VARCHAR2
	);

  	PROCEDURE UPDATE_EVENT
	(
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funcmode		IN VARCHAR2,
		result    	OUT NOCOPY VARCHAR2
	);

	l_pkg_name	VARCHAR2(80) := 'OKS_CT_EVENTS_WFA';

END OKS_CT_EVENTS_WFA;

 

/
