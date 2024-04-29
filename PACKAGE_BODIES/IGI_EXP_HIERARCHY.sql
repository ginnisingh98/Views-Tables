--------------------------------------------------------
--  DDL for Package Body IGI_EXP_HIERARCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_HIERARCHY" AS
-- $Header: igiexpkb.pls 120.3.12010000.1 2009/02/04 08:55:57 vensubra ship $


-- this package will be called when a request is made to update an approval hierarchy
-- associated with a workflow profile. the workflow profile is updated to include the
-- latest hierarchy changes.

-- $Header: igiexpkb.pls 120.3.12010000.1 2009/02/04 08:55:57 vensubra ship $
   PROCEDURE maintain  ( p_position_structure_id IN NUMBER,
                         p_role_id IN number)
   IS
BEGIN
NULL;
END maintain ;

END; -- Package Body IGI_EXP_HIERARCHY

/
