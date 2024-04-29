--------------------------------------------------------
--  DDL for Package Body FND_FORMS_SERVICE_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FORMS_SERVICE_GEN" AS
  /* $Header: affrsvgb.pls 120.0.12010000.3 2009/10/14 20:11:53 dbowles noship $ */

  PROCEDURE handleError(formid       VARCHAR2,
                        message_type VARCHAR2,
                        message      VARCHAR2,
                        servleturl   VARCHAR2) AS
    LANGUAGE JAVA

  NAME 'oracle.apps.fnd.soa.forms.services.rt.jsp.FormsErrorHandler.handleError(java.lang.String,
                                                                                java.lang.String,
                                                                                java.lang.String,
                                                                                java.lang.String )';
END fnd_forms_service_gen;

/
