--------------------------------------------------------
--  DDL for Package Body GMF_FND_GET_SEGMENT_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_FND_GET_SEGMENT_VAL" AS
/* $Header: gmfseglb.pls 115.6 2002/11/11 00:42:27 rseshadr ship $ */

    --
    -- removed gl_stat_account_uom table from the cursor Bug 1837544
    --
    CURSOR cur_get_segment_val ( startdate    date,
                                 enddate      date,
                                 sobname      varchar2,
                                 segmentname  varchar2,
                                 segmentnum   number,
                                 segmentval   varchar2,
                                 segmentdesc  varchar2,
                                 segmentuom   varchar2) IS
 SELECT VAL.start_date_active,
        VAL.end_date_active,
        FND.segment_name,
        FND.segment_num,
        VAL.flex_value,
        VAL.description,
	GLS.chart_of_accounts_id
   FROM fnd_id_flex_segments FND,
        gl_sets_of_books     GLS,
        fnd_flex_values_vl   VAL
  WHERE GLS.name                 =  NVL(sobname,GLS.name)
    AND GLS.chart_of_accounts_id = FND.id_flex_num
    AND LOWER(FND.segment_name)  = LOWER(NVL(segmentname,FND.segment_name))
    AND FND.segment_num          = NVL(segmentnum, FND.segment_num)
    AND FND.enabled_flag         = 'Y'
    AND FND.flex_value_set_id    = VAL.flex_value_set_id
    AND VAL.enabled_flag         = 'Y'
    AND NVL(VAL.start_date_active,SYSDATE)    <= NVL(startdate, SYSDATE)
    AND NVL(VAL.end_date_active,SYSDATE)      >= NVL(enddate,   SYSDATE)
    AND VAL.flex_value           = NVL(segmentval, VAL.flex_value)
    AND NVL(VAL.description,' ') = NVL(segmentdesc, NVL(VAL.description,' '))
    --AND VAL.flex_value           = GLU.ACCOUNT_SEGMENT_VALUE(+)
    --AND nvl(GLU.chart_of_accounts_id, GLS.chart_of_accounts_id) = GLS.chart_of_accounts_id -- Bug# 1837544
    AND VAL.summary_flag = 'N'
ORDER BY FND.segment_name,
         FND.segment_num,
         VAL.flex_value;

PROCEDURE proc_get_segment_val( startdate    IN OUT NOCOPY date,
                                enddate      IN OUT NOCOPY date,
                                sobname      IN     varchar2,
                                segmentname  IN OUT NOCOPY varchar2,
                                segmentnum   IN OUT NOCOPY number,
                                segmentval   IN OUT NOCOPY varchar2,
                                segmentdesc  IN OUT NOCOPY varchar2,
                                row_to_fetch IN     number,
                                statuscode      OUT NOCOPY number,
                                segmentuom   IN OUT NOCOPY varchar2 ) as


 -- Bug# 1837544 : Added following cursor and variable

 CURSOR cur_get_uom(acct_seg_val         VARCHAR2,
		     chart_of_accts_id    NUMBER)
 IS
 SELECT unit_of_measure
   FROM gl_stat_account_uom
  WHERE account_segment_value = acct_seg_val
    AND chart_of_accounts_id  = chart_of_accts_id ;

 l_chart_of_accounts_id		gl_sets_of_books.chart_of_accounts_id%TYPE ;

BEGIN
     IF  NOT cur_get_segment_val%ISOPEN THEN
         OPEN cur_get_segment_val(startdate,
                                  enddate,
                                  sobname,
                                  segmentname,
                                  segmentnum,
                                  segmentval,
                                  segmentdesc,
                                  segmentuom );
     END IF;

     FETCH cur_get_segment_val
      INTO startdate,
           enddate,
           segmentname,
           segmentnum,
           segmentval,
           segmentdesc,
           --segmentuom;  -- Bug# 1837544
           l_chart_of_accounts_id ;

     IF cur_get_segment_val%NOTFOUND THEN
            statuscode := 100;
        CLOSE cur_get_segment_val;
     END IF;

     IF row_to_fetch = 1 AND cur_get_segment_val%ISOPEN THEN
         CLOSE cur_get_segment_val;
     END IF;

     /* Begin Bug# 1837544 */

     IF NOT cur_get_uom%ISOPEN THEN
     	OPEN cur_get_uom( segmentval, l_chart_of_accounts_id) ;
     END IF;

     FETCH cur_get_uom INTO segmentuom ;

     IF cur_get_uom%NOTFOUND THEN
	segmentuom := '' ;
        CLOSE cur_get_uom;
     END IF ;

     IF cur_get_uom%ISOPEN THEN
	CLOSE cur_get_uom;
     END IF ;

     /* End Bug# 1837544 */

 EXCEPTION
             WHEN OTHERS THEN
             statuscode := SQLCODE;
 END;
END GMF_FND_GET_SEGMENT_VAL;

/
