--------------------------------------------------------
--  DDL for Package IGS_PE_CITIZENSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_CITIZENSHIPS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI74S.pls 120.1 2005/09/21 01:11:52 appldev ship $ */

PROCEDURE Citizenship(
p_action 	  	IN 	VARCHAR2 ,
P_birth_or_selected  	IN 	VARCHAR2,
P_country_code 		IN	Varchar2,
p_date_disowned		IN	Date,
p_date_recognized	IN	DATE,
p_DOCUMENT_REFERENCE	IN	VARCHAR2,
p_DOCUMENT_TYPE		IN	VARCHAR2,
p_PARTY_ID		IN	NUMBER,
p_END_DATE		IN	DATE,
p_TERRITORY_SHORT_NAME	IN	VARCHAR2,
p_last_update_date	IN OUT NOCOPY	DATE,
p_citizenship_id	IN OUT NOCOPY	NUMBER,
p_return_status 	OUT NOCOPY 	VARCHAR2 ,
p_msg_count 		OUT NOCOPY 	VARCHAR2 ,
p_msg_data 		OUT NOCOPY 	VARCHAR2,
p_object_version_number IN OUT NOCOPY NUMBER ,
p_Calling_From		IN	VARCHAR2 DEFAULT NULL
) ;

END IGS_PE_CITIZENSHIPS_PKG;

 

/
