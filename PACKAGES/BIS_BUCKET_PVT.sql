--------------------------------------------------------
--  DDL for Package BIS_BUCKET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BUCKET_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVBKTS.pls 120.0 2005/06/01 16:45:00 appldev noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_BUCKET_PVT';

c_bucket_att CONSTANT VARCHAR2(20) := 'BUCKET_MEASURE';

--Record type added for validation
TYPE BIS_BUCKET_RANGES_REC IS RECORD(
  RANGE_NAME        BIS_BUCKET_TL.range1_name%TYPE
 ,RANGE_LOW         BIS_BUCKET.range1_low%TYPE
 ,RANGE_HIGH        BIS_BUCKET.range1_high%TYPE
);

TYPE BIS_BUCKET_RANGES_TBL IS TABLE OF BIS_BUCKET_RANGES_REC INDEX BY BINARY_INTEGER;

TYPE RangeLabels IS   VARRAY(20) OF BIS_BUCKET_CUSTOMIZATIONS_TL.range1_name%TYPE;

--Called by Java API
--It should take all the data passed to it and builds a record of type BIS_BUCKET_REC_TYPE
--and call BIS_BUCKET_PVT. CREATE_BIS_BUCKET with it.
PROCEDURE CREATE_BIS_BUCKET_WRAPPER (
  p_short_name		IN BIS_BUCKET.short_name%TYPE
 ,p_name		IN BIS_BUCKET_TL.name%TYPE
 ,p_type		IN BIS_BUCKET.type%TYPE
 ,p_application_id	IN BIS_BUCKET.application_id%TYPE
 ,p_range1_name		IN BIS_BUCKET_TL.range1_name%TYPE
 ,p_range1_low		IN BIS_BUCKET.range1_low%TYPE
 ,p_range1_high    	IN BIS_BUCKET.range1_high%TYPE
 ,p_range2_name		IN BIS_BUCKET_TL.range2_name%TYPE
 ,p_range2_low		IN BIS_BUCKET.range2_low%TYPE
 ,p_range2_high    	IN BIS_BUCKET.range2_high%TYPE
 ,p_range3_name		IN BIS_BUCKET_TL.range3_name%TYPE
 ,p_range3_low		IN BIS_BUCKET.range3_low%TYPE
 ,p_range3_high    	IN BIS_BUCKET.range3_high%TYPE
 ,p_range4_name		IN BIS_BUCKET_TL.range4_name%TYPE
 ,p_range4_low		IN BIS_BUCKET.range4_low%TYPE
 ,p_range4_high    	IN BIS_BUCKET.range4_high%TYPE
 ,p_range5_name		IN BIS_BUCKET_TL.range5_name%TYPE
 ,p_range5_low		IN BIS_BUCKET.range5_low%TYPE
 ,p_range5_high    	IN BIS_BUCKET.range5_high%TYPE
 ,p_range6_name		IN BIS_BUCKET_TL.range6_name%TYPE
 ,p_range6_low		IN BIS_BUCKET.range6_low%TYPE
 ,p_range6_high    	IN BIS_BUCKET.range6_high%TYPE
 ,p_range7_name		IN BIS_BUCKET_TL.range7_name%TYPE
 ,p_range7_low		IN BIS_BUCKET.range7_low%TYPE
 ,p_range7_high    	IN BIS_BUCKET.range7_high%TYPE
 ,p_range8_name		IN BIS_BUCKET_TL.range8_name%TYPE
 ,p_range8_low		IN BIS_BUCKET.range8_low%TYPE
 ,p_range8_high    	IN BIS_BUCKET.range8_high%TYPE
 ,p_range9_name		IN BIS_BUCKET_TL.range9_name%TYPE
 ,p_range9_low		IN BIS_BUCKET.range9_low%TYPE
 ,p_range9_high    	IN BIS_BUCKET.range9_high%TYPE
 ,p_range10_name	IN BIS_BUCKET_TL.range10_name%TYPE
 ,p_range10_low		IN BIS_BUCKET.range10_low%TYPE
 ,p_range10_high    IN BIS_BUCKET.range10_high%TYPE
 ,p_description		IN BIS_BUCKET_TL.description%TYPE
 ,p_updatable		IN BIS_BUCKET.updatable%TYPE := 'F'
 ,p_expandable		IN BIS_BUCKET.expandable%TYPE := 'F'
 ,p_discontinuous	IN BIS_BUCKET.discontinuous%TYPE := 'F'
 ,p_overlapping		IN BIS_BUCKET.overlapping%TYPE := 'F'
 ,p_uom		        IN BIS_BUCKET.uom%TYPE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_msg           OUT NOCOPY VARCHAR2
);


--Called by Java API
--It should take all the data passed to it and builds a record of type BIS_BUCKET_REC_TYPE
--and call BIS_BUCKET_PVT. UPDATE_BIS_BUCKET with it.
PROCEDURE UPDATE_BIS_BUCKET_WRAPPER (
  p_bucket_id           IN BIS_BUCKET.bucket_id%TYPE		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_short_name		IN BIS_BUCKET.short_name%TYPE		:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_name		IN BIS_BUCKET_TL.name%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_type		IN BIS_BUCKET.type%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_application_id	IN BIS_BUCKET.application_id%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range1_name		IN BIS_BUCKET_TL.range1_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_range1_low		IN BIS_BUCKET.range1_low%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range1_high    	IN BIS_BUCKET.range1_high%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range2_name		IN BIS_BUCKET_TL.range2_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_range2_low		IN BIS_BUCKET.range2_low%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range2_high    	IN BIS_BUCKET.range2_high%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range3_name		IN BIS_BUCKET_TL.range3_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_range3_low		IN BIS_BUCKET.range3_low%TYPE		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range3_high    	IN BIS_BUCKET.range3_high%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range4_name		IN BIS_BUCKET_TL.range4_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_range4_low		IN BIS_BUCKET.range4_low%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range4_high    	IN BIS_BUCKET.range4_high%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range5_name		IN BIS_BUCKET_TL.range5_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_range5_low		IN BIS_BUCKET.range5_low%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range5_high    	IN BIS_BUCKET.range5_high%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range6_name		IN BIS_BUCKET_TL.range6_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_range6_low		IN BIS_BUCKET.range6_low%TYPE		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range6_high    	IN BIS_BUCKET.range6_high%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range7_name		IN BIS_BUCKET_TL.range7_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_range7_low		IN BIS_BUCKET.range7_low%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range7_high    	IN BIS_BUCKET.range7_high%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range8_name		IN BIS_BUCKET_TL.range8_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_range8_low		IN BIS_BUCKET.range8_low%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range8_high    	IN BIS_BUCKET.range8_high%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range9_name		IN BIS_BUCKET_TL.range9_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_range9_low		IN BIS_BUCKET.range9_low%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range9_high    	IN BIS_BUCKET.range9_high%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range10_name	IN BIS_BUCKET_TL.range10_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_range10_low		IN BIS_BUCKET.range10_low%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_range10_high    	IN BIS_BUCKET.range10_high%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_description		IN BIS_BUCKET_TL.description%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,p_updatable		IN BIS_BUCKET.updatable%TYPE := 'F'
 ,p_expandable		IN BIS_BUCKET.expandable%TYPE := 'F'
 ,p_discontinuous	IN BIS_BUCKET.discontinuous%TYPE := 'F'
 ,p_overlapping		IN BIS_BUCKET.overlapping%TYPE := 'F'
 ,p_uom		        IN BIS_BUCKET.uom%TYPE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_msg           OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_CUST_BUCKET (
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE
, p_id                 IN  BIS_BUCKET_CUSTOMIZATIONS.id%TYPE
, p_bucket_id          IN  BIS_BUCKET_CUSTOMIZATIONS.bucket_id%TYPE
, p_user_id            IN  BIS_BUCKET_CUSTOMIZATIONS.user_id%TYPE
, p_responsibility_id  IN  BIS_BUCKET_CUSTOMIZATIONS.responsibility_id%TYPE
, p_application_id     IN  BIS_BUCKET_CUSTOMIZATIONS.application_id%TYPE
, p_org_id             IN  BIS_BUCKET_CUSTOMIZATIONS.org_id%TYPE
, p_site_id            IN  BIS_BUCKET_CUSTOMIZATIONS.site_id%TYPE
, p_page_id            IN  BIS_BUCKET_CUSTOMIZATIONS.page_id%TYPE
, p_function_id        IN  BIS_BUCKET_CUSTOMIZATIONS.function_id%TYPE
, p_range1_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range1_low%TYPE
, p_range1_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range1_high%TYPE
, p_range2_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range2_low%TYPE
, p_range2_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range2_high%TYPE
, p_range3_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range3_low%TYPE
, p_range3_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range3_high%TYPE
, p_range4_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range4_low%TYPE
, p_range4_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range4_high%TYPE
, p_range5_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range5_low%TYPE
, p_range5_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range5_high%TYPE
, p_range6_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range6_low%TYPE
, p_range6_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range6_high%TYPE
, p_range7_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range7_low%TYPE
, p_range7_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range7_high%TYPE
, p_range8_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range8_low%TYPE
, p_range8_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range8_high%TYPE
, p_range9_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range9_low%TYPE
, p_range9_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range9_high%TYPE
, p_range10_low        IN  BIS_BUCKET_CUSTOMIZATIONS.range10_low%TYPE
, p_range10_high       IN  BIS_BUCKET_CUSTOMIZATIONS.range10_high%TYPE
, p_range1_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range1_name%TYPE
, p_range2_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range2_name%TYPE
, p_range3_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range3_name%TYPE
, p_range4_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range4_name%TYPE
, p_range5_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range5_name%TYPE
, p_range6_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range6_name%TYPE
, p_range7_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range7_name%TYPE
, p_range8_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range8_name%TYPE
, p_range9_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range9_name%TYPE
, p_range10_name       IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range10_name%TYPE
, p_customized         IN  BIS_BUCKET_CUSTOMIZATIONS.customized%TYPE
, p_deleted_ranges     IN  VARCHAR2
, p_new_ranges         IN  VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE reset_bucket (
 p_bucket_id  IN  NUMBER
);

--Called by Java API
--It should call BIS_BUCKET_PVT. RETRIEVE _BIS_BUCKET with the short name
--and using the record of type BIS_BUCKET_REC_TYPE data obtained from that procedure,
--it should populates the out parameters
PROCEDURE RETRIEVE_BIS_BUCKET_WRAPPER (
  p_short_name		IN BIS_BUCKET.short_name%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_bucket_id           OUT NOCOPY BIS_BUCKET.bucket_id%TYPE
 ,x_name		OUT NOCOPY BIS_BUCKET_TL.name%TYPE
 ,x_type		OUT NOCOPY BIS_BUCKET.type%TYPE
 ,x_application_id	OUT NOCOPY BIS_BUCKET.application_id%TYPE
 ,x_range1_name		OUT NOCOPY BIS_BUCKET_TL.range1_name%TYPE
 ,x_range1_low		OUT NOCOPY BIS_BUCKET.range1_low%TYPE
 ,x_range1_high    	OUT NOCOPY BIS_BUCKET.range1_high%TYPE
 ,x_range2_name		OUT NOCOPY BIS_BUCKET_TL.range2_name%TYPE
 ,x_range2_low		OUT NOCOPY BIS_BUCKET.range2_low%TYPE
 ,x_range2_high    	OUT NOCOPY BIS_BUCKET.range2_high%TYPE
 ,x_range3_name		OUT NOCOPY BIS_BUCKET_TL.range3_name%TYPE
 ,x_range3_low		OUT NOCOPY BIS_BUCKET.range3_low%TYPE
 ,x_range3_high    	OUT NOCOPY BIS_BUCKET.range3_high%TYPE
 ,x_range4_name		OUT NOCOPY BIS_BUCKET_TL.range4_name%TYPE
 ,x_range4_low		OUT NOCOPY BIS_BUCKET.range4_low%TYPE
 ,x_range4_high    	OUT NOCOPY BIS_BUCKET.range4_high%TYPE
 ,x_range5_name		OUT NOCOPY BIS_BUCKET_TL.range5_name%TYPE
 ,x_range5_low		OUT NOCOPY BIS_BUCKET.range5_low%TYPE
 ,x_range5_high    	OUT NOCOPY BIS_BUCKET.range5_high%TYPE
 ,x_range6_name		OUT NOCOPY BIS_BUCKET_TL.range6_name%TYPE
 ,x_range6_low		OUT NOCOPY BIS_BUCKET.range6_low%TYPE
 ,x_range6_high    	OUT NOCOPY BIS_BUCKET.range6_high%TYPE
 ,x_range7_name		OUT NOCOPY BIS_BUCKET_TL.range7_name%TYPE
 ,x_range7_low		OUT NOCOPY BIS_BUCKET.range7_low%TYPE
 ,x_range7_high    	OUT NOCOPY BIS_BUCKET.range7_high%TYPE
 ,x_range8_name		OUT NOCOPY BIS_BUCKET_TL.range8_name%TYPE
 ,x_range8_low		OUT NOCOPY BIS_BUCKET.range8_low%TYPE
 ,x_range8_high    	OUT NOCOPY BIS_BUCKET.range8_high%TYPE
 ,x_range9_name		OUT NOCOPY BIS_BUCKET_TL.range9_name%TYPE
 ,x_range9_low		OUT NOCOPY BIS_BUCKET.range9_low%TYPE
 ,x_range9_high    	OUT NOCOPY BIS_BUCKET.range9_high%TYPE
 ,x_range10_name	OUT NOCOPY BIS_BUCKET_TL.range10_name%TYPE
 ,x_range10_low		OUT NOCOPY BIS_BUCKET.range10_low%TYPE
 ,x_range10_high    	OUT NOCOPY BIS_BUCKET.range10_high%TYPE
 ,x_description		OUT NOCOPY BIS_BUCKET_TL.description%TYPE
 ,x_updatable		OUT NOCOPY BIS_BUCKET.updatable%TYPE
 ,x_expandable		OUT NOCOPY BIS_BUCKET.expandable%TYPE
 ,x_discontinuous	OUT NOCOPY BIS_BUCKET.discontinuous%TYPE
 ,x_overlapping		OUT NOCOPY BIS_BUCKET.overlapping%TYPE
 ,x_uom		        OUT NOCOPY BIS_BUCKET.uom%TYPE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_msg           OUT NOCOPY VARCHAR2
);


PROCEDURE DELETE_BIS_BUCKET_WRAPPER (
  p_bucket_id   	IN BIS_BUCKET.bucket_id%TYPE	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_short_name		IN BIS_BUCKET.short_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_return_status      	OUT NOCOPY VARCHAR2
 ,x_error_msg           OUT NOCOPY VARCHAR2
);

--This API should generate the bucket_id in sequence and insert the data passed to it,
--into the tables BIS_BUCKET, BIS_BUCKET_TL and BIS_BUCKET_TYPE
PROCEDURE CREATE_BIS_BUCKET (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


--This API should update the tables BIS_BUCKET, BIS_BUCKET_TL and BIS_BUCKET_TYPE
--using the short name or the bucket id as the where clause value
PROCEDURE UPDATE_BIS_BUCKET (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


--This API should delete a row from the tables BIS_BUCKET and BIS_BUCKET_TL
--using the short name or the bucket id as the where clause value
PROCEDURE DELETE_BIS_BUCKET (
  p_bucket_id   	IN BIS_BUCKET.bucket_id%TYPE		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_short_name		IN BIS_BUCKET.short_name%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


--This API should populate a record of type bis_bucket_rec_type based on the bucket short name
PROCEDURE RETRIEVE_BIS_BUCKET (
  p_short_name		IN BIS_BUCKET.short_name%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_bis_bucket_rec	OUT NOCOPY BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE TRANSLATE_BUCKET (
  p_bis_bucket_rec	IN  BIS_BUCKET_PUB.bis_bucket_rec_type
 ,p_owner		IN  VARCHAR2
 ,x_return_status	OUT NOCOPY VARCHAR2
 ,x_error_Tbl		OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--=============================================================================
FUNCTION IS_BUCKET_TYPE_EXISTS (
  p_bucket_type IN VARCHAR2
) RETURN BOOLEAN;
--=============================================================================
PROCEDURE Validate_Bucket (
   p_bis_bucket_rec IN BIS_BUCKET_PUB.bis_bucket_rec_type
  ,x_return_status OUT NOCOPY VARCHAR2
  ,x_error_Tbl OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--=============================================================================

--=============================================================================
--API for returning the report lists that using the specified bucket.
--=============================================================================
FUNCTION GET_REPORT_LISTS (
   p_bucket_short_name  IN VARCHAR2 DEFAULT NULL
   ,p_bucket_id  IN NUMBER DEFAULT NULL
) return VARCHAR2;

--=============================================================================
--API for populating the table of records with low and high range values
--Needed for range validations -- overlappig and discontinous.
--=============================================================================
PROCEDURE Populate_Loc_Bucket_Range_Tbl
(
  p_bis_bucket_rec      IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_bucket_ranges_tbl   OUT NOCOPY BIS_BUCKET_PVT.bis_bucket_ranges_tbl
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


--=============================================================================
--API for validating the overlapping feature of the bucket
-- If it allows overlapping, no validation is needed.
-- Validation is only needed if it doesn't allow overlapping.
--=============================================================================
PROCEDURE Validate_Bucket_Overlapping (
  p_overlapping    IN  VARCHAR2
 ,p_bucket_ranges_tbl   IN BIS_BUCKET_PVT.bis_bucket_ranges_tbl
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_error_tbl      OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


--=============================================================================
--API for validating the discontinuous feature of the bucket
-- If it allows discontinuous, no validation is needed.
-- Validation is only needed if it doesn't allow discontinuous.
--=============================================================================
PROCEDURE Validate_Bucket_Discontinuous (
  p_discontinuous    IN  VARCHAR2
 ,p_bucket_ranges_tbl   IN BIS_BUCKET_PVT.bis_bucket_ranges_tbl
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_error_tbl      OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--=============================================================================
--API for validating that the FROM is always less than or equal to TO
--=============================================================================
PROCEDURE Validate_From_To (
  p_bucket_ranges_tbl   IN BIS_BUCKET_PVT.bis_bucket_ranges_tbl
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_error_tbl      OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE VALIDATE_BUCKET_WRAPPER (
  p_short_name		IN BIS_BUCKET.short_name%TYPE
 ,p_name		IN BIS_BUCKET_TL.name%TYPE
 ,p_type		IN BIS_BUCKET.type%TYPE
 ,p_application_id	IN BIS_BUCKET.application_id%TYPE
 ,p_range1_name		IN BIS_BUCKET_TL.range1_name%TYPE
 ,p_range1_low		IN BIS_BUCKET.range1_low%TYPE
 ,p_range1_high    	IN BIS_BUCKET.range1_high%TYPE
 ,p_range2_name		IN BIS_BUCKET_TL.range2_name%TYPE
 ,p_range2_low		IN BIS_BUCKET.range2_low%TYPE
 ,p_range2_high    	IN BIS_BUCKET.range2_high%TYPE
 ,p_range3_name		IN BIS_BUCKET_TL.range3_name%TYPE
 ,p_range3_low		IN BIS_BUCKET.range3_low%TYPE
 ,p_range3_high    	IN BIS_BUCKET.range3_high%TYPE
 ,p_range4_name		IN BIS_BUCKET_TL.range4_name%TYPE
 ,p_range4_low		IN BIS_BUCKET.range4_low%TYPE
 ,p_range4_high    	IN BIS_BUCKET.range4_high%TYPE
 ,p_range5_name		IN BIS_BUCKET_TL.range5_name%TYPE
 ,p_range5_low		IN BIS_BUCKET.range5_low%TYPE
 ,p_range5_high    	IN BIS_BUCKET.range5_high%TYPE
 ,p_range6_name		IN BIS_BUCKET_TL.range6_name%TYPE
 ,p_range6_low		IN BIS_BUCKET.range6_low%TYPE
 ,p_range6_high    	IN BIS_BUCKET.range6_high%TYPE
 ,p_range7_name		IN BIS_BUCKET_TL.range7_name%TYPE
 ,p_range7_low		IN BIS_BUCKET.range7_low%TYPE
 ,p_range7_high    	IN BIS_BUCKET.range7_high%TYPE
 ,p_range8_name		IN BIS_BUCKET_TL.range8_name%TYPE
 ,p_range8_low		IN BIS_BUCKET.range8_low%TYPE
 ,p_range8_high    	IN BIS_BUCKET.range8_high%TYPE
 ,p_range9_name		IN BIS_BUCKET_TL.range9_name%TYPE
 ,p_range9_low		IN BIS_BUCKET.range9_low%TYPE
 ,p_range9_high    	IN BIS_BUCKET.range9_high%TYPE
 ,p_range10_name	IN BIS_BUCKET_TL.range10_name%TYPE
 ,p_range10_low		IN BIS_BUCKET.range10_low%TYPE
 ,p_range10_high    IN BIS_BUCKET.range10_high%TYPE
 ,p_description		IN BIS_BUCKET_TL.description%TYPE
 ,p_updatable		IN BIS_BUCKET.updatable%TYPE := 'F'
 ,p_expandable		IN BIS_BUCKET.expandable%TYPE := 'F'
 ,p_discontinuous	IN BIS_BUCKET.discontinuous%TYPE := 'F'
 ,p_overlapping		IN BIS_BUCKET.overlapping%TYPE := 'F'
 ,p_uom		        IN BIS_BUCKET.uom%TYPE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_msg           OUT NOCOPY VARCHAR2
);

FUNCTION IS_VALID_APPLICATION_ID (
  p_application_id IN NUMBER
) RETURN BOOLEAN;

PROCEDURE Validate_Bucket_Common (
   p_bis_bucket_rec IN BIS_BUCKET_PUB.bis_bucket_rec_type
  ,x_return_status OUT NOCOPY VARCHAR2
  ,x_error_Tbl OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE ADD_LANGUAGE;

END BIS_BUCKET_PVT;

 

/
