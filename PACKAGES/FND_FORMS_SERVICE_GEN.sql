--------------------------------------------------------
--  DDL for Package FND_FORMS_SERVICE_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FORMS_SERVICE_GEN" AUTHID CURRENT_USER AS
  /* $Header: affrsvgs.pls 120.0.12010000.3 2009/10/14 20:12:52 dbowles noship $ */
  PROCEDURE handleError(formid       VARCHAR2,
                        message_type VARCHAR2,
                        message      VARCHAR2,
                        servleturl   VARCHAR2);
END fnd_forms_service_gen;

/
