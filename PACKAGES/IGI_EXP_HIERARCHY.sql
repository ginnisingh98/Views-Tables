--------------------------------------------------------
--  DDL for Package IGI_EXP_HIERARCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_HIERARCHY" AUTHID CURRENT_USER AS
--  $Header: igiexpks.pls 120.2.12010000.1 2009/02/04 08:58:45 vensubra ship $

   PROCEDURE MAINTAIN
     ( p_position_structure_id IN number,
       p_role_id IN number );


 END IGI_EXP_HIERARCHY ; -- Package Specification IGI_EXP_HIERARCHY

/
