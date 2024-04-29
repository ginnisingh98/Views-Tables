--------------------------------------------------------
--  DDL for Package Body ARRX_C_COGS_REP_OUTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_C_COGS_REP_OUTER" AS
/* $Header: ARRXCWRB.pls 120.1 2005/10/30 04:45:52 appldev noship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
  g_variable1                  VARCHAR2(10);
  g_variable2                  NUMBER      ;

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/

   pg_debug varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE wrapper (
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  argument1         IN  VARCHAR2  DEFAULT  NULL,  -- gl date low
  argument2         IN  VARCHAR2  DEFAULT  NULL,  -- gl date high
  argument3         IN  VARCHAR2  DEFAULT  NULL,  -- sales order low
  argument4         IN  VARCHAR2  DEFAULT  NULL,  -- sales order high
  argument5         IN  VARCHAR2  DEFAULT  NULL,  -- posted line only?
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
  argument100       IN  VARCHAR2  DEFAULT  NULL) IS

  l_gl_date_low   	 DATE;
  l_gl_date_high  	 DATE;
  l_sales_order_low      VARCHAR2(30);
  l_sales_order_high	 VARCHAR2(30);
  l_posted_lines_only    VARCHAR2(1);
  l_unmatched_items_only VARCHAR2(1);
  l_request_id           NUMBER;
  l_user_id              NUMBER;

BEGIN

  -- call the inner report passing mandatory parameters
  -- and report specific parameters

  IF pg_debug in ('Y', 'C') THEN
    fnd_file.put_line(fnd_file.log, 'ARRX_C_COGS_REP_OUTER.WRAPPER()+');
    fnd_file.put_line(fnd_file.log, 'argument1 : ' || argument1);
    fnd_file.put_line(fnd_file.log, 'argument2 : ' || argument2);
    fnd_file.put_line(fnd_file.log, 'argument3 : ' || argument3);
    fnd_file.put_line(fnd_file.log, 'argument4 : ' || argument4);
    fnd_file.put_line(fnd_file.log, 'argument5 : ' || argument5);
    fnd_file.put_line(fnd_file.log, 'argument6 : ' || argument6);
  END IF;

  -- Populate mandatory parameters for request_id and user_id

  l_user_id := NVL(fnd_global.user_id, -1);
  l_request_id := NVL(fnd_global.conc_request_id, -1);

  -- Assign parameters to local variables doing any necessary mappings
  -- e.g. Date/Number conversions

  l_gl_date_low          := fnd_date.canonical_to_date(argument1);
  l_gl_date_high         := fnd_date.canonical_to_date(argument2);
  l_sales_order_low      := argument3;
  l_sales_order_high     := argument4;
  l_posted_lines_only    := argument5;
  l_unmatched_items_only := argument6;

  fnd_file.put_line(fnd_file.log, 'request id: '        || l_request_id);
  fnd_file.put_line(fnd_file.log, 'user id : '          || l_user_id);
  fnd_file.put_line(fnd_file.log, 'low gl date: '       || l_gl_date_low);
  fnd_file.put_line(fnd_file.log, 'high gl date: '      || l_gl_date_high);
  fnd_file.put_line(fnd_file.log, 'low sales order: '   || l_sales_order_low);
  fnd_file.put_line(fnd_file.log, 'high sales order: '  || l_sales_order_high);
  fnd_file.put_line(fnd_file.log, 'posted lines only: ' ||
    l_posted_lines_only);
  fnd_file.put_line(fnd_file.log, 'unmatched items only: ' ||
    l_unmatched_items_only);

  arrx_cogs_rep_inner.populate_rows
  (
    p_gl_date_low   	   => l_gl_date_low,
    p_gl_date_high  	   => l_gl_date_high,
    p_sales_order_low      => l_sales_order_low,
    p_sales_order_high	   => l_sales_order_high,
    p_posted_lines_only    => l_posted_lines_only,
    p_unmatched_items_only => l_unmatched_items_only,
    p_user_id 		   => l_user_id,
    p_request_id      	   => l_request_id,
    x_retcode         	   => retcode,
    x_errbuf          	   => errbuf
  );

  fnd_file.put_line(fnd_file.log, 'after arrx_cogs_rep_inner.populate_rows');

  IF PG_DEBUG in ('Y', 'C') THEN
    fnd_file.put_line(fnd_file.log, 'ARRX_C_COGS_REP_OUTER.WRAPPER()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      fnd_file.put_line(fnd_file.log,
                        'EXCEPTION: arrx_c_cogs_rep_outer.wrapper()');
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      fnd_file.put_line(fnd_file.log, sqlcode);
      fnd_file.put_line(fnd_file.log, sqlerrm);
      retcode := 2;
      fnd_file.put_line(fnd_file.log,
        'EXCEPTION: arrx_c_cogs_rep_outer.wrapper()');
    END IF;
    RAISE;

END wrapper;


PROCEDURE summary (
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  argument1         IN  VARCHAR2  DEFAULT  NULL,  -- gl date low
  argument2         IN  VARCHAR2  DEFAULT  NULL,  -- gl date high
  argument3         IN  VARCHAR2  DEFAULT  NULL,  -- chart of accounts id
  argument4         IN  VARCHAR2  DEFAULT  NULL,  -- cogs gl account low
  argument5         IN  VARCHAR2  DEFAULT  NULL,  -- cogs gl account high
  argument6         IN  VARCHAR2  DEFAULT  NULL,  -- posted line only?
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
  argument100       IN  VARCHAR2  DEFAULT  NULL) IS

  l_gl_date_low   	 DATE;
  l_gl_date_high  	 DATE;
  l_chart_of_accounts_id NUMBER;
  l_gl_account_low       VARCHAR2(240);
  l_gl_account_high	 VARCHAR2(240);
  l_posted_lines_only    VARCHAR2(1);
  l_request_id           NUMBER;
  l_user_id              NUMBER;

BEGIN

  -- call the inner report passing mandatory parameters
  -- and report specific parameters

  fnd_file.put_line(fnd_file.log, 'ARRX_C_COGS_REP_OUTER.SUMMARY()+');

  IF pg_debug in ('Y', 'C') THEN
    fnd_file.put_line(fnd_file.log, 'ARRX_C_COGS_REP_OUTER.SUMMARY()+');
    fnd_file.put_line(fnd_file.log, 'argument1 : ' || argument1);
    fnd_file.put_line(fnd_file.log, 'argument2 : ' || argument2);
    fnd_file.put_line(fnd_file.log, 'argument3 : ' || argument3);
    fnd_file.put_line(fnd_file.log, 'argument4 : ' || argument4);
    fnd_file.put_line(fnd_file.log, 'argument5 : ' || argument5);
    fnd_file.put_line(fnd_file.log, 'argument6 : ' || argument6);
  END IF;

  -- Populate mandatory parameters for request_id and user_id

  l_user_id := NVL(fnd_global.user_id, -1);
  l_request_id := NVL(fnd_global.conc_request_id, -1);

  -- Assign parameters to local variables doing any necessary mappings
  -- e.g. Date/Number conversions

  l_gl_date_low          := fnd_date.canonical_to_date(argument1);
  l_gl_date_high         := fnd_date.canonical_to_date(argument2);
  l_chart_of_accounts_id := argument3;
  l_gl_account_low       := argument4;
  l_gl_account_high      := argument5;
  l_posted_lines_only    := argument6;

  fnd_file.put_line(fnd_file.log, 'request id: '        || l_request_id);
  fnd_file.put_line(fnd_file.log, 'user id: '           || l_user_id);
  fnd_file.put_line(fnd_file.log, 'chart of account: '  ||
    l_chart_of_accounts_id);
  fnd_file.put_line(fnd_file.log, 'low gl account: '    || l_gl_date_low);
  fnd_file.put_line(fnd_file.log, 'high gl account: '   || l_gl_date_high);
  fnd_file.put_line(fnd_file.log, 'posted lines only: ' ||
    l_posted_lines_only);

  -- call the inner routine to actually populate the interface table.
  arrx_cogs_rep_inner.populate_summary
  (
    p_gl_date_low   	   => l_gl_date_low,
    p_gl_date_high  	   => l_gl_date_high,
    p_chart_of_accounts_id => l_chart_of_accounts_id,
    p_gl_account_low       => l_gl_account_low,
    p_gl_account_high      => l_gl_account_high,
    p_posted_lines_only    => l_posted_lines_only,
    p_user_id 		   => l_user_id,
    p_request_id      	   => l_request_id,
    x_retcode         	   => retcode,
    x_errbuf          	   => errbuf
  );

  fnd_file.put_line(fnd_file.log, 'after arrx_cogs_rep_inner.populate_rows');

  IF PG_DEBUG in ('Y', 'C') THEN
    fnd_file.put_line(fnd_file.log, 'ARRX_C_COGS_REP_OUTER.WRAPPER()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      fnd_file.put_line(fnd_file.log,
                        'EXCEPTION: arrx_c_cogs_rep_outer.wrapper()');
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      fnd_file.put_line(fnd_file.log, sqlcode);
      fnd_file.put_line(fnd_file.log, sqlerrm);
      retcode := 2;
      fnd_file.put_line(fnd_file.log,
        'EXCEPTION: arrx_c_cogs_rep_outer.wrapper()');
    END IF;
    RAISE;

END summary;


/*========================================================================
 | INITIALIZATION SECTION
 |
 | DESCRIPTION
 |
 *=======================================================================*/

BEGIN

   NULL;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.log,
                       'EXCEPTION: arrx_c_cogs_rep_outer.initialize()');
     RAISE;

  WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log,
                       'EXCEPTION: arrx_c_cogs_rep_outer.initialize()');
     RAISE;

END arrx_c_cogs_rep_outer;

/
