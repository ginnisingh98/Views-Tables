--------------------------------------------------------
--  DDL for Package MSC_GET_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_GET_PROFILE" AS-- specification
/* $Header: MSCPROFS.pls 115.1 2004/05/21 13:11:55 rawasthi noship $ */


  ----- CONSTANTS --------------------------------------------------------

   G_CONC_ERROR                            CONSTANT NUMBER := 3;
   G_SUCCESS                               CONSTANT NUMBER := 0;
   G_WARNING                               CONSTANT NUMBER := 1;
   G_ERROR                                 CONSTANT NUMBER := 2;

  PROCEDURE GETPROF  ( ERRBUF                OUT NOCOPY VARCHAR2,
                       RETCODE               OUT NOCOPY NUMBER,
                       preference_set_name   IN  VARCHAR2,
                       usr_name   IN varchar2 DEFAULT NULL,
                       application_name IN varchar2 DEFAULT NULL,
                       resp_name IN varchar2 DEFAULT NULL,
                       schema_name IN varchar2,
                       p_file_name IN varchar2);

END MSC_GET_PROFILE;

 

/
