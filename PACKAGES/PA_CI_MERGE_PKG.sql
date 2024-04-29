--------------------------------------------------------
--  DDL for Package PA_CI_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_MERGE_PKG" AUTHID CURRENT_USER AS
 /* $Header: PACIMRGS.pls 120.0 2005/05/30 01:28:25 appldev noship $ */



PROCEDURE control_items_owner_id(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2);

PROCEDURE control_items_last_mod_by_id(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2);

PROCEDURE control_items_closed_by_id(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2);

PROCEDURE ci_actions_assigned_to(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2);

PROCEDURE ci_impacts_implemented_by(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2);

PROCEDURE project_parties_res_src_id(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2);

PROCEDURE update_project_parties_res_id(
  p_from_resource_id IN NUMBER,
  p_to_resource_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2);

END;

 

/
