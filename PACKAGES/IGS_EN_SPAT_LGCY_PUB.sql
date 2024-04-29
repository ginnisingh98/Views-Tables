--------------------------------------------------------
--  DDL for Package IGS_EN_SPAT_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPAT_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSENA9S.pls 120.1 2006/01/17 03:32:10 rnirwani noship $ */
/*#
 * The Student Program Attempt Term Record Import process is a public API designed for use in populating
 * rows with data during a system conversion.  This API is also used by the Legacy Import Process for
 * Enrollment and Records when importing rows from the IGS_EN_LGY_SPAT_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Term Record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */
 -- irep annotations above.

TYPE spat_rec_type IS RECORD (
	person_number		igs_en_lgy_spat_int.person_number%TYPE,
	program_cd		igs_en_lgy_spat_int.program_cd%TYPE,
	program_version		igs_en_lgy_spat_int.program_version%TYPE,
	key_program_flag	igs_en_lgy_spat_int.key_program_flag%TYPE,
	acad_cal_type		igs_en_lgy_spat_int.acad_cal_type%TYPE,
	location_cd		igs_en_lgy_spat_int.location_cd%TYPE,
	attendance_mode		igs_en_lgy_spat_int.attendance_mode%TYPE,
	attendance_type		igs_en_lgy_spat_int.attendance_type%TYPE,
	class_standing		igs_en_lgy_spat_int.class_standing%TYPE,
	fee_cat			igs_en_lgy_spat_int.fee_cat%TYPE,
	term_cal_alternate_cd	igs_en_lgy_spat_int.term_cal_alternate_cd%TYPE,
	attribute_category	igs_en_lgy_spat_int.attribute_category%TYPE,
	attribute1		igs_en_lgy_spat_int.attribute1%TYPE,
	attribute2		igs_en_lgy_spat_int.attribute2%TYPE,
	attribute3		igs_en_lgy_spat_int.attribute3%TYPE,
	attribute4		igs_en_lgy_spat_int.attribute4%TYPE,
	attribute5		igs_en_lgy_spat_int.attribute5%TYPE,
	attribute6		igs_en_lgy_spat_int.attribute6%TYPE,
	attribute7		igs_en_lgy_spat_int.attribute7%TYPE,
	attribute8		igs_en_lgy_spat_int.attribute8%TYPE,
	attribute9		igs_en_lgy_spat_int.attribute9%TYPE,
	attribute10		igs_en_lgy_spat_int.attribute10%TYPE,
	attribute11		igs_en_lgy_spat_int.attribute11%TYPE,
	attribute12		igs_en_lgy_spat_int.attribute12%TYPE,
	attribute13		igs_en_lgy_spat_int.attribute13%TYPE,
	attribute14		igs_en_lgy_spat_int.attribute14%TYPE,
	attribute15		igs_en_lgy_spat_int.attribute15%TYPE,
	attribute16		igs_en_lgy_spat_int.attribute16%TYPE,
	attribute17		igs_en_lgy_spat_int.attribute17%TYPE,
	attribute18		igs_en_lgy_spat_int.attribute18%TYPE,
	attribute19		igs_en_lgy_spat_int.attribute19%TYPE,
	attribute20		igs_en_lgy_spat_int.attribute20%TYPE );

-- irep annotations below
/*#
 * The Student Program Attempt Term Record Import process is a public API designed for use in populating
 * rows with data during a system conversion.  This API is also used by the Legacy Import Process for
 * Enrollment and Records when importing rows from the IGS_EN_LGY_SPAT_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param P_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_spat_rec Legacy Student Program Attempt Term record type. Refer to IGS_EN_LGY_SPAT_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Term Record
 */
PROCEDURE create_spa_t (
	p_api_version		IN		NUMBER,
	p_init_msg_list		IN		VARCHAR2        DEFAULT FND_API.G_FALSE,
	p_commit		IN		VARCHAR2        DEFAULT FND_API.G_FALSE,
	p_validation_level	IN		NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL,
	p_spat_rec		IN		spat_rec_type,
	x_return_status		OUT	NOCOPY	VARCHAR2,
	x_msg_count		OUT	NOCOPY	NUMBER,
	x_msg_data		OUT	NOCOPY	VARCHAR2 );

END igs_en_spat_lgcy_pub;

 

/
