--------------------------------------------------------
--  DDL for Package IGS_AS_SUARC_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SUARC_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPAS2S.pls 120.2 2006/01/17 03:52:49 ijeddy noship $ */
/*#
 * The Unit Attempt Reference Codes  Legacy import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_AS_LGCY_SUARC_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Legacy Student Unit Attempt Reference Codes
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_UNIT
 */

/***********************************************************************************************
 ||
 ||Created By:        Bhavani Radhakrishnan
 ||
 ||Date Created By:   20-11-2002
 ||
 ||Purpose:       This package is to import the Student Unit attempt reference          ||COdes
 ||
 ||Known limitations,enhancements,remarks:
 ||
 ||Change History
 ||
************************************************************************************************/
TYPE sua_refcd_rec_type IS RECORD
/*===========================================================================+
 | Object  Type                                                              |
 |              Record type of the table IGS_AS_LGCY_SUARC_INT                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               Record type of the table IGS_AS_LGCY_SUARC_INT              |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | CREATION     HISTORY :                                                    |
 |  bradhakr    02-Jul-2005                                                  |
 | MODIFICATION HISTORY                                                      |
 +===========================================================================*/
(
 person_number                  	IGS_AS_LGCY_SUARC_INT.person_number%TYPE ,
 program_cd                     	IGS_AS_LGCY_SUARC_INT.program_cd%TYPE ,
 unit_cd                        	IGS_AS_LGCY_SUARC_INT.unit_cd%TYPE ,
 version_number                 	IGS_AS_LGCY_SUARC_INT.version_number%TYPE ,
 teach_cal_alt_code             	IGS_AS_LGCY_SUARC_INT.teach_cal_alt_code%TYPE ,
 location_cd                    	IGS_AS_LGCY_SUARC_INT.location_cd%TYPE ,
 unit_class                     	IGS_AS_LGCY_SUARC_INT.unit_class%TYPE ,
 reference_cd_type               	IGS_AS_LGCY_SUARC_INT.reference_cd_type%TYPE ,
 reference_cd                   	IGS_AS_LGCY_SUARC_INT.reference_cd%TYPE ,
 applied_program_cd              	IGS_AS_LGCY_SUARC_INT.applied_program_cd%TYPE ,
 import_status                  	IGS_AS_LGCY_SUARC_INT.import_status%TYPE
);
PROCEDURE validate_parameters(p_suarc_dtls_rec   IN   sua_refcd_rec_type );
/*===========================================================================+
 | PROCEDURE                                                                 |
 |              validate_parameters                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is a public procedure and is responsible for the        |
 |              validation of the parameters of the igs_As_sua_ref_cds       |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
  |                   p_suarc_dtls_rec                                    |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | CREATION     HISTORY :                                                    |
 |  bradhakr   02-Jul-2005
 | MODIFICATION HISTORY                                                      |
 +===========================================================================*/
PROCEDURE validate_db_cons( p_person_id             IN   NUMBER,
                            p_unit_version_number   IN   NUMBER,
                            p_uoo_id                IN   NUMBER ,
                           p_suarc_dtls_rec          IN   sua_refcd_rec_type  ) ;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |              validate_db_cons                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is a public procedure and is responsible for the        |
 |              creation of a student Assessment unit  outcome record.       |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_person_id                                          |
 |                    p_unit_version_number                                        |
 |                    p_uoo_id                                               |
 |                    p_suarc_dtls_rec                                         |
 |              OUT:							     |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | CREATION     HISTORY :                                                    |
 |   bradhakr   02-Jul-2005                                                   |
 | MODIFICATION HISTORY                                                      |
 +===========================================================================*/
/*#
 * The Unit Attempt Reference Codes  Legacy import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_AS_LGCY_SUARC_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_suarc_dtls_rec Legacy Unit Attempt Reference Code record type. Refer to IGS_AS_LGCY_SUARC_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Unit Attempt Reference Codes
 */
PROCEDURE create_suarc (    p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2 ,
                            p_commit                IN   VARCHAR2 ,
                            p_validation_level      IN   NUMBER  ,
                            p_suarc_dtls_rec          IN   sua_refcd_rec_type  ,
                            x_return_status         OUT  NOCOPY VARCHAR2,
                            x_msg_count             OUT  NOCOPY NUMBER,
                            x_msg_data              OUT  NOCOPY VARCHAR2)   ;
    /*===========================================================================+
 | PROCEDURE                                                                 |
|                                 create_suarc |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is a public procedure and is responsible for the        |
 |              creation of a student Assessment unit  outcome record.       |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                          p_api_version
 |                           p_init_msg_list
 |                           p_commit
 |                           p_validation_level
 |                           p_suarc_dtls_rec
 |                 OUT:      x_return_status
 |                           x_msg_count
 |                           x_msg_data
 |                                                                 |
 |                                                                           |
 |                                                    |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | CREATION     HISTORY :                                                    |
 |   bradhakr   02-Jul-2005                                                   |
 | MODIFICATION HISTORY                                                      |
 +===========================================================================*/
END IGS_AS_SUARC_LGCY_PUB;

 

/
