--------------------------------------------------------
--  DDL for Package WSH_WF_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_WF_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: WSHWINTS.pls 120.1 2005/10/26 02:02:32 rahujain noship $ */


PROCEDURE SCPOD_SHIPPING_STATUS(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2);

PROCEDURE SCPOD_C_MARK_INTRANSIT(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2 );
PROCEDURE SCPOD_C_CLOSE_TRIP(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2 );
PROCEDURE SCPOD_C_RUN_INTERFACE(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2 );
PROCEDURE SCPOD_C_PRINT_DOCSET(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2 );
PROCEDURE SCPOD_C_INTRANSIT_CK(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2 );
PROCEDURE SCPOD_C_INTERFACE_CK(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2 );
PROCEDURE SCPOD_C_CLOSE_TRIP_CK(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2 );
PROCEDURE ITM_AT_SHIP_CONFIRM(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2 );
PROCEDURE ITM_AT_DEL_CR(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2 );
PROCEDURE SCPOD_C_SUBMIT_ITM(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2 );



PROCEDURE SCPOD_SCWF_STATUS(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2);
/* CURRENTLY NOT IN USE
PROCEDURE MANIFESTING_STATUS(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2);
*/

PROCEDURE SELECTOR(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2);

END WSH_WF_INTERFACE;

 

/
