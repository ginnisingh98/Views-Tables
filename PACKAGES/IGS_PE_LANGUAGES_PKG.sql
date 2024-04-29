--------------------------------------------------------
--  DDL for Package IGS_PE_LANGUAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_LANGUAGES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI75S.pls 120.1 2005/06/24 04:02:53 appldev ship $ */

PROCEDURE Languages(
p_action 			IN 	VARCHAR2 ,
P_LANGUAGE_NAME 		IN	Varchar2,
p_DESCRIPTION		        IN	VARCHAR2,
p_PARTY_ID			IN	NUMBER,
p_native_language		IN 	VARCHAR2,
p_primary_language_indicator    IN	VARCHAR2,
P_READS_LEVEL			IN	VARCHAR2,
P_SPEAKS_LEVEL			IN	VARCHAR2,
P_WRITES_LEVEL			IN	VARCHAR2,
p_END_DATE			IN	DATE,
p_status                        IN      VARCHAR2 DEFAULT 'A',
p_understand_level              IN      VARCHAR2 DEFAULT NULL,
p_last_update_date		IN OUT NOCOPY  DATE,
p_return_status 		OUT NOCOPY 	VARCHAR2 ,
p_msg_count 			OUT NOCOPY 	VARCHAR2 ,
p_msg_data 			OUT NOCOPY 	VARCHAR2,
P_language_use_reference_id 	IN OUT NOCOPY 	NUMBER,
p_language_ovn                  IN OUT NOCOPY   NUMBER,
p_source            IN  VARCHAR2 DEFAULT NULL
);

End Igs_Pe_languages_Pkg;

 

/
