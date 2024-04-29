--------------------------------------------------------
--  DDL for Package Body CN_CONC_PRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CONC_PRG" AS
-- $Header: cncpsubb.pls 115.2 99/07/16 07:05:39 porting shi $
  PROCEDURE submit_request (x_ruleset_id   IN   cn_rulesets.ruleset_id%TYPE,
                            x_spool_path   IN   VARCHAR2,
                            x_request_id    OUT  NUMBER) IS

    l_request_id                 NUMBER;

  BEGIN
    l_request_id := FND_REQUEST.SUBMIT_REQUEST('CN', 'CN_CL_RULES_INSTALL',
                         '', '', FALSE,
                         x_spool_path||'cn_clsfn_'||to_char(x_ruleset_id),
                         to_char(x_ruleset_id), chr(0),
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '');
    IF l_request_id <> 0 THEN
      commit;
    END IF;
    x_request_id := l_request_id;
  END submit_request;
END cn_conc_prg;

/
