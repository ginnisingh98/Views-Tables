--------------------------------------------------------
--  DDL for Package IGS_AS_SUAO_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SUAO_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPAS1S.pls 120.1 2006/01/17 03:52:30 ijeddy noship $ */
/*#
 * The Unit Outcome Legacy import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_AS_LGCY_SUO_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Legacy Unit Outcome
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_UNIT
 */
/***********************************************************************************************
 ||
 ||Created By:        Arun Iyer
 ||
 ||Date Created By:   20-11-2002
 ||
 ||Purpose:       This package creates a student Assessment unit outcome record.
 ||
 ||
 ||Known limitations,enhancements,remarks:
 ||
 ||Change History
 ||
 ||Who        When         What
 ||knaraset   14-May-2003  Modified the record type lgcy_suo_rec_type to add location_cd and Unit_class,
                           as part of MUS build bug 2829262
************************************************************************************************/



TYPE lgcy_suo_rec_type IS RECORD
/*===========================================================================+
 | Object  Type                                                              |
 |              Record type of the table igs_as_lgcy_suo_int                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               Record type of the table igs_as_lgcy_suo_int                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | CREATION     HISTORY :                                                    |
 |  Aiyer       20-Nov-2002                                                  |
 | MODIFICATION HISTORY                                                      |
 +===========================================================================*/
    (
      PERSON_NUMBER                      IGS_AS_LGCY_SUO_INT.PERSON_NUMBER%TYPE                     ,
      PROGRAM_CD                         IGS_AS_LGCY_SUO_INT.PROGRAM_CD%TYPE			    ,
      UNIT_CD                            IGS_AS_LGCY_SUO_INT.UNIT_CD%TYPE			    ,
      TEACH_CAL_ALT_CODE                 IGS_AS_LGCY_SUO_INT.TEACH_CAL_ALT_CODE%TYPE		    ,
      OUTCOME_DT                         IGS_AS_LGCY_SUO_INT.OUTCOME_DT%TYPE			    ,
      GRADING_SCHEMA_CD                  IGS_AS_LGCY_SUO_INT.GRADING_SCHEMA_CD%TYPE		    ,
      VERSION_NUMBER                     IGS_AS_LGCY_SUO_INT.VERSION_NUMBER%TYPE		    ,
      GRADE                              IGS_AS_LGCY_SUO_INT.GRADE%TYPE	    ,
      S_GRADE_CREATION_METHOD_TYPE       IGS_AS_LGCY_SUO_INT.S_GRADE_CREATION_METHOD_TYPE%TYPE	    ,
      FINALISED_OUTCOME_IND              IGS_AS_LGCY_SUO_INT.FINALISED_OUTCOME_IND%TYPE             ,
      MARK                               IGS_AS_LGCY_SUO_INT.MARK%TYPE				    ,
      INCOMP_DEADLINE_DATE               IGS_AS_LGCY_SUO_INT.INCOMP_DEADLINE_DATE%TYPE		    ,
      INCOMP_GRADING_SCHEMA_CD           IGS_AS_LGCY_SUO_INT.INCOMP_GRADING_SCHEMA_CD%TYPE	    ,
      INCOMP_VERSION_NUMBER              IGS_AS_LGCY_SUO_INT.INCOMP_VERSION_NUMBER%TYPE	            ,
      INCOMP_DEFAULT_GRADE               IGS_AS_LGCY_SUO_INT.INCOMP_DEFAULT_GRADE%TYPE		    ,
      INCOMP_DEFAULT_MARK                IGS_AS_LGCY_SUO_INT.INCOMP_DEFAULT_MARK%TYPE		    ,
      COMMENTS                           IGS_AS_LGCY_SUO_INT.COMMENTS%TYPE			    ,
      GRADING_PERIOD_CD                  IGS_AS_LGCY_SUO_INT.GRADING_PERIOD_CD%TYPE		    ,
      ATTRIBUTE_CATEGORY                 IGS_AS_LGCY_SUO_INT.ATTRIBUTE_CATEGORY%TYPE		    ,
      ATTRIBUTE1                         IGS_AS_LGCY_SUO_INT.ATTRIBUTE1%TYPE			    ,
      ATTRIBUTE2                         IGS_AS_LGCY_SUO_INT.ATTRIBUTE2%TYPE			    ,
      ATTRIBUTE3                         IGS_AS_LGCY_SUO_INT.ATTRIBUTE3%TYPE			    ,
      ATTRIBUTE4                         IGS_AS_LGCY_SUO_INT.ATTRIBUTE4%TYPE			    ,
      ATTRIBUTE5                         IGS_AS_LGCY_SUO_INT.ATTRIBUTE5%TYPE			    ,
      ATTRIBUTE6                         IGS_AS_LGCY_SUO_INT.ATTRIBUTE6%TYPE			    ,
      ATTRIBUTE7                         IGS_AS_LGCY_SUO_INT.ATTRIBUTE7%TYPE			    ,
      ATTRIBUTE8                         IGS_AS_LGCY_SUO_INT.ATTRIBUTE8%TYPE			    ,
      ATTRIBUTE9                         IGS_AS_LGCY_SUO_INT.ATTRIBUTE9%TYPE			    ,
      ATTRIBUTE10                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE10%TYPE			    ,
      ATTRIBUTE11                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE11%TYPE			    ,
      ATTRIBUTE12                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE12%TYPE			    ,
      ATTRIBUTE13                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE13%TYPE			    ,
      ATTRIBUTE14                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE14%TYPE			    ,
      ATTRIBUTE15                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE15%TYPE			    ,
      ATTRIBUTE16                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE16%TYPE			    ,
      ATTRIBUTE17                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE17%TYPE			    ,
      ATTRIBUTE18                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE18%TYPE			    ,
      ATTRIBUTE19                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE19%TYPE                      ,
      ATTRIBUTE20                        IGS_AS_LGCY_SUO_INT.ATTRIBUTE20%TYPE,
      LOCATION_CD                        IGS_AS_LGCY_SUO_INT.LOCATION_CD%TYPE,
      UNIT_CLASS                         IGS_AS_LGCY_SUO_INT.UNIT_CLASS%TYPE
     );

/*#
 * The Unit Outcome Legacy import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_AS_LGCY_SUO_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_lgcy_suo_rec Legacy Unit Outcome record type. Refer to IGS_AS_LGCY_SUO_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Unit Outcome
 */
  PROCEDURE create_unit_outcome

 /*===========================================================================+
 | PROCEDURE                                                                 |
 |              create_unit_outcome                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is a public procedure and is responsible for the        |
 |              creation of a student Assessment unit  outcome record.       |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |                    p_commit                                               |
 |                    p_lgcy_suo_rec                                         |
 |              OUT:							     |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | CREATION     HISTORY :                                                    |
 |  Aiyer   20-Nov-2002                                                      |
 | MODIFICATION HISTORY                                                      |
 +===========================================================================*/
            (
	       p_api_version                 IN  NUMBER                                             ,
	       p_init_msg_list               IN  VARCHAR2 DEFAULT FND_API.G_FALSE                   ,
	       p_commit                      IN  VARCHAR2 DEFAULT FND_API.G_FALSE		    ,
	       p_validation_level            IN  VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL	    ,
	       p_lgcy_suo_rec                IN  LGCY_SUO_REC_TYPE				    ,
	       x_return_status               OUT NOCOPY VARCHAR2				    ,
	       x_msg_count                   OUT NOCOPY NUMBER					    ,
	       x_msg_data                    OUT NOCOPY VARCHAR2
	    );

  PROCEDURE initialise ( p_lgcy_suo_rec IN OUT NOCOPY LGCY_SUO_REC_TYPE );
/*============================================================================+
 | PROCEDURE                                                                 |
 |              initialise                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This procedure initialises the record type variable          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN/ OUT:                                                     |
 |                    p_lgcy_suo_rec                                         |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | CREATION     HISTORY :                                                    |
 |  Aiyer   20-Nov-2002                                                      |
 | MODIFICATION HISTORY                                                      |
 +===========================================================================*/

END igs_as_suao_lgcy_pub;

 

/
