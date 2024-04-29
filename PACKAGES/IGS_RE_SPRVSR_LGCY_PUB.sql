--------------------------------------------------------
--  DDL for Package IGS_RE_SPRVSR_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_SPRVSR_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSRE19S.pls 120.1 2006/01/17 03:36:09 rnirwani noship $ */
/*#
 * The Research Supervisor Import process is a public API designed for use in populating rows with
 * data during a system conversion.  This API is also used by the Legacy Import Process for Enrollment
 * and Records when importing rows from the IGS_RE_LGCY_SPR_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Research Supervisor
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */
 -- irep annotations above.
/*------------------------------------------------------------------------------+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA       |
 |                            All rights reserved.                              |
 +==============================================================================+
 |                                                                              |
 | DESCRIPTION                                                                  |
 |      PL/SQL package: igs_re_sprvsr_lgcy_pub                                  |
 |                                                                              |
 | NOTES : Research Supervisor Legacy API. This API imports supervisor          |
 |         information against the specified program attempt / candidature.     |
 |         Created as part of Enrollment Legacy build. Bug# 2661533             |
 |                                                                              |
 | HISTORY                                                                      |
 | Who        When           What                                               |
 | pradhakr   03-Dec-2002    Changed the reference to the table                 |
 |                           igs_re_lgcy_sprvsr_int to igs_re_lgcy_spr_int.     |
 *==============================================================================*/

 TYPE sprvsr_dtls_rec_type IS RECORD
 (
    ca_person_number            igs_re_lgcy_spr_int.ca_person_number%TYPE,
    program_cd                  igs_re_lgcy_spr_int.program_cd%TYPE,
    person_number		igs_re_lgcy_spr_int.person_number%TYPE,
    start_dt			igs_re_lgcy_spr_int.start_dt%TYPE,
    end_dt			igs_re_lgcy_spr_int.end_dt%TYPE,
    research_supervisor_type	igs_re_lgcy_spr_int.research_supervisor_type%TYPE,
    supervisor_profession	igs_re_lgcy_spr_int.supervisor_profession%TYPE,
    supervision_percentage	igs_re_lgcy_spr_int.supervision_percentage%TYPE,
    funding_percentage		igs_re_lgcy_spr_int.funding_percentage%TYPE,
    org_unit_cd			igs_re_lgcy_spr_int.org_unit_cd%TYPE,
    replaced_person_number	igs_re_lgcy_spr_int.replaced_person_number%TYPE,
    comments			igs_re_lgcy_spr_int.comments%TYPE
);

-- irep annotations below
/*#
 * The Research Supervisor Import process is a public API designed for use in populating rows with
 * data during a system conversion.  This API is also used by the Legacy Import Process for Enrollment
 * and Records when importing rows from the IGS_RE_LGCY_SPR_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param P_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_sprvsr_dtls_rec Legacy Research Supervisor record type. Refer to IGS_EN_LGCY_SPR_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Research Supervisor
 */
 PROCEDURE create_sprvsr
 (
    p_api_version             IN           NUMBER,
    p_init_msg_list           IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                  IN           VARCHAR2 DEFAULT FND_API.G_FALSE ,
    p_validation_level        IN           NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL ,
    p_sprvsr_dtls_rec         IN           sprvsr_dtls_rec_type,
    x_return_status           OUT  NOCOPY  VARCHAR2,
    x_msg_count               OUT  NOCOPY  NUMBER,
    x_msg_data                OUT  NOCOPY  VARCHAR2
 );


END igs_re_sprvsr_lgcy_pub;

 

/
