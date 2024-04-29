--------------------------------------------------------
--  DDL for Package Body FWK_PORTLET_GEN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FWK_PORTLET_GEN_UTIL" as
/* $Header: fwkportgenutlb.pls 120.0.12010000.3 2009/07/22 17:55:28 gjimenez noship $ */
  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC METHODS ---------------------------------
  -----------------------------------------------------------------------------
  /* $Header: fwkportgenutlb.pls 120.0.12010000.3 2009/07/22 17:55:28 gjimenez noship $ */
  -- Return back the full Page Metadata.
  --
  -- Parameters:
  --  p_document    - the fully qualified document name, which can represent
  --                  either a document or package file.
  --                  (i.e.  '/oracle/apps/ak/attributeSets')
  --
  FUNCTION getPageMetaData(p_document in VARCHAR2) RETURN CLOB
  IS
    p_chunk       VARCHAR2(32000) DEFAULT '';
    full_document    CLOB DEFAULT '';
  BEGIN
    p_chunk := jdr_mds_internal.exportDocumentAsXML(p_document);
    full_document := p_chunk;
    IF p_chunk IS NULL THEN
      return full_document;
    ELSE
      LOOP
        p_chunk := jdr_mds_internal.exportDocumentAsXML(NULL);
        EXIT WHEN p_chunk IS NULL;
        full_document := full_document || p_chunk;
      END LOOP;
    END IF;
    return full_document;
  END;


  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC METHODS ---------------------------------
  -----------------------------------------------------------------------------

  -- Return Path Name for specific document ID.
  --
  -- Parameters:
  --  p_docid    - the fully qualified document id

  FUNCTION getPathName(p_docid in NUMBER) RETURN VARCHAR
  IS
    path_name    JDR_PATHS.PATH_NAME%TYPE;

    CURSOR c_pathName(docID JDR_PATHS.PATH_OWNER_DOCID%TYPE) IS
    SELECT path_name
    FROM JDR_PATHS
    WHERE path_owner_docid = 2
    CONNECT BY PRIOR PATH_OWNER_DOCID = PATH_DOCID
    START WITH PATH_DOCID = docID;


  BEGIN

    path_name := null;
    for x in c_pathName(p_docid) loop
      path_name := x.path_name;
    end loop;
    return path_name;

  END;


  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC METHODS ---------------------------------
  -----------------------------------------------------------------------------

  -- This is the concurrent program that will refresh the Materialized view.
  --
  -- Parameters:
  --  none

  PROCEDURE refresh_mview(errbuf    out nocopy varchar2,
                          retcode   out nocopy number)
  IS
	begin

	    fnd_file.put_line(fnd_file.log, 'Refreshing materialized view');
	    fnd_file.put_line(fnd_file.log, 'Start time : ' || to_char(sysdate, 'DD-MON-RR HH24:MI:SS'));

	    dbms_mview.refresh('FWK_PORTLET_GEN_MV');

	    fnd_file.put_line(fnd_file.log, 'Refresh successful.');
	    fnd_file.put_line(fnd_file.log, 'End time : ' || to_char(sysdate, 'DD-MON-RR HH24:MI:SS'));



	    errbuf := 'Portlet MV Refresh successful.';
	    retcode := 0;

	exception
	    when others then
		retcode := 2;
		errbuf := 'ERROR: ' || sqlerrm;

	end;



END FWK_PORTLET_GEN_UTIL;

/
