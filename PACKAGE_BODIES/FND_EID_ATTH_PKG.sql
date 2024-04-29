--------------------------------------------------------
--  DDL for Package Body FND_EID_ATTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EID_ATTH_PKG" AS
--  $Header: fndeidatthb.pls 120.0.12010000.2 2012/07/17 07:22:12 rnagaraj noship $

/* This functions creates oracle text based preference and policy to filter binary
   documents stored in FND_LOBS table.
   Author :Ranjan Tripathy
   Created : 15th May 2012 */

FUNCTION return_text(p_id NUMBER,  p_html NUMBER DEFAULT 1)
        RETURN CLOB AS

  l_clob		CLOB;
  l_flag		BOOLEAN;

  CURSOR c1 IS
  SELECT *
    FROM fnd_lobs
   WHERE file_id=p_id;

BEGIN

  IF p_html = 1 THEN
    l_flag:=FALSE;
  ELSE
    l_flag:=TRUE;
  END IF;

  FOR v1 IN c1  LOOP
  BEGIN

    ctx_doc.policy_filter( 'endeca_policy', v1.file_data, l_clob, l_flag,v1.language,null,v1.oracle_charset);

    RETURN(l_clob);

  EXCEPTION WHEN OTHERS THEN  -- filter errors out so return null
    RETURN(l_clob);
  END;
  END LOOP;

  RETURN(l_clob);

  EXCEPTION WHEN OTHERS THEN
	-- everything errors out.Return null
    RETURN(l_clob);

END return_text;

END FND_EID_ATTH_PKG;

/
