--------------------------------------------------------
--  DDL for Package Body GMF_FND_GET_SEGMENT_DTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_FND_GET_SEGMENT_DTL" AS
/* $Header: gmfsegdb.pls 115.2 2002/11/11 00:42:07 rseshadr Exp $ */
                  CURSOR cur_get_segment_dtl (  sobname      varchar2,
                                                segmentname  varchar2,
                                                segmentnum   number,
                                                segmentattr_type varchar2,
                                                attributevalue varchar2 ) IS
      SELECT FND.segment_name,
             FND.segment_num,
        ATT.segment_attribute_type,
        ATT.attribute_value
        FROM fnd_id_flex_segments FND,
             gl_sets_of_books     GLS,
        fnd_segment_attribute_values ATT
       WHERE GLS.name                 =  NVL(sobname,GLS.name)
         AND GLS.chart_of_accounts_id = FND.id_flex_num
         AND LOWER(FND.segment_name)  = LOWER(NVL(segmentname,FND.segment_name))         AND FND.segment_num          = NVL(segmentnum, FND.segment_num)
         AND FND.enabled_flag         = 'Y'
         AND ATT.APPLICATION_ID       = FND.APPLICATION_ID
         AND ATT.ID_FLEX_CODE         = FND.ID_FLEX_CODE
         AND ATT.ID_FLEX_NUM          = FND.ID_FLEX_NUM
         AND ATT.APPLICATION_COLUMN_NAME = FND.APPLICATION_COLUMN_NAME
         AND ATT.SEGMENT_ATTRIBUTE_TYPE =  NVL(segmentattr_type,ATT.SEGMENT_ATTRIBUTE_TYPE )
         AND ATT.ATTRIBUTE_VALUE = NVL(attributevalue,ATT.ATTRIBUTE_VALUE);

PROCEDURE proc_get_segment_dtl(sobname          IN     varchar2,
                                    segmentname      IN OUT NOCOPY varchar2,
                                    segmentnum       IN OUT NOCOPY number,
                                    segmentattr_type IN OUT NOCOPY varchar2,
                                    attributevalue   IN OUT NOCOPY varchar2,
                                    row_to_fetch     IN     number,
                                    statuscode          OUT NOCOPY number) AS
     BEGIN
        IF  NOT cur_get_segment_dtl%ISOPEN THEN
            OPEN cur_get_segment_dtl(   sobname,
                                        segmentname,
                                        segmentnum,
                                        segmentattr_type,
                                        attributevalue);
        END IF;

            FETCH cur_get_segment_dtl
                  INTO segmentname,
                  segmentnum,
                  segmentattr_type,
                  attributevalue;

            IF cur_get_segment_dtl%NOTFOUND THEN
                   statuscode := 100;
                CLOSE cur_get_segment_dtl;
            END IF;

                  IF row_to_fetch = 1 AND cur_get_segment_dtl%ISOPEN THEN
                        CLOSE cur_get_segment_dtl;
                   END IF;

        EXCEPTION
                    WHEN OTHERS THEN
                    statuscode := SQLCODE;
        END;
END GMF_FND_GET_SEGMENT_DTL;

/
