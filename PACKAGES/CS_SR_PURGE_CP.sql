--------------------------------------------------------
--  DDL for Package CS_SR_PURGE_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_PURGE_CP" AUTHID CURRENT_USER AS
/* $Header: csvsrpgs.pls 120.3 2005/08/23 02:32:58 varnaray noship $ */
/*#
 * This package contains procedures that are run as concurrent
 * requests for purging service requests. The main procedure here
 * is purge_servicerequests which in turn invokes several child
 * concurrent requests using the procedure purge_sr_worker. The
 * parent concurrent request divides the load among the worker
 * concurrent requests by striping the data using a number matching
 * the worker_id of the worker concurrent request. The worker
 * concurrent requests identify the data that needs to processed
 * by it using a combination of the parent concurrent request id
 * and the worker id.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Service Request Purge Concurrent Program
 */

PROCEDURE purge_servicerequests
(
  errbuf                          IN OUT NOCOPY   VARCHAR2
, errcode                         IN OUT NOCOPY   INTEGER
, p_api_version_number            IN              NUMBER
, p_init_msg_list                 IN              VARCHAR2
, p_commit                        IN              VARCHAR2
, p_validation_level              IN              NUMBER
, p_incident_id                   IN              NUMBER
, p_incident_status_id            IN              NUMBER
, p_incident_type_id              IN              NUMBER
, p_creation_from_date            IN              VARCHAR2
, p_creation_to_date              IN              VARCHAR2
, p_last_update_from_date         IN              VARCHAR2
, p_last_update_to_date           IN              VARCHAR2
, p_not_updated_since             IN              VARCHAR2
, p_customer_id                   IN              NUMBER
, p_customer_acc_id               IN              NUMBER
, p_item_category_id              IN              NUMBER
, p_inventory_item_id             IN              NUMBER
, p_history_size                  IN              NUMBER
, p_number_of_workers             IN              NUMBER
, p_purge_batch_size              IN              NUMBER
, p_purge_source_with_open_task   IN              VARCHAR2
, p_audit_required                IN              VARCHAR2
);

PROCEDURE purge_sr_worker
(
  errbuf                          IN OUT NOCOPY   VARCHAR2
, errcode                         IN OUT NOCOPY   INTEGER
, p_api_version_number            IN              NUMBER
, p_init_msg_list                 IN              VARCHAR2
, p_commit                        IN              VARCHAR2
, p_validation_level              IN              NUMBER
, p_worker_id                     IN              NUMBER
, p_purge_batch_size              IN              NUMBER
, p_purge_set_id                  IN              NUMBER
, p_purge_source_with_open_task   IN              VARCHAR2
, p_audit_required                IN              VARCHAR2
);

PROCEDURE activity_summarizer;

END cs_sr_purge_cp;

 

/
