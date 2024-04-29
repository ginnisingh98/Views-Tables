--------------------------------------------------------
--  DDL for Package CS_SR_WF_DUP_CHK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_WF_DUP_CHK_PVT" AUTHID CURRENT_USER AS
/* $Header: cswfdpcs.pls 115.0 2003/09/19 00:37:01 aneemuch noship $ */

    PROCEDURE Check_SR_Channel(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE Check_SR_Updated(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE Check_Duplicate_Profile(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE Check_And_Perf_Dup_Check(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE Auto_Task_Create(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE Setup_Notify_Name(
                itemtype	VARCHAR2,
                itemkey		VARCHAR2,
                actid		NUMBER,
                funmode		VARCHAR2,
                result		OUT NOCOPY VARCHAR2 );

    PROCEDURE Check_SR_Owner_To_Notify(
                itemtype	VARCHAR2,
                itemkey		VARCHAR2,
                actid		NUMBER,
                funmode		VARCHAR2,
                result		OUT NOCOPY VARCHAR2 );
END;

 

/
