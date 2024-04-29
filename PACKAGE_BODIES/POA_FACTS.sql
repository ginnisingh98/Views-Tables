--------------------------------------------------------
--  DDL for Package Body POA_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_FACTS" AS
/* $Header: poasvp0b.pls 120.1 2005/10/05 11:43:17 nnewadka noship $ */

  /*
    NAME
      populate_facts -
    DESCRIPTION
     main function for populating poa fact tables
     for Oracle Purchasing
  */
  --
  PROCEDURE populate_facts (errbuf	    OUT	NOCOPY VARCHAR2,
                            retcode	    OUT NOCOPY NUMBER,
                            p_start_date    IN  VARCHAR2,
                            p_end_date	    IN  VARCHAR2)
  IS

  v_buf		VARCHAR2(240) := NULL;
  v_start_date 	DATE;
  v_end_date	DATE;

  BEGIN

    errbuf := NULL;
    retcode := 0;

    POA_LOG.setup('POAPOPF');

    SELECT NVL(TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS'), to_date(1,'J'))
    INTO v_start_date
    FROM sys.dual;

    SELECT NVL(TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS'), sysdate)
    INTO v_end_date
    FROM sys.dual;

    POA_LOG.put_line('Parameter start_date is: ' ||
	fnd_date.date_to_chardate(v_start_date));
    POA_LOG.put_line(' ');

    POA_LOG.put_line('Parameter end_date is: ' ||
	fnd_date.date_to_chardate(v_end_date));
    POA_LOG.put_line(' ');

    poa_savings_main.populate_savings(v_start_date, v_end_date+1);

    POA_LOG.put_line('Spend Analysis data populated');
    POA_LOG.put_line(' ');


    POA_LOG.wrapup('SUCCESS');

    RETURN;

  EXCEPTION
    WHEN others THEN

     errbuf := sqlerrm;
     retcode := sqlcode;

     v_buf := to_char(retcode) || ':' || errbuf;
     ROLLBACK;
     POA_LOG.put_line(v_buf);
     POA_LOG.wrapup('ERROR');

     RETURN;
  END populate_facts;
  --

END poa_facts;
--

/
