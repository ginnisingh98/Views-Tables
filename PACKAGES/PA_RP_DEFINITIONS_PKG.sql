--------------------------------------------------------
--  DDL for Package PA_RP_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RP_DEFINITIONS_PKG" AUTHID CURRENT_USER AS
/*$Header: PARPDFKS.pls 120.0.12010000.1 2010/03/25 06:57:28 vgovvala noship $*/

Procedure Insert_Row(
			P_RP_ID                 IN NUMBER,
			P_RP_NAME               IN VARCHAR2,
			P_EMAIL_TITLE           IN VARCHAR2,
			P_EMAIL_BODY            IN VARCHAR2,
			P_DESCRIPTIONS          IN VARCHAR2,
			P_RP_TYPE_ID            IN NUMBER,
			P_DT_PROCESS_DATE       IN DATE,
			P_RP_FILE_ID            IN NUMBER,
			P_TEMPLATE_START_DATE   IN DATE,
			P_TEMPLATE_END_DATE     IN DATE,
			P_OBSOLETE_FLAG         IN VARCHAR2 );

Procedure Update_Row(
			P_RP_ID                 IN NUMBER,
			P_RP_NAME               IN VARCHAR2,
			P_EMAIL_TITLE           IN VARCHAR2,
			P_EMAIL_BODY            IN VARCHAR2,
			P_DESCRIPTIONS          IN VARCHAR2,
			P_RP_TYPE_ID            IN NUMBER,
			P_DT_PROCESS_DATE       IN DATE,
			P_RP_FILE_ID            IN NUMBER,
			P_TEMPLATE_START_DATE   IN DATE,
			P_TEMPLATE_END_DATE     IN DATE,
			P_OBSOLETE_FLAG         IN VARCHAR2);

Procedure Add_language;

End PA_RP_DEFINITIONS_PKG;

/
