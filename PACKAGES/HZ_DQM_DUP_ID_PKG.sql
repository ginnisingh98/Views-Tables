--------------------------------------------------------
--  DDL for Package HZ_DQM_DUP_ID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DQM_DUP_ID_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHDUPIS.pls 120.8 2005/06/16 21:11:37 jhuang noship $ */

/*=======================================================================+
 |  Copyright (c) 1999 Oracle Corporation Redwood Shores, California, USA|
 |                          All rights reserved.                         |
 +=======================================================================+
 | NAME
 |      HZ_DQM_DUP_ID_PKG
 |
 | DESCRIPTION
 |      VJN created code, for dup identification, using B-tree indices
 |      for all the three flows:
 |      1. Existing System Duplicate Identification
 |      2. Interface vs TCA Duplicate Identification
 |      3. Interface Duplicate Identification
 | PUBLIC PROCEDURES
 |
 | HISTORY
 |      13-MAY-2003 : VJN Created
 |
 *=======================================================================*/

TYPE EntityCur IS REF CURSOR;
TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE CharList IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

-- this needs to be revisited to make sure, value is populated from a profile
l_like_comparison_min_length number := 3;

---------------------------------
-- TCA DUPLICATE IDENTIFICATION
---------------------------------
-- will be called by find_dup_parties_worker ( which is one of the n concurrent workers
-- spawned off by find_dup_parties), as part of system duplicate identification
PROCEDURE tca_dup_id_worker(
                 p_dup_batch_id            IN NUMBER,
                 p_match_rule_id           IN NUMBER,
                 p_worker_number           IN NUMBER,
                 p_number_of_workers       IN NUMBER,
                 p_subset_sql              IN VARCHAR2
                 );

-- will be called when all the tca dup id workers are done
PROCEDURE tca_sanitize_report(
                 p_dup_batch_id            IN NUMBER,
                 p_match_rule_id           IN NUMBER,
                 p_subset_sql              IN VARCHAR2,
                 p_within_subset           IN VARCHAR2
                 );

PROCEDURE update_hz_dup_results (
    p_cur    IN EntityCur );

--------------------------------------------
-- INTERFACE vs TCA DUPLICATE IDENTIFICATION
--------------------------------------------

PROCEDURE interface_tca_dup_id(
                  p_batch_id                   IN number,
                  p_match_rule_id              IN number,
                  p_from_osr                   IN VARCHAR2,
                  p_to_osr                     IN VARCHAR2,
                  p_batch_mode_flag            IN VARCHAR2,
                  x_return_status              OUT     NOCOPY VARCHAR2,
                  x_msg_count                  OUT     NOCOPY NUMBER,
                  x_msg_data                   OUT     NOCOPY VARCHAR2
                 );

PROCEDURE interface_tca_sanitize_report(
                 p_batch_id                   IN      NUMBER,
                 p_match_rule_id              IN      NUMBER,
                 p_request_id                 IN      NUMBER,
                 x_dup_batch_id               OUT     NOCOPY NUMBER,
                 x_return_status              OUT     NOCOPY VARCHAR2,
                 x_msg_count                  OUT     NOCOPY NUMBER,
                 x_msg_data                   OUT     NOCOPY VARCHAR2
                 );

PROCEDURE update_hz_imp_dup_parties (
    p_batch_id IN number,
    p_cur    IN EntityCur );

PROCEDURE update_party_dqm_action_flag (
    p_batch_id IN number,
    p_cur    IN EntityCur );

PROCEDURE update_detail_dqm_action_flag (
    p_entity IN VARCHAR2,
    p_batch_id IN number,
    p_cur    IN EntityCur );

--------------------------------------------
-- INTERFACE DUPLICATE IDENTIFICATION
--------------------------------------------

PROCEDURE interface_dup_id_worker(
                  p_batch_id         IN number,
                  p_match_rule_id              IN number,
                  p_from_osr                   IN VARCHAR2,
                  p_to_osr                     IN VARCHAR2,
                  x_return_status              OUT     NOCOPY VARCHAR2,
                  x_msg_count                  OUT     NOCOPY NUMBER,
                  x_msg_data                   OUT     NOCOPY VARCHAR2
                 );

PROCEDURE interface_sanitize_report(
                 p_batch_id                   IN NUMBER,
                 p_match_rule_id              IN NUMBER,
                 x_return_status              OUT     NOCOPY VARCHAR2,
                 x_msg_count                  OUT     NOCOPY NUMBER,
                 x_msg_data                   OUT     NOCOPY VARCHAR2
                 );

PROCEDURE update_hz_int_dup_results (
    p_batch_id IN number,
    p_cur    IN EntityCur );


--------------------------------------------
-- THIS WILL BE USED FOR ALL FLOWS
--------------------------------------------

PROCEDURE compile_match_rule (
	    p_match_rule_id         IN NUMBER,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2
);

PROCEDURE  final_process_int_tca_dup_id(p_batch_id IN number);
END ;  -- HZ_DQM_DUP_ID_PKG


 

/
