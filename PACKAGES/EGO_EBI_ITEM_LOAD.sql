--------------------------------------------------------
--  DDL for Package EGO_EBI_ITEM_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_EBI_ITEM_LOAD" AUTHID CURRENT_USER AS
/* $Header: EGOVEILS.pls 120.1.12010000.1 2009/05/19 12:08:36 aashah noship $ */

G_ITEM_LOAD_EVENT    CONSTANT  VARCHAR2(240)   :=  'oracle.apps.ego.ebi.itemLoad';

--Generate Events. This can be run multiple times to generate the events incrementally.
--When run for the first time, qualifying item id records will be inserted into the event log table
-- and the procedure will stamp the records with the event id and raise the event.
-- if the records left in the the event log table without stamped event id, the output message
-- will state so. On the subsequent run, it will start stamping the events after the last run left.

PROCEDURE GENERATE_EVENTS( p_organization_id   IN         NUMBER
                          ,p_batch_size        IN            NUMBER      DEFAULT 20
                          ,p_max_events        IN            NUMBER      DEFAULT NULL
                          ,x_err_msg           OUT NOCOPY VARCHAR2
                           );

-- Purge load events from Event log
PROCEDURE PURGE_EVENTLOG;


--To regenrate failed event provide the event id
PROCEDURE REGENERATE_FAILED_EVENT( p_organization_id   IN         NUMBER
                                   ,p_event_id         IN         NUMBER
                                   ,x_err_msg           OUT NOCOPY VARCHAR2
                           );

END EGO_EBI_ITEM_LOAD;

/
