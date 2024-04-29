--------------------------------------------------------
--  DDL for Package EGO_PUB_HIST_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_PUB_HIST_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOPPHPS.pls 120.0.12010000.2 2009/08/31 10:55:31 cmath noship $ */

--  ============================================================================
--  Name        : Purge_Publish_History
--
--
--  Description : This procedure will be used to delete publish history based on
--                input parameter passed.
--
--        IN    :
--                p_batch_id                IN      NUMBER
--                A unique batch identifier.
--
--                p_target_system_code      IN      VARCHAR2
--                Sytem identification code into which entities are published.
--
--                p_from_date            IN      DATE
--                From date for a date Range.
--
--                p_to_date            IN      DATE
--                To date for a date Range.
--
--                p_status_code             IN      VARCHAR2
--                Status of the entity i.e. Successful,In-Progress etc.
--
--                p_published_by            IN      NUMBER
--                Publisher of Entity/Batch.
--
--                p_entity_type             IN      VARCHAR2
--                Type of the Entity, which you want to delete
--
--        OUT   :
--                err_buff                  OUT   VARCHAR2
--                standard out parameter to handle error message
--
--                ret_code                  OUT   NUMBER
--                standard out parameter to return API execution status
--  ============================================================================

PROCEDURE Purge_Publish_History (  err_buff             OUT   NOCOPY  VARCHAR2,
                                   ret_code             OUT   NOCOPY  NUMBER,
                                   p_batch_id           IN            NUMBER ,
				   p_target_system_code IN            VARCHAR2 ,
                                   p_from_date          IN            VARCHAR2 ,
                                   p_to_date            IN            VARCHAR2 ,
                                   p_status_code        IN            VARCHAR2 ,
                                   p_published_by       IN            NUMBER ,
                                   p_entity_type        IN            VARCHAR2);


END ego_pub_hist_purge_pkg;

/
