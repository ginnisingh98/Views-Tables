--------------------------------------------------------
--  DDL for Package BEN_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SUM" AUTHID CURRENT_USER AS
/* $Header: bensumfm.pkh 115.1 2003/02/12 10:30:40 rpgupta noship $ */
--
TYPE sum_rec IS RECORD (
ORDER_NUM1          ben_benefits_summary_v.ORDER_NUM1%TYPE
,ORDER_NUM2         ben_benefits_summary_v.ORDER_NUM2%TYPE
,ORDER_NUM3         ben_benefits_summary_v.ORDER_NUM3%TYPE
,NAME               ben_benefits_summary_v.NAME%TYPE
,ID                 ben_benefits_summary_v.ID%TYPE
,BUSINESS_GROUP_ID  ben_benefits_summary_v.BUSINESS_GROUP_ID%TYPE
,PERSON_ID          ben_benefits_summary_v.PERSON_ID%TYPE
,MEANING            ben_benefits_summary_v.MEANING%TYPE
,TYPE               ben_benefits_summary_v.TYPE%TYPE
,OBJECT_TYPE_CD     ben_benefits_summary_v.OBJECT_TYPE_CD%TYPE
);
--
TYPE sumtab IS TABLE OF sum_rec INDEX BY BINARY_INTEGER;
--
PROCEDURE sum_query
  (block_data  IN OUT NOCOPY sumtab
  ,p_person_id IN     NUMBER
  );
--
END ben_sum;

 

/
