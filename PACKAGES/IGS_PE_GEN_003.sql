--------------------------------------------------------
--  DDL for Package IGS_PE_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSPE18S.pls 120.3 2006/01/23 06:33:09 gmaheswa noship $ */
/*
  ||  Created By : gmaheswa
  ||  Created On : 2-NOV-2004
  ||  Purpose : Created to process FA todo items in case of insert/update of housing status/residency status
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gmaheswa        17-Jan-06       4938278: Added a procedure TURNOFF_TCA_BE to disable and enable business events in bulk import process.
  ||  skpandey        18-AUG-2005     Bug#: 4378028
  ||                                  Added procedure raise_person_type_event and resp_assignment to handle person type responsibility enhancements
  ||  (reverse chronological order - newest change first)
*/
PROCEDURE PROCESS_RES_DTLS(
        P_ACTION        IN      VARCHAR2 , -- I/U I-INSERT U-UPDATE,
        P_OLD_RECORD    IN      IGS_PE_RES_DTLS_ALL%ROWTYPE,
        P_NEW_RECORD    IN      IGS_PE_RES_DTLS_ALL%ROWTYPE);

PROCEDURE PROCESS_HOUSING_DTLS(
        P_ACTION        IN      VARCHAR2 , -- I/U I-INSERT U-UPDATE,
        P_OLD_RECORD    IN      IGS_PE_TEACH_PERIODS_ALL%ROWTYPE,
        P_NEW_RECORD    IN      IGS_PE_TEACH_PERIODS_ALL%ROWTYPE);

FUNCTION RESP_ASSIGNMENT(
        P_SUBSCRIPTION_GUID IN RAW,
        P_EVENT             IN OUT NOCOPY WF_EVENT_T)
	RETURN VARCHAR2;

PROCEDURE RAISE_PERSON_TYPE_EVENT(
        p_person_id          IN      NUMBER,
        p_person_type_code   IN      VARCHAR2,
        p_action             IN      VARCHAR2,
	p_end_date           IN      DATE DEFAULT NULL);

PROCEDURE TURNOFF_TCA_BE(
	p_turnoff VARCHAR2
);
g_hz_api_callouts_profl VARCHAR2(30);

END IGS_PE_GEN_003;

 

/
