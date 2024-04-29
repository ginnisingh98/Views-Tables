--------------------------------------------------------
--  DDL for Package Body CN_CLASSIFICATION_CONC_SUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CLASSIFICATION_CONC_SUBMIT" AS
-- $Header: cncpclsb.pls 120.4 2005/08/05 04:42:55 rramakri ship $
  PROCEDURE submit_request (x_ruleset_id   IN   NUMBER,
                            x_request_id    OUT NOCOPY NUMBER,
			    x_org_id   IN   NUMBER) IS

    l_request_id                 NUMBER;

  BEGIN
    FND_REQUEST.SET_ORG_ID(x_org_id);
    l_request_id := FND_REQUEST.SUBMIT_REQUEST('CN', 'CN_CL_RULES_INSTALL',
                         NULL, NULL, FALSE,
                         x_ruleset_id,x_org_id);
    IF l_request_id <> 0 THEN
       --commit;
      null;
    END IF;
    x_request_id := l_request_id;
  END submit_request;
END CN_CLASSIFICATION_CONC_SUBMIT;

/
