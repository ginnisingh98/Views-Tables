--------------------------------------------------------
--  DDL for Package AZ_FLEX_COMPILER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZ_FLEX_COMPILER" AUTHID CURRENT_USER AS
/*$Header: azfcomps.pls 115.2 2003/03/10 22:20:03 jke noship $*/

PROCEDURE submit(
--     ERRBUF                           OUT    VARCHAR2,
--     RETCODE                          OUT    NUMBER,
      p_mode                         IN     VARCHAR2,
      p_app_short_name               IN     VARCHAR2,
      P_FLEX_NAME                 IN     VARCHAR2);

END AZ_FLEX_COMPILER;

 

/
