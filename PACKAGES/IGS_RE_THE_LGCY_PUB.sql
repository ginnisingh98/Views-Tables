--------------------------------------------------------
--  DDL for Package IGS_RE_THE_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_THE_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSRE20S.pls 120.1 2006/01/17 03:39:21 rnirwani noship $ */
/*#
 * The Research Thesis Import process is a public API designed for use in populating rows with data
 * during a system conversion.  This API is also used by the Legacy Import Process for Enrollment and
 * Records when importing rows from the IGS_RE_LGCY_THE_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Research Thesis
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */
 -- irep annotations above.

--Start of comments
--      API name        : Thesis Details
--      Type            : Public.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version           IN NUMBER       Required
--                        p_init_msg_list         IN VARCHAR2     Optional Default = FND_API.G_FALSE
--                        p_commit                IN VARCHAR2     Optional Default = FND_API.G_FALSE
--                        p_validation_level      IN NUMBER       Optional Default = FND_API.G_VALID_LEVEL_FULL
--                        p_the_dtls_rec          IN the_dtls_rec_type (this is a record type declared in the spec
--                                                                      contains the below mentioned fields)
--          {
--           person_number               :Person Number which will be resolved to get PERSON_ID.
--           program_cd                  :The program code in which the thesis applies.
--           title                       :Describes the title of the research student's thesis.
--           final_title_ind             :Indicates and specifies if the nominated title is the final title for
--                                        the thesis, or a working title. Selecting the check box indicates the
--                                        thesis title is final.
--           short_title                 :The short title of the thesis.
--           abbreviated_title           :The abbreviated title of the thesis.
--           final_thesis_result_cd      :Describes the final result that has been allocated to the thesis.
--                                        This result must be mapped to a system result of type final.
--           expected_submission_dt      :The date that the thesis is expected to be submitted. This field would be
--                                        entered once the student had given notification of intention to submit.
--           library_lodgement_dt        :Contains the date the research students thesis was lodged in the library.
--           library_catalogue_number    :Contains the library catalogue number of the thesis.
--           embargo_expiry_dt           :The expiry date of any embargo placed on the release of the thesis.
--           thesis_format               :Describes the format of the thesis.
--           embargo_details             :Records the details of any embargo placed on the release of the thesis.
--           thesis_topic                :Describes the topic of the thesis.
--           citation                    :Contains citation information to be read during a graduation ceremony.
--           comments                    :General comments.
--           submission_dt               :The date that the thesis was submitted for examination.
--           thesis_exam_type            :The type of examination that is being undertaken. For example, written,
--                                        performance, oral.Must be an uppercase value.
--           thesis_panel_type           :The type of panel used for the thesis examination.Must be an uppercase value.
--           thesis_result_cd            :The thesis result that is an outcome of the panel members having provided
--                                        their recommended results.Must be an uppercase value.
--          }
--      OUT             : x_return_status         OUT     VARCHAR2(1)
--                        x_msg_count             OUT     NUMBER
--                        x_msg_data              OUT     VARCHAR2(2000)
--
--      Version : Current version       1.0
-- End of comments
--
-- Change History :
-- Who             When            What
-- (reverse chronological order - newest change first)

TYPE the_dtls_rec_type IS RECORD (
person_number              igs_re_lgcy_the_int.person_number%TYPE,
program_cd                 igs_re_lgcy_the_int.program_cd%TYPE,
title                      igs_re_lgcy_the_int.title%TYPE,
final_title_ind            igs_re_lgcy_the_int.final_title_ind%TYPE,
short_title                igs_re_lgcy_the_int.short_title%TYPE,
abbreviated_title          igs_re_lgcy_the_int.abbreviated_title%TYPE,
final_thesis_result_cd     igs_re_lgcy_the_int.final_thesis_result_cd%TYPE,
expected_submission_dt     igs_re_lgcy_the_int.expected_submission_dt%TYPE,
library_lodgement_dt       igs_re_lgcy_the_int.library_lodgement_dt%TYPE,
library_catalogue_number   igs_re_lgcy_the_int.library_catalogue_number%TYPE,
embargo_expiry_dt          igs_re_lgcy_the_int.embargo_expiry_dt%TYPE,
thesis_format              igs_re_lgcy_the_int.thesis_format%TYPE,
embargo_details            igs_re_lgcy_the_int.embargo_details%TYPE,
thesis_topic               igs_re_lgcy_the_int.thesis_topic%TYPE,
citation                   igs_re_lgcy_the_int.citation%TYPE,
comments                   igs_re_lgcy_the_int.comments%TYPE,
submission_dt              igs_re_lgcy_the_int.submission_dt%TYPE,
thesis_exam_type           igs_re_lgcy_the_int.thesis_exam_TYPE%TYPE,
thesis_panel_type          igs_re_lgcy_the_int.thesis_panel_TYPE%TYPE,
thesis_result_cd           igs_re_lgcy_the_int.thesis_result_cd%TYPE
);

-- irep annotations below.
/*#
 * The Research Thesis Import process is a public API designed for use in populating rows with data
 * during a system conversion.  This API is also used by the Legacy Import Process for Enrollment and
 * Records when importing rows from the IGS_RE_LGCY_THE_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param P_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_the_dtls_rec Legacy Research Thesis record type. Refer to IGS_EN_LGCY_THE_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Research Thesis
 */
PROCEDURE create_the
(       p_api_version           IN   NUMBER,
        p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE ,
        p_commit                IN   VARCHAR2 DEFAULT FND_API.G_FALSE ,
        p_validation_level      IN   NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL   ,
        p_the_dtls_rec          IN   the_dtls_rec_type ,
        x_return_status         OUT  NOCOPY  VARCHAR2,
        x_msg_count             OUT  NOCOPY  NUMBER,
        x_msg_data              OUT  NOCOPY  VARCHAR2);

END igs_re_the_lgcy_pub;

 

/
