--------------------------------------------------------
--  DDL for Package IGW_PROP_PERSONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PERSONS_PUB" AUTHID CURRENT_USER AS
--$Header: igwppers.pls 120.1 2005/10/30 05:54:40 appldev ship $
/*#
 * This is the public interface for Grants Proposal Personnel creation.  It allows
 * users to upload personnel for a given proposal into Grants Proposal.
 * @rep:scope public
 * @rep:product IGW
 * @rep:displayname Create Proposal Personnel
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGW_PROPOSAL
 */

   ---------------------------------------------------------------------------
/*#
 * Create Proposal Personnel Interface
 * @param p_commit Variable to control implicit commit
 * @param p_validate_only Variable to control plain validation or creation of data
 * @param p_proposal_number Proposal number
 * @param p_full_name Person full name
 * @param p_proposal_role_desc  Person role
 * @param p_key_person_flag Flag to indicate if the person is a key person
 * @param p_person_unit_name Name of the organization the person belongs to
 * @param x_return_status Error status
 * @param x_msg_count Number of error messages
 * @param x_msg_data Error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Proposal Personnel
 */
   PROCEDURE Create_Prop_Person
   (
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      p_proposal_number        IN VARCHAR2,
      p_full_name              IN VARCHAR2,
      p_proposal_role_desc     IN VARCHAR2,
      p_key_person_flag        IN VARCHAR2,
      p_person_unit_name       IN VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Persons_Pub;

 

/
