--------------------------------------------------------
--  DDL for Package IGF_SP_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SP_ASSIGN_PUB" AUTHID CURRENT_USER AS
/* $Header: IGFSP05S.pls 120.1 2006/01/17 02:49:12 svuppala noship $ */
/*#
 * The Sponsorship Assignment API is a public API that is used to assign a number of students to a sponsor automatically.
 * Oracle Student System allows you to  create student-sponsor assignment records though the interface. This API is a means to automatically create multiple student-sponsor assignment records.
 * @rep:scope public
 * @rep:product IGF
 * @rep:displayname Import Sponsorship Relationships
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_SPONSORSHIP
 */

  /****************************************************************************
  Created By:         Vinay Chappidi
  Date Created By:    19-Feb-2003
  Purpose:            This procedure is the main api call.
  Known limitations,enhancements,remarks:

  Change History
  Who         When           What
  svuppala   9-Jan-2006    R12 iRep Annotation - added annotation
  ******************************************************************************/

-- Start of comments
--      API name        : CREATE_STDNT_SPNSR_REL
--      Type            : Public
--      Pre-reqs        : Complete Setup has to be done before invoking this API
--      Function        : Creates a Student Sponsor Relationship
--      Parameters      :
--      IN              :       p_api_version             IN NUMBER       Required
--                                                        Current Version number of the Public API
--
--      IN              :       p_init_msg_list           IN VARCHAR2     Optional, Default:fnd_api.g_false
--                                                        Message stack initialization parameter
--
--      IN              :       p_commit                  IN VARCHAR2     Optional, Default:fnd_api.g_false
--                                                        Parameter to check if the current transactions have
--                                                        to be committed explicitly.
--
--
--      IN              :       p_person_id               IN NUMBER       Conditionally Required
--                                                        Person ID of the person for creating a Student-Sponsor
--                                                        relationship.
--
--      IN              :       p_alt_person_id_type      IN VARCHAR2     Conditionally Required
--                                                        User defined Person Id Type.
--
--      IN              :       p_api_person_id           IN VARCHAR2     Conditionally Required
--                                                        Alternate ID parameter in combination with derived
--                                                        System defined Person ID type will be used to identify
--                                                        a unique person.
--
--      IN              :       p_sponsor_code            IN VARCHAR2     Required
--                                                        Active Sponsor code pre-defined in the system for
--                                                        an Award Year Calendar Instance
--
--      IN              :       p_awd_ci_cal_type         IN VARCHAR2     Required
--                                                        Award Calendar Type parameter for which the sponsor is
--                                                        offering sponsorships to students.
--
--      IN              :       p_awd_ci_sequence_number  IN NUMBER       Required
--                                                        Award Calendar Instance Sequence Number parameter for
--                                                        which the sponsor is offering sponsorships to students.
--
--      IN              :       p_ld_cal_type             IN VARCHAR2     Required
--                                                        Load/Term Calendar Type parameter under Award Calendar
--                                                        Instance for which the sponsor is offering
--                                                        sponsorships to students.
--
--      IN              :       p_ld_ci_sequence_number   IN NUMBER       Required
--                                                        Load/Term Calendar Instance Sequence Number parameter
--                                                        for which the sponsor is offering sponsorships to students.
--
--      IN              :       p_amount                  IN NUMBER       Required
--                                                        Amount parameter that the sponsor is willing to sponsor
--                                                        a student for a Term/Load Calendar Instance with in
--                                                        an Award Calendar Instance.
--      OUT             :       x_return_status           OUT VARCHAR2
--                                                        Parameter to convey public API's return status.
--
--      OUT             :       x_msg_count               OUT NUMBER
--                                                        Parameter contains message count returned
--                                                        by the Public API.
--
--      OUT             :       x_msg_data                OUT VARCHAR2
--                                                        Parameter contains the messages in the encoded format.
--
--      Version : Current version       1.0
--                Initial version       1.0
-- End of comments

/*#
 * The Sponsorship Assignment API is a public API that is used to assign a number of students to a sponsor automatically.
 * Oracle Student System allows you to  create student-sponsor assignment records though the interface. This API is a means to automatically create multiple student-sponsor assignment records.
 * @param p_api_version The version number will be used to compare with the public api's current version number. Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXp_ERROR
 * @param x_msg_count The message count.
 * @param x_msg_data The message data.
 * @param p_person_id Person Identifier of the person for creating a Student-Sponsor relationship.
 * @param p_alt_person_id_type User defined Person ID Type.
 * @param p_api_person_id Alternate ID parameter in combination with derived System defined Person ID type will be used to identify a unique person.
 * @param p_sponsor_code Active Sponsor code pre-defined in the system for an Award Year Calendar Instance
 * @param p_awd_ci_cal_type Award Calendar Type parameter for which the sponsor is offering sponsorships to students.
 * @param p_awd_ci_sequence_number Award Calendar Instance Sequence Number parameter for which the sponsor is offering sponsorships to students.
 * @param p_ld_cal_type Load/Term Calendar Type parameter under Award Calendar Instance for which the sponsor is offering sponsorships to students.
 * @param p_ld_ci_sequence_number Load/Term Calendar Instance Sequence Number parameter for which the sponsor is offering sponsorships to students.
 * @param p_amount Amount parameter that the sponsor is willing to sponsor a student for a Term/Load Calendar Instance within an Award Calendar Instance.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Sponsorship Relationships
 */
  PROCEDURE create_stdnt_spnsr_rel(p_api_version   IN NUMBER,
                                   p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                   p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_person_id     IN NUMBER,
                                   p_alt_person_id_type IN VARCHAR2,
                                   p_api_person_id IN VARCHAR2,
                                   p_sponsor_code IN VARCHAR2,
                                   p_awd_ci_cal_type IN VARCHAR2,
                                   p_awd_ci_sequence_number IN NUMBER,
                                   p_ld_cal_type IN VARCHAR2,
                                   p_ld_ci_sequence_number IN NUMBER,
                                   p_amount IN NUMBER);
END igf_sp_assign_pub;

 

/
