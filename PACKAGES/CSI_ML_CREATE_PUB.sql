--------------------------------------------------------
--  DDL for Package CSI_ML_CREATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ML_CREATE_PUB" AUTHID CURRENT_USER AS
-- $Header: csimcrps.pls 120.2 2006/02/03 15:34:51 sguthiva noship $

PROCEDURE create_instances
 (
    x_msg_data              OUT NOCOPY   VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    p_txn_from_date         IN           VARCHAR2,
    p_txn_to_date           IN           VARCHAR2,
    p_batch_name            IN           VARCHAR2,
    p_source_system_name    IN           VARCHAR2,
    p_resolve_ids           IN           VARCHAR2
 );

PROCEDURE create_parallel_instances
 (
    x_msg_data              OUT NOCOPY   VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    p_txn_from_date         IN           VARCHAR2,
    p_txn_to_date           IN           VARCHAR2,
    p_source_system_name    IN           VARCHAR2,
    p_worker_id             IN           NUMBER,
    p_resolve_ids           IN           VARCHAR2
 );

PROCEDURE create_relationships
 (
    x_msg_data              OUT NOCOPY   VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    p_txn_from_date         IN           VARCHAR2,
    p_txn_to_date           IN           VARCHAR2,
    p_source_system_name    IN           VARCHAR2
 );

END CSI_ML_CREATE_PUB;

 

/
