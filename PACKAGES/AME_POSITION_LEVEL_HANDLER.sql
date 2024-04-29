--------------------------------------------------------
--  DDL for Package AME_POSITION_LEVEL_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_POSITION_LEVEL_HANDLER" AUTHID CURRENT_USER as
/* $Header: ameeplha.pkh 120.0 2005/07/26 05:58:40 mbocutt noship $ */
--
  function  getNextPosition(positionIdIn in integer) return integer;
--
  procedure handler;
end ame_position_level_handler;

 

/
