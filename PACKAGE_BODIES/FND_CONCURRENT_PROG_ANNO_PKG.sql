--------------------------------------------------------
--  DDL for Package Body FND_CONCURRENT_PROG_ANNO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONCURRENT_PROG_ANNO_PKG" as
/* $Header: AFCPANTB.pls 120.1 2005/07/02 03:58:27 appldev noship $ */

FUNCTION GET_ANNOTATION(X_APPLICATION_ID NUMBER, X_CONCURRENT_PROGRAM_ID NUMBER) RETURN VARCHAR2 as
  anno_text varchar2(32100);
  anno_text1 varchar2(32100);
  start_index number := 1;
  download_size  number := 4000;
  lcount number ;
BEGIN
  anno_text := '';
  lcount := 1;

  LOOP

    select dbms_lob.substr(PROGRAM_ANNOTATION,download_size,start_index ) into anno_text1
    from FND_CONC_PROG_ANNOTATIONS where CONCURRENT_PROGRAM_ID=X_CONCURRENT_PROGRAM_ID AND
    APPLICATION_ID=X_APPLICATION_ID ;

    start_index := start_index+download_size;

    lcount := lcount + 1;

    anno_text := anno_text || anno_text1;

    EXIT WHEN lcount > 8;

  END LOOP;

  RETURN anno_text;
END GET_ANNOTATION;

end FND_CONCURRENT_PROG_ANNO_PKG;

/
