--------------------------------------------------------
--  DDL for Package Body PER_MAINTAIN_TASKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MAINTAIN_TASKFLOW" AS
/* $Header: petkflow.pkb 115.2 2004/06/25 02:27:09 adudekul noship $ */

--
-- Procedure to delete a taskflow and related data.
--
PROCEDURE delete_taskflow (
  p_taskflow_name IN VARCHAR2
) IS
l_workflow_id NUMBER;
l_nav_node_usage_id NUMBER;
--
-- Cursor to bring back all of the node usages for a node in a tasfklow.
--
CURSOR csr_node_usages IS
  SELECT nav_node_usage_id
  FROM   hr_navigation_node_usages
  WHERE  workflow_id = l_workflow_id;
BEGIN
   --
   -- Find the workflow_id that corresponds to p_taskflow_name (workflow name).
   --
   SELECT workflow_id
   INTO   l_workflow_id
   FROM   hr_workflows
   WHERE  workflow_name = p_taskflow_name;
   --
   -- For each node usage attached to a taskflow delete the navigation paths
   -- then delete the node usage record.
   --
   FOR node_usage_record IN csr_node_usages LOOP
      l_nav_node_usage_id := node_usage_record.nav_node_usage_id;
      DELETE FROM hr_navigation_paths
      WHERE       from_nav_node_usage_id = l_nav_node_usage_id
      OR          to_nav_node_usage_id = l_nav_node_usage_id;
      DELETE FROM hr_navigation_node_usages
      WHERE       nav_node_usage_id = l_nav_node_usage_id;
   END LOOP;
   --
   -- Delete the taskflow.
   --
   DELETE FROM hr_workflows
   WHERE       workflow_id = l_workflow_id;
END delete_taskflow;

--
-- Procedure to delete a navigation unit and related data.
--
PROCEDURE delete_navigation_unit (
  p_form_name IN VARCHAR2,
  p_block_name IN VARCHAR2
) IS
l_nav_unit_id NUMBER;
l_node_name VARCHAR2(80);
l_global_usage_id NUMBER;
--
-- Cursor to bring back all of the navigation nodes for a unit.
--
CURSOR csr_nav_nodes IS
  SELECT nav_node_id, name
  FROM   hr_navigation_nodes
  WHERE  nav_unit_id = l_nav_unit_id;
--
-- Cursor to bring back all of the global usages for a unit.
--
CURSOR csr_global_usages IS
  SELECT global_usage_id
  FROM   hr_nav_unit_global_usages
  WHERE  nav_unit_id = l_nav_unit_id;
BEGIN
   --
   -- Find the nav_unit_id for the form name/block name combination.
   --
   SELECT nav_unit_id
   INTO   l_nav_unit_id
   FROM   hr_navigation_units
   WHERE  form_name = p_form_name
   AND    nvl(block_name,hr_api.g_varchar2) = nvl(p_block_name,hr_api.g_varchar2);
   --
   -- For each navigation node associated with a navigation unit call
   -- the delete_navigation_nodes procedure to delete the navigation
   -- node data.  This includes node usages and navigation paths.
   --
   FOR node_record IN csr_nav_nodes LOOP
      l_node_name := node_record.name;
      delete_navigation_node(l_node_name);
   END LOOP;
   --
   -- For each global usage associaged with a navigation unit, delete
   -- all of the navigation context rules, then delete the global
   -- usage record.
   --
   FOR global_usage_record IN csr_global_usages LOOP
      l_global_usage_id := global_usage_record.global_usage_id;
      DELETE FROM hr_navigation_context_rules
      WHERE       global_usage_id = l_global_usage_id;
      DELETE FROM hr_nav_unit_global_usages
      WHERE       global_usage_id = l_global_usage_id;
   END LOOP;
   --
   -- Delete all of the incompatibility rules associated with a
   -- navigation unit.
   --
   DELETE FROM hr_incompatibility_rules
   WHERE       from_nav_unit_id = l_nav_unit_id
   OR          to_nav_unit_id = l_nav_unit_id;
   --
   -- Delete the navigation unit record.
   --

   DELETE FROM hr_navigation_units_tl
   WHERE       nav_unit_id = l_nav_unit_id;

   DELETE FROM hr_navigation_units
   WHERE       nav_unit_id = l_nav_unit_id;

END delete_navigation_unit;

--
-- Procedure to delete a navigation node and related data.
--
PROCEDURE delete_navigation_node (
  p_nav_node_name IN VARCHAR2
) IS
l_nav_node_id NUMBER;
l_nav_node_usage_id NUMBER;
l_nav_path_id number;
--
-- Cursor to bring back all of the node usages for a node.
--
-- Bug 3648687. Modified the following cursor.
--
CURSOR csr_node_usages IS
  SELECT nnu.nav_node_usage_id, hnp.nav_path_id
  FROM   hr_navigation_node_usages nnu,
         hr_navigation_paths hnp
  WHERE  nav_node_id = l_nav_node_id
  AND    (nnu.nav_node_usage_id = hnp.from_nav_node_usage_id
          OR nnu.nav_node_usage_id = hnp.to_nav_node_usage_id);
BEGIN
   --
   -- Find the nav_node_id that correspond to p_nav_node_name.
   --
   SELECT nav_node_id
   INTO   l_nav_node_id
   FROM   hr_navigation_nodes
   WHERE  name = p_nav_node_name;
   --
   -- For each node usage attached to a node delete the navigation paths
   -- then delete the node usage record.
   --
   FOR node_usage_record IN csr_node_usages LOOP
      l_nav_node_usage_id := node_usage_record.nav_node_usage_id;
      l_nav_path_id := node_usage_record.nav_path_id;

      DELETE FROM hr_navigation_paths_tl
      WHERE       nav_path_id           = l_nav_path_id;

      DELETE FROM hr_navigation_paths
      WHERE       from_nav_node_usage_id = l_nav_node_usage_id
      OR          to_nav_node_usage_id = l_nav_node_usage_id
      OR          nav_path_id           = l_nav_path_id;

      DELETE FROM hr_navigation_node_usages
      WHERE       nav_node_usage_id = l_nav_node_usage_id;
   END LOOP;
   --
   -- Delete the navigation node.
   --
   DELETE FROM hr_navigation_nodes
   WHERE       nav_node_id = l_nav_node_id;
END delete_navigation_node;

END per_maintain_taskflow;


/
