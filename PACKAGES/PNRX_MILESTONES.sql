--------------------------------------------------------
--  DDL for Package PNRX_MILESTONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNRX_MILESTONES" AUTHID CURRENT_USER AS
/* $Header: PNRXMSTS.pls 115.4 2002/11/14 20:23:38 stripath ship $ */

PROCEDURE pn_milestones(
          lease_number_low                  IN                    VARCHAR2,
          lease_number_high                 IN                    VARCHAR2,
          location_code_low                 IN                    VARCHAR2,
          location_code_high                IN                    VARCHAR2,
          lease_termination_from            IN                    DATE,
          lease_termination_to              IN                    DATE,
          responsible_user                  IN                    VARCHAR2,
          action_due_date_from              IN                    DATE,
          action_due_date_to                IN                    DATE,
          milestone_type                    IN                    VARCHAR2,
          l_request_id                      IN                    NUMBER,
          l_user_id                         IN                    NUMBER,
          retcode                           OUT NOCOPY                   VARCHAR2,
          errbuf                            OUT NOCOPY                   VARCHAR2
                   );

END pnrx_milestones;

 

/
