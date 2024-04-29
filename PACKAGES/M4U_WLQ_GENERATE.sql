--------------------------------------------------------
--  DDL for Package M4U_WLQ_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_WLQ_GENERATE" AUTHID CURRENT_USER AS
/* $Header: m4uwlqgs.pls 120.0 2005/05/24 16:21:08 appldev noship $ */
/*#
 * This package contains the private APIs invoked for outbound XML generation
 * for the Worklist-query collaboration.
 * @rep:scope private
 * @rep:product CLN
 * @rep:displayname M4U private APIs invoked during the outbound XML generation for the
 * UCCnet worklist-query collaboration
 * @rep:category BUSINESS_ENTITY EGO_ITEM
 */

        -- Name
        --      raise_wlq_event
        -- Purpose
        --      This procedure is called from a concurrent program.
        --      The the event 'oracle.apps.m4u.createworklistquery' is raised with the supplied event parameters
        --      The sequence m4u_wlqid_sequence is used to obtain unique event key.
        -- Arguments
        --      x_err_buf                       => API param for concurrent program calls
        --      x_retcode                       => API param for concurrent program calls
        --      p_wlq_type                      => The type of notifications from Worklist to be queried
        --      p_wlq_status                    => The status of notifications to be queried
        -- Notes
        --      Status is expected to be UnREAD to avoid duplicate processing of notifications.
        /*#
         * Raises business event to generate UCCnet Worklist-query collaboration.
         * The event parameters include status, type filters for the Worklist-query.
         * @param x_errbuf Error buffer.
         * @param x_retcode Return code.
         * @param p_wlq_type Notification-type filter for worklist query.
         * @param p_wlq_status Notification-status filter for worklist query.
         * @rep:scope private
         * @rep:displayname Raise worklist-query business event.
         * @rep:businessevent oracle.apps.m4u.worklistquery.generate
        */
        PROCEDURE raise_wlq_event(
                                x_errbuf        OUT NOCOPY VARCHAR2,
                                x_retcode       OUT NOCOPY NUMBER,
                                p_wlq_type      IN VARCHAR2,
                                p_wlq_status    IN VARCHAR2
                                );

END m4u_wlq_generate;

 

/
