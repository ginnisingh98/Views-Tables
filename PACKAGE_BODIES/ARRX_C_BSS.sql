--------------------------------------------------------
--  DDL for Package Body ARRX_C_BSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_C_BSS" AS
/* $Header: ARRXCBSB.pls 115.2 2002/11/15 03:10:36 anukumar ship $ */

PROCEDURE run_report(
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  argument1         IN  VARCHAR2, -- Reporting Level
  argument2         IN  VARCHAR2, -- Reporting Context
  argument3         IN  VARCHAR2, -- As of Date
  argument4         IN  VARCHAR2  DEFAULT  NULL,
  argument5         IN  VARCHAR2  DEFAULT  NULL,
  argument6         IN  VARCHAR2  DEFAULT  NULL,
  argument7         IN  VARCHAR2  DEFAULT  NULL,
  argument8         IN  VARCHAR2  DEFAULT  NULL,
  argument9         IN  VARCHAR2  DEFAULT  NULL,
  argument10        IN  VARCHAR2  DEFAULT  NULL,
  argument11        IN  VARCHAR2  DEFAULT  NULL,
  argument12        IN  VARCHAR2  DEFAULT  NULL,
  argument13        IN  VARCHAR2  DEFAULT  NULL,
  argument14        IN  VARCHAR2  DEFAULT  NULL,
  argument15        IN  VARCHAR2  DEFAULT  NULL,
  argument16        IN  VARCHAR2  DEFAULT  NULL,
  argument17        IN  VARCHAR2  DEFAULT  NULL,
  argument18        IN  VARCHAR2  DEFAULT  NULL,
  argument19        IN  VARCHAR2  DEFAULT  NULL,
  argument20        IN  VARCHAR2  DEFAULT  NULL,
  argument21        IN  VARCHAR2  DEFAULT  NULL,
  argument22        IN  VARCHAR2  DEFAULT  NULL,
  argument23        IN  VARCHAR2  DEFAULT  NULL,
  argument24        IN  VARCHAR2  DEFAULT  NULL,
  argument25        IN  VARCHAR2  DEFAULT  NULL,
  argument26        IN  VARCHAR2  DEFAULT  NULL,
  argument27        IN  VARCHAR2  DEFAULT  NULL,
  argument28        IN  VARCHAR2  DEFAULT  NULL,
  argument29        IN  VARCHAR2  DEFAULT  NULL,
  argument30        IN  VARCHAR2  DEFAULT  NULL,
  argument31        IN  VARCHAR2  DEFAULT  NULL,
  argument32        IN  VARCHAR2  DEFAULT  NULL,
  argument33        IN  VARCHAR2  DEFAULT  NULL,
  argument34        IN  VARCHAR2  DEFAULT  NULL,
  argument35        IN  VARCHAR2  DEFAULT  NULL,
  argument36        IN  VARCHAR2  DEFAULT  NULL,
  argument37        IN  VARCHAR2  DEFAULT  NULL,
  argument38        IN  VARCHAR2  DEFAULT  NULL,
  argument39        IN  VARCHAR2  DEFAULT  NULL,
  argument40        IN  VARCHAR2  DEFAULT  NULL,
  argument41        IN  VARCHAR2  DEFAULT  NULL,
  argument42        IN  VARCHAR2  DEFAULT  NULL,
  argument43        IN  VARCHAR2  DEFAULT  NULL,
  argument44        IN  VARCHAR2  DEFAULT  NULL,
  argument45        IN  VARCHAR2  DEFAULT  NULL,
  argument46        IN  VARCHAR2  DEFAULT  NULL,
  argument47        IN  VARCHAR2  DEFAULT  NULL,
  argument48        IN  VARCHAR2  DEFAULT  NULL,
  argument49        IN  VARCHAR2  DEFAULT  NULL,
  argument50        IN  VARCHAR2  DEFAULT  NULL,
  argument51        IN  VARCHAR2  DEFAULT  NULL,
  argument52        IN  VARCHAR2  DEFAULT  NULL,
  argument53        IN  VARCHAR2  DEFAULT  NULL,
  argument54        IN  VARCHAR2  DEFAULT  NULL,
  argument55        IN  VARCHAR2  DEFAULT  NULL,
  argument56        IN  VARCHAR2  DEFAULT  NULL,
  argument57        IN  VARCHAR2  DEFAULT  NULL,
  argument58        IN  VARCHAR2  DEFAULT  NULL,
  argument59        IN  VARCHAR2  DEFAULT  NULL,
  argument60        IN  VARCHAR2  DEFAULT  NULL,
  argument61        IN  VARCHAR2  DEFAULT  NULL,
  argument62        IN  VARCHAR2  DEFAULT  NULL,
  argument63        IN  VARCHAR2  DEFAULT  NULL,
  argument64        IN  VARCHAR2  DEFAULT  NULL,
  argument65        IN  VARCHAR2  DEFAULT  NULL,
  argument66        IN  VARCHAR2  DEFAULT  NULL,
  argument67        IN  VARCHAR2  DEFAULT  NULL,
  argument68        IN  VARCHAR2  DEFAULT  NULL,
  argument69        IN  VARCHAR2  DEFAULT  NULL,
  argument70        IN  VARCHAR2  DEFAULT  NULL,
  argument71        IN  VARCHAR2  DEFAULT  NULL,
  argument72        IN  VARCHAR2  DEFAULT  NULL,
  argument73        IN  VARCHAR2  DEFAULT  NULL,
  argument74        IN  VARCHAR2  DEFAULT  NULL,
  argument75        IN  VARCHAR2  DEFAULT  NULL,
  argument76        IN  VARCHAR2  DEFAULT  NULL,
  argument77        IN  VARCHAR2  DEFAULT  NULL,
  argument78        IN  VARCHAR2  DEFAULT  NULL,
  argument79        IN  VARCHAR2  DEFAULT  NULL,
  argument80        IN  VARCHAR2  DEFAULT  NULL,
  argument81        IN  VARCHAR2  DEFAULT  NULL,
  argument82        IN  VARCHAR2  DEFAULT  NULL,
  argument83        IN  VARCHAR2  DEFAULT  NULL,
  argument84        IN  VARCHAR2  DEFAULT  NULL,
  argument85        IN  VARCHAR2  DEFAULT  NULL,
  argument86        IN  VARCHAR2  DEFAULT  NULL,
  argument87        IN  VARCHAR2  DEFAULT  NULL,
  argument88        IN  VARCHAR2  DEFAULT  NULL,
  argument89        IN  VARCHAR2  DEFAULT  NULL,
  argument90        IN  VARCHAR2  DEFAULT  NULL,
  argument91        IN  VARCHAR2  DEFAULT  NULL,
  argument92        IN  VARCHAR2  DEFAULT  NULL,
  argument93        IN  VARCHAR2  DEFAULT  NULL,
  argument94        IN  VARCHAR2  DEFAULT  NULL,
  argument95        IN  VARCHAR2  DEFAULT  NULL,
  argument96        IN  VARCHAR2  DEFAULT  NULL,
  argument97        IN  VARCHAR2  DEFAULT  NULL,
  argument98        IN  VARCHAR2  DEFAULT  NULL,
  argument99        IN  VARCHAR2  DEFAULT  NULL,
  argument100       IN  VARCHAR2  DEFAULT  NULL)

IS

  l_request_id                  NUMBER;
  l_user_id                     NUMBER;
  l_reporting_level             FND_LOOKUPS.lookup_code%TYPE;
  l_reporting_context           GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
  l_as_of_date                  AR_TRANSACTION_HISTORY.trx_date%TYPE;

  BEGIN

    -- Populate mandatory parameters for request_id and user_id
    l_request_id := fnd_global.conc_request_id;
    fnd_profile.get('USER_ID', l_user_id);

    -- Assign parameters to local variables doing any necessary mappings
    -- e.g. Date/Number conversions
    l_reporting_level             := argument1;
    l_reporting_context           := to_number(argument2);
    l_as_of_date                  := to_date(argument3, 'YYYY/MM/DD HH24:MI:SS');


    -- Call the inner report passing mandatory parameters and report specific parameters
    arrx_bss.arrxbss_report(l_request_id
                           ,l_user_id
                           ,l_reporting_level
                           ,l_reporting_context
                           ,l_as_of_date
                           ,retcode
                           ,errbuf);

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,sqlcode);
      fnd_file.put_line(fnd_file.log,sqlerrm);
      retcode := 2;
    RAISE;

  END run_report;

END arrx_c_bss;

/
