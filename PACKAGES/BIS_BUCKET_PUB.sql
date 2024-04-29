--------------------------------------------------------
--  DDL for Package BIS_BUCKET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BUCKET_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPBKTS.pls 115.5 2004/02/15 21:54:59 ankgoel noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_BUCKET_PUB';

TYPE BIS_BUCKET_REC_TYPE IS RECORD (
  bucket_id            	BIS_BUCKET.bucket_id%TYPE
 ,short_name		BIS_BUCKET.short_name%TYPE
 ,name		  	BIS_BUCKET_TL.name%TYPE
 ,type			BIS_BUCKET.type%TYPE
 ,application_id	BIS_BUCKET.application_id%TYPE
 ,range1_name		BIS_BUCKET_TL.range1_name%TYPE
 ,range1_low		BIS_BUCKET.range1_low%TYPE
 ,range1_high    	BIS_BUCKET.range1_high%TYPE
 ,range2_name		BIS_BUCKET_TL.range2_name%TYPE
 ,range2_low		BIS_BUCKET.range2_low%TYPE
 ,range2_high    	BIS_BUCKET.range2_high%TYPE
 ,range3_name		BIS_BUCKET_TL.range3_name%TYPE
 ,range3_low		BIS_BUCKET.range3_low%TYPE
 ,range3_high    	BIS_BUCKET.range3_high%TYPE
 ,range4_name		BIS_BUCKET_TL.range4_name%TYPE
 ,range4_low		BIS_BUCKET.range4_low%TYPE
 ,range4_high    	BIS_BUCKET.range4_high%TYPE
 ,range5_name		BIS_BUCKET_TL.range5_name%TYPE
 ,range5_low		BIS_BUCKET.range5_low%TYPE
 ,range5_high    	BIS_BUCKET.range5_high%TYPE
 ,range6_name		BIS_BUCKET_TL.range6_name%TYPE
 ,range6_low		BIS_BUCKET.range6_low%TYPE
 ,range6_high    	BIS_BUCKET.range6_high%TYPE
 ,range7_name		BIS_BUCKET_TL.range7_name%TYPE
 ,range7_low		BIS_BUCKET.range7_low%TYPE
 ,range7_high    	BIS_BUCKET.range7_high%TYPE
 ,range8_name		BIS_BUCKET_TL.range8_name%TYPE
 ,range8_low		BIS_BUCKET.range8_low%TYPE
 ,range8_high    	BIS_BUCKET.range8_high%TYPE
 ,range9_name		BIS_BUCKET_TL.range9_name%TYPE
 ,range9_low		BIS_BUCKET.range9_low%TYPE
 ,range9_high    	BIS_BUCKET.range9_high%TYPE
 ,range10_name		BIS_BUCKET_TL.range10_name%TYPE
 ,range10_low		BIS_BUCKET.range10_low%TYPE
 ,range10_high    	BIS_BUCKET.range10_high%TYPE
 ,customized		BIS_BUCKET_CUSTOMIZATIONS.customized%TYPE
 ,description		BIS_BUCKET_TL.description%TYPE
 ,updatable         BIS_BUCKET.updatable%TYPE:='F'
 ,expandable        BIS_BUCKET.expandable%TYPE:='F'
 ,discontinuous     BIS_BUCKET.discontinuous%TYPE:='F'
 ,overlapping       BIS_BUCKET.overlapping%TYPE:='F'
 ,uom               BIS_BUCKET.uom%TYPE
);


--This API should call BIS_BUCKET_PVT.CREATE_BIS_BUCKET
PROCEDURE CREATE_BIS_BUCKET (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--This API should call BIS_BUCKET_PVT.UPDATE_BIS_BUCKET
PROCEDURE UPDATE_BIS_BUCKET (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--This API should call BIS_BUCKET_PVT.DELETE_BIS_BUCKET
PROCEDURE DELETE_BIS_BUCKET (
  p_bucket_id   	IN BIS_BUCKET.bucket_id%TYPE	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_short_name		IN BIS_BUCKET.short_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_return_status      	OUT NOCOPY VARCHAR2
 ,x_error_tbl     	OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


--This API should call BIS_BUCKET_PVT.RETRIEVE _BIS_BUCKET
PROCEDURE RETRIEVE_BIS_BUCKET (
  p_short_name		IN BIS_BUCKET.short_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_bis_bucket_rec	OUT NOCOPY BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status      	OUT NOCOPY VARCHAR2
 ,x_error_tbl          	OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
-- This API is called from LCT file
--=============================================================================
PROCEDURE LOAD_BIS_BUCKET (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status      	OUT NOCOPY VARCHAR2
 ,x_error_tbl          	OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--=============================================================================

PROCEDURE ADD_LANGUAGE;

END BIS_BUCKET_PUB;

 

/
