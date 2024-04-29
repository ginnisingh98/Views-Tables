--------------------------------------------------------
--  DDL for Package AR_POSTBATCH_PARALLEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_POSTBATCH_PARALLEL" AUTHID CURRENT_USER AS
/* $Header: ARPBMPS.pls 120.0.12010000.2 2008/11/12 14:33:56 mgaleti noship $ */
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   submit_postbatch_parallel() - Submit child requests for the processing  |
 |                    of postbatch through submit_subrequest(). It makes a   |
 |                    call to update_batch_after_process() to update the     |
 |                    batch status after all the child requests are completed|
 | DESCRIPTION                                                               |
 |      Submits child requests.                                              |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |      arp_standard.debug() - debug procedure                               |
 |      FND_REQUEST.wait_for_request                                         |
 | ARGUMENTS  : IN:                     				     |
 |                 p_org_id - Org ID                                         |
 |                 p_batch_id - Batch Id                                     |
 |                 p_transmission_id - Lockbox transmission ID               |
 |                 p_total_workers - Number of workers                       |
 |                                                                           |
 |              OUT:  P_ERRBUF                                               |
 |                    P_RETCODE                                              |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by AGHORAKA	     	    - 09/01/2008     |
 |                        Modified Parameter List           - 01/02/2008     |
 +===========================================================================*/
PROCEDURE submit_postbatch_parallel(
                          P_ERRBUF                          OUT NOCOPY VARCHAR2,
			  P_RETCODE                         OUT NOCOPY NUMBER,
			  p_org_id                          IN NUMBER,
			  p_batch_id                        IN NUMBER,
			  p_transmission_id                 IN NUMBER,
                          p_total_workers                   IN NUMBER default 1 );
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   update_batch_for_rerun() - If any error occurs during the postbatch     |
 |   process, the batch_applied_status is put back to 'POSTBATCH_WAITING'    |
 |   for rerun at later time.                                                |
 | DESCRIPTION                                                               |
 |     Updates batch_applied_Status to 'POSTBATCH_WAITING'                   |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 | ARGUMENTS  : IN:                     				     |
 |                 p_status - Batch Status                                   |
 |                 p_batch_id - Batch Id                                     |
 |                                                                           |
 |              OUT:     None                                                |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  09/01/2008 - Created by AGHORAKA	     	     |
 +===========================================================================*/
PROCEDURE update_batch_for_rerun( p_status    IN ar_batches.status%TYPE,
				  p_batch_id  IN NUMBER);

END AR_POSTBATCH_PARALLEL;

/
