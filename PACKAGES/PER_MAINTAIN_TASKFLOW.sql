--------------------------------------------------------
--  DDL for Package PER_MAINTAIN_TASKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MAINTAIN_TASKFLOW" AUTHID CURRENT_USER AS
/* $Header: petkflow.pkh 115.1 2003/06/03 10:06:40 pkakar noship $ */

--
-- Procedure to delete a taskflow and related data.
--
PROCEDURE delete_taskflow (
  p_taskflow_name IN VARCHAR2
);

--
-- Procedure to delete a navigation unit and related data.
--
PROCEDURE delete_navigation_unit (
  p_form_name IN VARCHAR2,
  p_block_name IN VARCHAR2
);

--
-- Procedure to delete a navigation node and related data.
--
PROCEDURE delete_navigation_node (
  p_nav_node_name IN VARCHAR2
);

END per_maintain_taskflow;


 

/
