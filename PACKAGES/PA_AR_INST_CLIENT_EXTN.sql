--------------------------------------------------------
--  DDL for Package PA_AR_INST_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AR_INST_CLIENT_EXTN" AUTHID CURRENT_USER AS
/* $Header: PAVARICS.pls 120.1 2005/08/19 17:07:02 mwasowic noship $ */
      PROCEDURE client_extn_driver
          (  p_ar_inst_mode             IN    VARCHAR2,
             x_ar_inst_mode		OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
end pa_ar_inst_client_extn;

 

/
