--------------------------------------------------------
--  DDL for Package Body GMF_FND_SEGMENT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_FND_SEGMENT_INFO" AS
/* $Header: gmfsegnb.pls 115.1 2002/11/11 00:42:49 rseshadr ship $ */
    CURSOR segment_info(  startdate date,
                  enddate date,
                  segmentname varchar2,
                  sobname varchar2) IS
      SELECT  fnd.segment_name, fnd.segment_num
      FROM fnd_id_flex_segments fnd,gl_sets_of_books gls
      WHERE    gls.name=sobname    AND
            gls.chart_of_accounts_id=fnd.id_flex_num  AND
            fnd.segment_name=nvl(segmentname,fnd.segment_name) AND
            fnd.creation_date  BETWEEN
            nvl(startdate,fnd.creation_date)  AND
            nvl(enddate,fnd.creation_date);
    PROCEDURE get_segment_info(  startdate in date,
                        enddate in date,
                        sobname in varchar2,
                        segmentname in out NOCOPY varchar2,
                        segmentnum out NOCOPY number,
                        statuscode out NOCOPY number) as
    Begin
      IF ((segmentname IS NOT NULL)  AND (NOT segment_info%ISOPEN)) THEN
        SELECT    fnd.segment_num
        INTO      segmentnum
        FROM     fnd_id_flex_segments fnd,
              gl_sets_of_books gls
        WHERE    gls.name=sobname
        AND     gls.chart_of_accounts_id=fnd.id_flex_num
        AND     fnd.segment_name=segmentname;

      ELSE
        IF  NOT segment_info%ISOPEN THEN
          OPEN segment_info(startdate,enddate,segmentname,sobname);
        END IF;
        FETCH   segment_info
        INTO     segmentname,
              segmentnum;
        IF segment_info%NOTFOUND THEN
          statuscode := 100;
          close segment_info;
        END IF;
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          statuscode := SQLCODE;
    End;
  END GMF_FND_SEGMENT_INFO;

/
