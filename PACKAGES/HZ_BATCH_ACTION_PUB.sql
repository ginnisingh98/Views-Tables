--------------------------------------------------------
--  DDL for Package HZ_BATCH_ACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BATCH_ACTION_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBATAS.pls 120.4 2003/10/14 20:24:02 rpalanis noship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------
/**
 * PROCEDURE clear_status
 *
 * DESCRIPTION
 *     Clear the interface_status and dqm_action_flag of the interface
 *     tables.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   p_batch_id           Interface Batch ID.
 *
 *   OUT:
 *   x_return_status      Return status after the call. The status can
 *                        be FND_API.G_RET_STS_SUCCESS (success),
 *                        FND_API.G_RET_STS_ERROR (error).
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-17-2003    Rajeshwari P      o Created.
 *
 */

  PROCEDURE clear_status (
      p_batch_id        IN            NUMBER,
      x_return_status   OUT NOCOPY    VARCHAR2
                         );

/**
 *PROCEDURE batch_dedup_action
 *
 * DESCRIPTION
 *     Mark the interface_status in the interface tables
 *     with 'R' to indicate which records should be removed from
 *     processing by Data Load program.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   p_batch_id                 Batch ID from batch summary table.
 *   p_action_on_parties        Action to be taken on duplicate party records
 *                              in the interface tables.
 *   p_action_on_addresses      Action to be taken on duplicate site records
 *                              in the interface tables.
 *   p_action_on_contacts       Action to be taken on duplicate contact records
 *                              in the interface tables.
 *   p_action_on_contact_points Action to be taken on duplicate contact point
 *                              records in the interface tables.
 *
 *   OUT:
 *   x_return_status      Return status after the call. The status can
 *                        be FND_API.G_RET_STS_SUCCESS (success),
 *                        FND_API.G_RET_STS_ERROR (error),
 *                        FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   x_msg_count          Number of messages in message stack.
 *   x_msg_data           Message text if x_msg_count is 1..
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-17-2003    Rajeshwari P      o Created.
 *
 */

PROCEDURE batch_dedup_action (
    p_batch_id                  IN         NUMBER,
    p_action_on_parties         IN         VARCHAR2,
    p_action_on_addresses       IN         VARCHAR2,
    p_action_on_contacts        IN         VARCHAR2,
    p_action_on_contact_points  IN         VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
      );

/**
 *PROCEDURE registry_dedup_action
 *
 * DESCRIPTION
 *     This API will be called to reflect the user defined
 *     options into the interface tables after DQM has performed
 *     registry de-duplication.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *    p_batch_id                  Interface Batch ID
 *    p_action_new_parties        New Parties,
 *    p_action_existing_parties   Existing parties,
 *    p_action_dup_parties        Dup parties,
 *    p_action_pot_dup_parties    Potential duplicate parties,
 *    p_action_new_addrs          New Address,
 *    p_action_existing_addrs     Existing Address,
 *    p_action_pot_dup_addrs      Potential Duplicate address,
 *    p_action_new_contacts       New Contacts,
 *    p_action_existing_contacts  Existing Contacts,
 *    p_action_pot_dup_contacts   Potential duplicate Contacts,
 *    p_action_new_cpts           New Contact Points,
 *    p_action_existing_cpts      Existing Contact Points,
 *    p_action_pot_dup_cpts       Potential Duplicate Contact Points,
 *    p_action_new_supents        New Supents,
 *    p_action_existing_supents   Existing Supents,
 *    p_action_new_finents        New Finents,
 *    p_action_existing_finents   Existing Finents,
 *
 *   OUT:
 *    x_return_status      Return status after the call. The status can
 *                        be FND_API.G_RET_STS_SUCCESS (success),
 *                        FND_API.G_RET_STS_ERROR (error),
 *                        FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   x_msg_count          Number of messages in message stack.
 *   x_msg_data           Message text if x_msg_count is 1..
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-17-2003    Rajeshwari P      o Created.
 *
 */

PROCEDURE registry_dedup_action (
     p_batch_id                  IN         NUMBER,
     p_action_new_parties        IN         VARCHAR2,
     p_action_existing_parties   IN         VARCHAR2,
     p_action_dup_parties        IN         VARCHAR2,
     p_action_pot_dup_parties    IN         VARCHAR2,
     p_action_new_addrs          IN         VARCHAR2,
     p_action_existing_addrs     IN         VARCHAR2,
     p_action_pot_dup_addrs      IN         VARCHAR2,
     p_action_new_contacts       IN         VARCHAR2,
     p_action_existing_contacts  IN         VARCHAR2,
     p_action_pot_dup_contacts   IN         VARCHAR2,
     p_action_new_cpts           IN         VARCHAR2,
     p_action_existing_cpts      IN         VARCHAR2,
     p_action_pot_dup_cpts       IN         VARCHAR2,
     p_action_new_supents        IN         VARCHAR2,
     p_action_existing_supents   IN         VARCHAR2,
     p_action_new_finents        IN         VARCHAR2,
     p_action_existing_finents   IN         VARCHAR2,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
  );

/**
 *FUNCTION GET_DEDUP_BATCH_STATUS
 *
 * DESCRIPTION
 *     This API will be called to get the
 *     status (Import/Remove) of records in
 *     dedup results based on the action
 *     in batch summary.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *    p_batch_id              Interface Batch ID
 *    p_entity                Entity Name in Dedup Results,
 *    p_action_on_entity      Action on entity in Batch Summary,
 *    p_winner_record_os      Winner record Orig System in Dedup Results
 *    p_winner_record_osr     Winner record Orig System Reference in Dedup Results
 *    p_dup_record_os         Dup record Orig System in Dedup Results
 *    p_dup_record_osr        Dup record Orig System Reference in Dedup Results
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-30-2003    Ramesh Ch      o Created.
 *
 */

FUNCTION GET_DEDUP_BATCH_STATUS(p_batch_id                  IN         NUMBER,
		                p_entity                    IN         VARCHAR2,
				p_action_on_entity          IN         VARCHAR2,
				p_winner_record_os          IN         VARCHAR2,
        			p_winner_record_osr         IN         VARCHAR2,
   				p_dup_record_os             IN         VARCHAR2,
				p_dup_record_osr            IN         VARCHAR2
			      ) RETURN VARCHAR2;


END HZ_BATCH_ACTION_PUB;

 

/
