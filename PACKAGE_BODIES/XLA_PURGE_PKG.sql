--------------------------------------------------------
--  DDL for Package Body XLA_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_PURGE_PKG" AS
/* $Header: xlapurge.pkb 120.0.12010000.4 2009/12/10 20:07:02 vkasina noship $ */

--=============================================================================
-- Function to get the GroupID from a given XLA_GLT_XXXX table
--=============================================================================
FUNCTION GetGroupID(p_gltname IN VARCHAR2)
RETURN NUMBER IS
  l_length NUMBER;
  l_number VARCHAR2(2000) := '';
BEGIN
  l_length := length(p_gltname);

  FOR i IN 1..l_length
  LOOP
     IF substr(p_gltname,i,1) IN ('0','1','2','3','4','5','6','7','8','9') THEN
          l_number := l_number || substr(p_gltname,i,1);
     END IF;
  END LOOP;

  IF l_number IS NULL THEN
     RETURN 0;
  ELSE
     RETURN TO_NUMBER(RTRIM(LTRIM(l_number)));
  END IF;

END GetGroupID;


--=============================================================================
--                   ******* Print Log File **********
--=============================================================================

PROCEDURE print_logfile(p_msg  IN  VARCHAR2) IS
BEGIN

   fnd_file.put_line(fnd_file.log,p_msg);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_accounting_pkg.print_logfile');
END print_logfile;


PROCEDURE drop_glt
   (  p_errbuf          OUT NOCOPY VARCHAR2
     ,p_retcode         OUT NOCOPY NUMBER
     ,p_application_id  IN NUMBER
     ,p_dummy_parameter IN VARCHAR2
     ,p_ledger_id       IN NUMBER
     ,p_end_date        IN VARCHAR2 )
IS
  l_status        VARCHAR2(5);
  l_industry      VARCHAR2(5);
  l_table_owner   VARCHAR2(30);

  l_statement     VARCHAR2(60) := null;
  l_rec_count     NUMBER := 0;
  l_category      VARCHAR2(30);
  l_ledger_name   gl_ledgers.name%TYPE;
  l_end_date      DATE;

CURSOR getledgers IS
      SELECT ledger_id
            ,NAME
            ,ledger_category_code
       FROM  xla_ledger_relationships_v xlr
      WHERE  xlr.primary_ledger_id         = p_ledger_id
        AND  xlr.relationship_enabled_flag = 'Y'
      ORDER BY DECODE(xlr.ledger_category_code,
                     'PRIMARY',1,
                     'ALC',2
                     ,3);

--Cursor to get group_id's that needs to be dropped.
--
CURSOR drop_glt(l_ledger_id IN NUMBER, l_table_owner VARCHAR2) is
SELECT group_id
FROM
xla_ae_headers xah,
xla_Ae_lines xal,
dba_tables dbj
WHERE xah.accounting_entry_status_code='F'
AND xah.accounting_date <= l_end_date
AND xah.ledger_id = l_ledger_id
AND xah.group_id = GetGroupID(dbj.table_name) -- TO_NUMBER(TRIM(SUBSTR(dbj.table_name,9)))
AND NOT EXISTS
   (
    SELECT 1 FROM GL_PERIOD_STATUSES GLP
    WHERE GLP.APPLICATION_ID = 101
    AND GLP.PERIOD_NAME in (select distinct xah1.period_name
               from xla_ae_headers xah1
               where xah1.application_id = xah.application_id
               and xah1.ledger_id = xah.ledger_id
               and xah1.group_id = xah.group_id)
   AND glp.closing_status in ('O', 'F')
   AND glp.adjustment_period_flag = 'N'
   AND glp.ledger_id = xah.ledger_id
  )
AND dbj.owner = l_table_owner
AND dbj.table_name like 'XLA_GLT_%'
AND xah.ae_header_id = xal.ae_header_id
AND xah.application_id=xal.application_id
AND xah.ledger_id=xal.ledger_id
AND EXISTS
(
 SELECT 1 FROM gl_je_batches glb,gl_import_references gir,gl_je_headers gjh
  WHERE xal.gl_sl_link_id=gir.gl_sl_link_id
  AND xal.gl_sl_link_table=gir.gl_sl_link_table
  AND gir.gl_sl_link_table='XLAJEL'
  AND gir.je_batch_id=glb.je_batch_id
  AND gir.je_header_id=gjh.je_header_id
  AND gjh.ledger_id=xah.ledger_id
  AND glb.group_id is not null
  AND glb.group_id = xah.group_id
 )
UNION
SELECT TO_NUMBER(SUBSTR(table_name,9)) as group_id
FROM dba_tables dbj
WHERE table_name LIKE 'XLA_GLT_%'
AND owner = l_table_owner
AND NOT EXISTS
 (
  SELECT 1 FROM xla_ae_headers xlh
  WHERE xlh.group_id = GetGroupID(dbj.table_name) --TO_NUMBER(TRIM(SUBSTR(dbj.table_name,9)))
 )
;

BEGIN

    l_end_date := fnd_date.canonical_to_date(p_end_date);


    print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Starting To Purge The XLA_GLT tables ');
    p_retcode := 0;

	BEGIN

	    IF NOT fnd_installation.get_app_info (application_short_name => 'SQLGL',
                       status                  => l_status ,
                       industry                => l_industry,
                       oracle_schema           => l_table_owner) THEN
		       RAISE NO_DATA_FOUND;
	    END IF;

		 EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			l_table_owner := 'GL';
		    WHEN OTHERS THEN
			RAISE;
	END;

	BEGIN

 	 SELECT ledger_category_code, NAME
	   INTO l_category, l_ledger_name
	 FROM gl_ledgers
	 WHERE ledger_id = p_ledger_id;

         EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RAISE;
                p_retcode :=  2;
                p_errbuf  := 'The Ledger_id provided is not a valid Primary Ledger_id. Please give a valid primary ledger_id';
		print_logfile('The Ledger_id provided is not a valid Primary Ledger_id. Please give a valid primary ledger_id');

		WHEN OTHERS THEN
		RAISE;
		p_errbuf  := substr(SQLERRM,1,100);
                p_retcode :=  2;
                print_logfile(sqlerrm);

	END;

	IF l_category = 'PRIMARY' then
        FOR getledgers_rec in getledgers
        LOOP
                 FOR glt_rec in drop_glt(getledgers_rec.ledger_id, l_table_owner)
                 LOOP
                 BEGIN
			    l_rec_count := l_rec_count + 1;
			    IF glt_rec.group_id is not null THEN
			      l_statement := 'DROP TABLE '||l_table_owner||'.XLA_GLT_'||glt_rec.group_id;
			      EXECUTE IMMEDIATE l_statement;
			      print_logfile('The following GLT table is purged ' || l_table_owner||'.XLA_GLT_'||glt_rec.group_id);
   			    END IF;
   			   EXCEPTION
   			     WHEN OTHERS THEN
 			     print_logfile('The following GLT table could not be purged ' || l_table_owner||'.XLA_GLT_'||glt_rec.group_id);
                             print_logfile('Reason for not purging the above table is: ' || SQLCODE || SQLERRM);
       	                     p_retcode             := 1;
 		 END;
		END LOOP;

	END LOOP;


		IF p_retcode = 0 AND l_rec_count > 0 THEN
		    print_logfile('All the GLT tables have been purged successfully for end date ' || to_char(l_end_date,'DD-MON-YYYY')  || ' for ledger: '  || l_ledger_name );
		    p_errbuf              := 'Purge GLT Program completed Normal';
		ELSIF p_retcode = 0 AND l_rec_count = 0 THEN
   		    print_logfile('No GLT tables purged for end date ' || to_char(l_end_date,'DD-MON-YYYY')  || ' for ledger: '  || l_ledger_name );
		    p_errbuf              := 'Purge GLT Program completed Normal';
		ELSIF p_retcode = 1 THEN
		    print_logfile('Purge GLT Program completed with some GLT tables not being purged for end date ' || to_char(l_end_date,'DD-MON-YYYY')  || ' for ledger: '  || l_ledger_name );
  		    p_errbuf              := 'Purge GLT Program completed with some GLT tables not being purged ';
		END IF;

	ELSE
	      p_retcode :=  2;
	      p_errbuf  := 'The Ledger selected is not a Primary Ledger_id. Please run the concurrent program with a Primary Ledger';
	      print_logfile('The Ledger selected is not a Primary Ledger_id. Please run the concurrent program with a Primary Ledger' );

	END IF;

EXCEPTION
 WHEN OTHERS THEN
  p_errbuf  := substr(SQLERRM,1,100);
  p_retcode :=  2;
  print_logfile(sqlerrm);

END drop_glt;


END XLA_PURGE_PKG;

/
