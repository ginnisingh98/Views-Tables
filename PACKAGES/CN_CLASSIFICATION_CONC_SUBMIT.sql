--------------------------------------------------------
--  DDL for Package CN_CLASSIFICATION_CONC_SUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CLASSIFICATION_CONC_SUBMIT" AUTHID CURRENT_USER as
-- $Header: cncpclss.pls 120.2 2005/07/12 22:14:51 appldev ship $

  PROCEDURE submit_request (x_ruleset_id   IN   NUMBER,
                            x_request_id    OUT NOCOPY NUMBER,
			    x_org_id   IN   NUMBER);


END CN_CLASSIFICATION_CONC_SUBMIT;

 

/
