--------------------------------------------------------
--  DDL for Package CN_CONC_PRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CONC_PRG" AUTHID CURRENT_USER AS
-- $Header: cncpsubs.pls 115.3 99/07/16 07:05:43 porting shi $
--
-- Procedure Name
--   submit_request
-- History
--   01/22/99		Renu Chintalapati	Created
--
PROCEDURE submit_request ( x_ruleset_id    IN   cn_rulesets.ruleset_id%TYPE,
                           x_spool_path    IN   VARCHAR2,
                           x_request_id    OUT  NUMBER);
--
END cn_conc_prg;

 

/
