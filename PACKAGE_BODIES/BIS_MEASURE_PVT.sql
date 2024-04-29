--------------------------------------------------------
--  DDL for Package Body BIS_MEASURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_MEASURE_PVT" AS
/* $Header: BISVMEAB.pls 120.3 2006/06/27 06:24:46 akoduri ship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVMEAS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating and managing Performance Measurements
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation
REM | 15-OCT-2001      MAHRAO            Fix for 1850860
REM | 26-JUL-2002 rchandra  Fixed for enh 2440739                           |
REM | 13-NOV-2002 SASHAIK  Fixed for bug 2664898
REM | 23-JAN-03 sugopal For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)                            |
REM | 30-JAN-03 sugopal FND_API.G_MISS_xxx should not be used in            |
REM |                   initialization or declaration (bug#2774644)         |
REM | 13-FEB-03 sashaik 2784713 Measure update fix.                         |
REM | 11-APR-03 sugopal Not possible to update an existing value with null  |
REM |           in the Create/Update performance measures page -    |
REM |           modified UpdateMeasureRec for bug#2869324       |
REM | 23-APR-03 mdamle  PMD - Measure Definer Support               |
REM | 18-JUN-03 mdamle  Fixed bug in Get_Measure_Id_From_Name           |
REM | 24-JUN-2003 rchandra  leap frog PMD Changes to verssion 115.68        |
REM | 24-JUN-2003 rchandra  leap frog 115.70 to support dataset_id which    |
REM |                       already has been coded  for bug 3004651         |
REM | 26-JUN-2003 rchandra  populated dataset_id into measure_rec in the    |
REM |                       API retrieve_measure    for bug 3004651         |
REM | 04-JUL-2003 arhegde bug# 2975949 If enable link is null, then insert/ |
REM |                       update 'N' instead                              |
REM | 14-JUL-2003 jxyu   Fixed for bug#3037200. Remove the additional check |
REM |                    in Delete_Measure() for PMD                        |
REM | 18-JUL-2003 mdamle Added check for duplicate name in update_measure   |
REM |                    Added check for enable_link                        |
REM |                    Added check for data source column                 |
REM | 01-Aug-2003 mdamle Bug#3055812 - Chk for duplicate name after trimming|
REM | 06-Aug-2003 mdamle Fixed isSourceColumnMappedAlready                  |
REM | 20-Aug-2003 mdamle Bug#3102928 - Added check for actual_data_source   |
REM | 10-SEP-2003 mahrao Added check for matching dimensions in update_measure|
REM |                    procedure which will be called when measure is     |
REM |                    uploaded through an ldt.                           |
REM | 25-SEP-2003 mdamle Bug#3160325 - Sync up measures for all installed   |
REM |                    languages                      |
REM | 29-SEP-2003 adrao  Bug#3160325 - Sync up measures for all installed   |
REM |                    source languages                                   |
REM | 12-NOV-2003 smargand  added new function to determine whether the     |
REM |                       given indicator is customized,                  |
REM |                       added enable column to the affected views,      |
REM | 24-FEB-04 KYADAMAK    Bug #3439942  space not allowed for PMF       |
REM |                              Measures                                 |
REM | 08-APR-04 ankgoel     Modified for bug#3557236			    |
REM | 27-MAY-04 ankgoel	    Modified for bug#3610655			    |
REM | 03-JUN-04 ankgoel    Modified for bug#3583357. Added procedure call   |
REM |                      for re-sequencing dimensions in                  |
REM |                      bis_indicator_dimensions using the dim level     |
REM |                      order in bis_target_levels.                      |
REM | 27-JUL-04 sawu       Resolved WHO column info based on p_owner        |
REM | 02-SEP-04 sawu  Bug#3859267: added isColumnMappedAlready(),           |
REM |                 isSourceColumnMappedAlready() and                     |
REM |                 isCompareColumnMappedAlready()                        |
REM | 13-SEP-04 sawu  Bug#3852077: added api IsDimensionUpdatable()         |
REM | 29-SEP-04 ankgoel   Added WHO columns in Rec for Bug#3891748          |
REM | 01-OCT-04 ankgoel   Bug#3922308 - The new and old set of dimensions   |
REM |                     for a measure should be exactly same. Reverted    |
REM |                     fix done for Bug#3852077. Also, got the dimensions|
REM |                     from existing measure record in case of re-order. |
REM | 20-Dec-04 sawu  Bug#4045278: Modified update_measure to populate      |
REM |                 last_update_date from l_Measure_Rec. Removed line     |
REM |                 that updated last_update_date in api                  |
REM |                 Translate_Measure_by_lang to preserve lud integrity.  |
REM |                 Overloaded create_measure() also.                     |
REM | 27-Dec-04 rpenneru  Bug#4080204: Modifed Create_Measure(),            |
REM |                  Update_Measure() to populate functional Area Name    |
REM |                  to Measure extensions if the measure is uploaded.    |
REM | 31-Jan-2005 rpenneru Modified for #4073262, BIS_MEASURES_EXTENSION_TL |
REM |             Name and Description should not be updated, if the measure|
REM |             is uploaded from BISPMFLD.lct                             |
REM | 09-FEB-04 skchoudh    Enh#4141738 Added Functiona Area Combobox to MD |
REM | 21-MAR-05 ankagarw   bug#4235732 - changing count(*) to count(1)      |
REM | 22-APR-2005 akoduri   Enhancement#3865711 -- Obsolete Seeded Objects  |
REM | 03-MAY-2005  akoduri  Enh #4268374 -- Weighted Average Measures       |
REM | 19-MAY-2005  visuri   GSCC Issues bug 4363854                         |
REM | 19-JUL-2005  rpenneru bug#4447273- bis_measures_extension is corrupted|
REM |              when the ldt file is not having the FA short name        |
REM | 20-SEP-2005  akoduri bug#4607348 - Obsoletion of measures is not      |
REM |              changing the last_update_date and last_updated_by        |
REM | 16-JUN-2006  akoduri bug#5286873 Error is not shown in data source    |
REM |              mapping page in non-US sessions                          |
REM +=======================================================================+
*/

--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_MEASURE_PVT';
--

PROCEDURE Update_Measure_Rec_Total -- 2664898
( p_Measure_Rec_orig  IN         BIS_MEASURE_PUB.Measure_Rec_Type
, p_Measure_Rec_new   IN         BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec       OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
);

PROCEDURE UpdateMeasureRecNoDim -- 2664898
( p_Measure_Rec  IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_Measure_Rec1 IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec  OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
);

PROCEDURE Update_Measure_Rec_Dims -- 2664898
( p_Measure_Rec_orig  IN         BIS_MEASURE_PUB.Measure_Rec_Type
, p_Measure_Rec_new   IN         BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec       OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
);

PROCEDURE GetOriginalDimensions -- 3922308
( p_Measure_Rec_Orig    IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_Measure_Rec         IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec_Overlap OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
);

FUNCTION get_dimension_ID  -- 2664898
( p_dim_id  IN NUMBER )
RETURN NUMBER;

PROCEDURE ArrangeDimensions   -- Added for 2784713
( p_Measure_Rec       IN         BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec       OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
);

FUNCTION return_value_if_not_missing -- 2784713
( p_number  IN NUMBER )
RETURN NUMBER;

FUNCTION return_value_if_not_missing -- 2784713
( p_varchar2  IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION isColumnMappedAlready(
  p_region_code         IN  Ak_Region_Items.REGION_CODE%TYPE
 ,p_region_app_id       IN  Ak_Region_Items.REGION_APPLICATION_ID%Type
 ,p_attribute_code      IN  Ak_Region_Items.ATTRIBUTE_CODE%Type
 ,p_attribute_app_id    IN  Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type
 ,x_measure_short_name  OUT NOCOPY Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE
 ,x_measure_name        OUT NOCOPY Bisbv_Performance_Measures.MEASURE_NAME%TYPE
) RETURN boolean;

FUNCTION isCompareColumnMappedAlready(
  p_Measure_rec             IN          BIS_MEASURE_PUB.MEASURE_REC_TYPE
 ,x_measure_name   OUT NOCOPY  Bisbv_Performance_Measures.MEASURE_NAME%TYPE
) RETURN boolean;

-- mdamle 07/18/2003 - Check if measure is being mapped to a source
-- that's already mapped to another measure.
FUNCTION isSourceColumnMappedAlready(
  p_Measure_rec           IN            BIS_MEASURE_PUB.MEASURE_REC_TYPE
 ,x_measure_name OUT NOCOPY    Bisbv_Performance_Measures.MEASURE_NAME%TYPE
) RETURN boolean;


-- rpenneru 12/27/2004 for enh#4080204
PROCEDURE Load_Measure_Extension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


FUNCTION Get_Measure_Id_From_Short_Name
( p_measure_rec IN  BIS_MEASURE_PUB.Measure_Rec_Type
) RETURN NUMBER
IS
-- mdamle 08/01/2003 - Chk for duplicate name after trimming
-- mdamle 08/04/2003 - Added case insensitive check
cursor short_name_cursor IS
select indicator_id
from bis_indicators
where short_name = p_measure_rec.Measure_Short_name;
l_dummy number;
BEGIN

  open short_name_cursor;
  fetch short_name_cursor into l_dummy;
  if (short_name_cursor%NOTFOUND) then
    close short_name_cursor;
    return NULL;
  end if;
  close short_name_cursor;

  return l_dummy;

--EXCEPTION
--  WHEN OTHERS THEN
--    NULL;

END Get_Measure_Id_From_Short_Name;
-- Fix for 2309894 starts here
FUNCTION Get_Measure_Id_From_Name
( p_measure_rec IN  BIS_MEASURE_PUB.Measure_Rec_Type
) RETURN NUMBER
IS
-- mdamle 07/18/2003 - Changed like to =
-- Values may have % sign in them
-- mdamle 08/01/2003 - Chk for duplicate name after trimming
-- mdamle 08/04/2003 - Added case insensitive check
cursor name_cursor IS
select indicator_id
from bis_indicators_vl
where name = p_measure_rec.Measure_name;

l_dummy number;
BEGIN

  open name_cursor;
  fetch name_cursor into l_dummy;
  if (name_cursor%NOTFOUND) then
    close name_cursor;
    return NULL;
  end if;
  close name_cursor;

  return l_dummy;

--EXCEPTION
--  WHEN OTHERS THEN
--    NULL;

END Get_Measure_Id_From_Name;
--

-- ankgoel: bug#3922308
-- Retrieves the original set of dimensions and populates the new measure rec
PROCEDURE GetOriginalDimensions (
  p_Measure_Rec_Orig    IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_Measure_Rec         IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec_Overlap OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
)
IS
BEGIN
  x_Measure_Rec_Overlap := p_Measure_Rec;

  x_Measure_Rec_Overlap.Dimension1_ID := return_value_if_not_missing
                                 ( p_number => p_Measure_Rec_Orig.Dimension1_ID );
  x_Measure_Rec_Overlap.Dimension1_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension1_Short_Name );
  x_Measure_Rec_Overlap.Dimension1_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension1_Name );

  x_Measure_Rec_Overlap.Dimension2_ID := return_value_if_not_missing
                                 ( p_number => p_Measure_Rec_Orig.Dimension2_ID );
  x_Measure_Rec_Overlap.Dimension2_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension2_Short_Name );
  x_Measure_Rec_Overlap.Dimension2_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension2_Name );

  x_Measure_Rec_Overlap.Dimension3_ID := return_value_if_not_missing
                                 ( p_number => p_Measure_Rec_Orig.Dimension3_ID );
  x_Measure_Rec_Overlap.Dimension3_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension3_Short_Name );
  x_Measure_Rec_Overlap.Dimension3_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension3_Name );

  x_Measure_Rec_Overlap.Dimension4_ID := return_value_if_not_missing
                                 ( p_number => p_Measure_Rec_Orig.Dimension4_ID );
  x_Measure_Rec_Overlap.Dimension4_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension4_Short_Name );
  x_Measure_Rec_Overlap.Dimension4_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension4_Name );

  x_Measure_Rec_Overlap.Dimension5_ID := return_value_if_not_missing
                                 ( p_number => p_Measure_Rec_Orig.Dimension5_ID );
  x_Measure_Rec_Overlap.Dimension5_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension5_Short_Name );
  x_Measure_Rec_Overlap.Dimension5_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension5_Name );

  x_Measure_Rec_Overlap.Dimension6_ID := return_value_if_not_missing
                                 ( p_number => p_Measure_Rec_Orig.Dimension6_ID );
  x_Measure_Rec_Overlap.Dimension6_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension6_Short_Name );
  x_Measure_Rec_Overlap.Dimension6_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension6_Name );

  x_Measure_Rec_Overlap.Dimension7_ID := return_value_if_not_missing
                                 ( p_number => p_Measure_Rec_Orig.Dimension7_ID );
  x_Measure_Rec_Overlap.Dimension7_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension7_Short_Name );
  x_Measure_Rec_Overlap.Dimension7_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_Measure_Rec_Orig.Dimension7_Name );
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END GetOriginalDimensions;
--

-- Fix for 2309894 ends here
Procedure Create_Indicator_Dimension
( p_Measure_id    number
, p_dimension_id  number
, p_sequence_no   number
, p_owner         IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
l_user_id         number;
l_login_id        number;
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if (BIS_UTILITIES_PUB.Value_Missing(p_dimension_id) = FND_API.G_TRUE) then
    return;
  end if;

  l_user_id := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);

  l_login_id := fnd_global.LOGIN_ID;

  insert into bis_indicator_dimensions
  (
    INDICATOR_ID
  , Dimension_ID
  , SEQUENCE_NO
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  )
  values
  ( p_Measure_ID
  , p_dimension_id
  , p_sequence_no
  , SYSDATE
  , l_user_id
  , SYSDATE
  , l_user_id
  , l_login_id
  );

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params

      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Indicator_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Create_Indicator_Dimension;

PROCEDURE Create_Indicator_Dimensions
( p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_id NUMBER := p_Measure_rec.Measure_Id;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE
     AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE) then

    Create_Indicator_Dimension( l_id
                              , p_Measure_Rec.Dimension1_Id
                              , 1
                              , p_owner
                              , x_return_status
                              , x_error_tbl
                              );

    if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension2_id)
                                                   = FND_API.G_FALSE
        AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension2_id)
                                                    = FND_API.G_FALSE) then

      Create_Indicator_Dimension( l_id
                                , p_Measure_Rec.Dimension2_Id
                                , 2
                                , p_owner
                                , x_return_status
                                , x_error_tbl
                                );

      if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension3_id)
                                                   = FND_API.G_FALSE
          AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension3_id)
                                  = FND_API.G_FALSE) then
        Create_Indicator_Dimension( l_id
                                  , p_Measure_Rec.Dimension3_Id
                                  , 3
                                  , p_owner
                                  , x_return_status
                                  , x_error_tbl
                                  );

        if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension4_id)
                                                   = FND_API.G_FALSE
             AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension4_id)
                            = FND_API.G_FALSE) then
          Create_Indicator_Dimension( l_id
                                    , p_Measure_Rec.Dimension4_Id
                                    , 4
                                    , p_owner
                                    , x_return_status
                                    , x_error_tbl
                                    );

          if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension5_id)
                                                   = FND_API.G_FALSE
              AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension5_id)
                            = FND_API.G_FALSE) then
             Create_Indicator_Dimension( l_id
                                       , p_Measure_Rec.Dimension5_Id
                                       , 5
                                       , p_owner
                                       , x_return_status
                                       , x_error_tbl
                                       );

            if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension6_id)
                                                   = FND_API.G_FALSE
                AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension6_id)
                            = FND_API.G_FALSE) then
               Create_Indicator_Dimension( l_id
                                         , p_Measure_Rec.Dimension6_Id
                                         , 6
                                         , p_owner
                                         , x_return_status
                                         , x_error_tbl
                                         );

              if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension7_id)
                                                   = FND_API.G_FALSE
                  AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension7_id)
                            = FND_API.G_FALSE) then
                  Create_Indicator_Dimension( l_id
                                            , p_Measure_Rec.Dimension7_Id
                                            , 7
                                            , p_owner
                                            , x_return_status
                                            , x_error_tbl
                                            );
              end if;
            end if;
          end if;
        end if;
      end if;
    end if;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Indicator_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Indicator_Dimensions;

--Overload Create_Indicator_Dimensions so that old data model ldts can be uploaded using
--The latest lct file. The lct file can indirectly call this overloaded procedure
--by passing in Org and Time  also
PROCEDURE Create_Indicator_Dimensions
( p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_Org_Dimension_ID  IN   NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Time_Dimension_ID IN   NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_id NUMBER := p_Measure_rec.Measure_Id;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if(IS_OLD_DATA_MODEL(p_Measure_Rec,p_Org_Dimension_ID,p_Time_Dimension_ID)) THEN

    if (BIS_UTILITIES_PUB.Value_Missing(p_Org_Dimension_id)
                                                   = FND_API.G_FALSE
      AND BIS_UTILITIES_PUB.Value_Null(p_Org_Dimension_id)
                                                   = FND_API.G_FALSE) then

     Create_Indicator_Dimension( l_id
                              , p_Org_Dimension_Id
                              , 1
                              , p_owner
                              , x_return_status
                              , x_error_tbl
                              );
    if (BIS_UTILITIES_PUB.Value_Missing(p_Time_Dimension_id)
                                                   = FND_API.G_FALSE
      AND BIS_UTILITIES_PUB.Value_Null(p_Time_Dimension_id)
                                                   = FND_API.G_FALSE) then

     Create_Indicator_Dimension( l_id
                              , p_Time_Dimension_Id
                              , 2
                              , p_owner
                              , x_return_status
                              , x_error_tbl
                              );

    if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE
      AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE) then

     Create_Indicator_Dimension( l_id
                              , p_Measure_Rec.Dimension1_Id
                              , 3
                              , p_owner
                              , x_return_status
                              , x_error_tbl
                              );

    if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension2_id)
                                                   = FND_API.G_FALSE
        AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension2_id)
                                                    = FND_API.G_FALSE) then

      Create_Indicator_Dimension( l_id
                                , p_Measure_Rec.Dimension2_Id
                                , 4
                                , p_owner
                                , x_return_status
                                , x_error_tbl
                                );

      if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension3_id)
                                                   = FND_API.G_FALSE
          AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension3_id)
                                  = FND_API.G_FALSE) then
        Create_Indicator_Dimension( l_id
                                  , p_Measure_Rec.Dimension3_Id
                                  , 5
                                  , p_owner
                                  , x_return_status
                                  , x_error_tbl
                                  );

        if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension4_id)
                                                   = FND_API.G_FALSE
             AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension4_id)
                            = FND_API.G_FALSE) then
          Create_Indicator_Dimension( l_id
                                    , p_Measure_Rec.Dimension4_Id
                                    , 6
                                    , p_owner
                                    , x_return_status
                                    , x_error_tbl
                                    );

          if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension5_id)
                                                   = FND_API.G_FALSE
              AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension5_id)
                            = FND_API.G_FALSE) then
             Create_Indicator_Dimension( l_id
                                       , p_Measure_Rec.Dimension5_Id
                                       , 7
                                       , p_owner
                                       , x_return_status
                                       , x_error_tbl
                                       );
              end if;
            end if;
          end if;
        end if;
      end if;
    end if;
  end if;

  ELSE

    if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE
      AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE) then

     Create_Indicator_Dimension( l_id
                              , p_Measure_Rec.Dimension1_Id
                              , 1
                              , p_owner
                              , x_return_status
                              , x_error_tbl
                              );

    if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension2_id)
                                                   = FND_API.G_FALSE
        AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension2_id)
                                                    = FND_API.G_FALSE) then

      Create_Indicator_Dimension( l_id
                                , p_Measure_Rec.Dimension2_Id
                                , 2
                                , p_owner
                                , x_return_status
                                , x_error_tbl
                                );

      if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension3_id)
                                                   = FND_API.G_FALSE
          AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension3_id)
                                  = FND_API.G_FALSE) then
        Create_Indicator_Dimension( l_id
                                  , p_Measure_Rec.Dimension3_Id
                                  , 3
                                  ,p_owner
                                  , x_return_status
                                  , x_error_tbl
                                  );

        if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension4_id)
                                                   = FND_API.G_FALSE
             AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension4_id)
                            = FND_API.G_FALSE) then
          Create_Indicator_Dimension( l_id
                                    , p_Measure_Rec.Dimension4_Id
                                    , 4
                                    , p_owner
                                    , x_return_status
                                    , x_error_tbl
                                    );

          if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension5_id)
                                                   = FND_API.G_FALSE
              AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension5_id)
                            = FND_API.G_FALSE) then
             Create_Indicator_Dimension( l_id
                                       , p_Measure_Rec.Dimension5_Id
                                       , 5
                                       , p_owner
                                       , x_return_status
                                       , x_error_tbl
                                       );

            if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension6_id)
                                                   = FND_API.G_FALSE
                AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension6_id)
                            = FND_API.G_FALSE) then
               Create_Indicator_Dimension( l_id
                                       , p_Measure_Rec.Dimension6_Id
                                       , 6
                                       , p_owner
                                       , x_return_status
                                       , x_error_tbl
                                       );

              if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension7_id)
                                                   = FND_API.G_FALSE
                  AND BIS_UTILITIES_PUB.Value_Null(p_Measure_Rec.Dimension7_id)
                            = FND_API.G_FALSE) then
                  Create_Indicator_Dimension( l_id
                                           , p_Measure_Rec.Dimension7_Id
                                           , 7
                                           , p_owner
                                           , x_return_status
                                           , x_error_tbl
                                           );
              end if;
            end if;
          end if;
        end if;
      end if;
    end if;
  end if;

END IF;
--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Indicator_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Indicator_Dimensions;

PROCEDURE SetNULL
( p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec      OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
)
IS
BEGIN

  x_measure_rec.Measure_ID                :=
  BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Measure_ID);
  x_measure_rec.Measure_Short_Name        :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Measure_Short_Name);
  x_measure_rec.Measure_Name              :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Measure_Name);
  x_measure_rec.Description               :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Description);
  x_measure_rec.Dimension1_ID             :=
  BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Dimension1_ID);
  x_measure_rec.Dimension1_Short_Name     :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension1_Short_Name);
  x_measure_rec.Dimension1_Name           :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension1_Name);
  x_measure_rec.Dimension2_ID             :=
  BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Dimension2_ID);
  x_measure_rec.Dimension2_Short_Name     :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension2_Short_Name);
  x_measure_rec.Dimension2_Name           :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension2_Name);
  x_measure_rec.Dimension3_ID             :=
  BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Dimension3_ID);
  x_measure_rec.Dimension3_Short_Name     :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension3_Short_Name);
  x_measure_rec.Dimension3_Name           :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension3_Name);
  x_measure_rec.Dimension4_ID             :=
  BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Dimension4_ID);
  x_measure_rec.Dimension4_Short_Name     :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension4_Short_Name);
  x_measure_rec.Dimension4_Name           :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension4_Name);
  x_measure_rec.Dimension5_ID             :=
  BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Dimension5_ID);
  x_measure_rec.Dimension5_Short_Name     :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension5_Short_Name);
  x_measure_rec.Dimension5_Name           :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension5_Name);
  x_measure_rec.Dimension6_ID             :=
  BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Dimension6_ID);
  x_measure_rec.Dimension6_Short_Name     :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension6_Short_Name);
  x_measure_rec.Dimension6_Name           :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension6_Name);
  x_measure_rec.Dimension7_ID             :=
  BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Dimension7_ID);
  x_measure_rec.Dimension7_Short_Name     :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension7_Short_Name);
  x_measure_rec.Dimension7_Name           :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dimension7_Name);
  x_measure_rec.Unit_Of_Measure_Class     :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Unit_Of_Measure_Class);
-- Fix for 1850860 starts here
  x_measure_rec.Actual_Data_Source_Type   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Actual_Data_Source_Type);
  x_measure_rec.Actual_Data_Source        :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Actual_Data_Source);
  x_measure_rec.Function_Name             :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Function_Name);
  x_measure_rec.Comparison_Source         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Comparison_Source);
  x_measure_rec.Increase_In_Measure       :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Increase_In_Measure);
-- Fix for 1850860 ends here
-- 2440739
  x_measure_rec.Enable_Link       :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Enable_Link);
--Enhancement 3865711
  x_measure_rec.Obsolete       :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Obsolete);
  x_measure_rec.Measure_Type             :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Measure_Type);
  x_measure_rec.Application_Id       :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Application_Id); --2465354

  -- mdamle 4/23/2003 - PMD - Measure Definer
  x_measure_rec.Dataset_id       :=
  BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Dataset_Id); --2465354

  -- rpenneru 12/21/2004 - Functional Area Short Name
  x_measure_rec.Func_Area_Short_Name := BIS_UTILITIES_PVT.CheckMissChar(p_measure_rec.Func_Area_Short_Name);

  x_measure_rec.Created_By := BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Created_By);
  x_measure_rec.Creation_Date := BIS_UTILITIES_PVT.CheckMissDate(p_measure_rec.Creation_Date);
  x_measure_rec.Last_Updated_By := BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Last_Updated_By);
  x_measure_rec.Last_Update_Date := BIS_UTILITIES_PVT.CheckMissDate(p_measure_rec.Last_Update_Date);
  x_measure_rec.Last_Update_Login := BIS_UTILITIES_PVT.CheckMissNum(p_measure_rec.Last_Update_Login);

END SetNULL;

-- creates one Measure, with the dimensions sequenced in the order
-- they are passed in
--- redundant because of defaults in next overloaded signature
--Procedure Create_Measure
--( p_api_version      IN  NUMBER
--, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
--, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
--, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
--, x_return_status    OUT NOCOPY VARCHAR2
--, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
--)
--IS
--BEGIN
--
--  Create_Measure
--  ( p_api_version       => p_api_version
--  , p_commit            => p_commit
--  , p_validation_level  => p_validation_level
--  , p_Measure_Rec       => p_Measure_Rec
--  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
--  , x_return_status     => x_return_status
--  , x_error_Tbl         => x_error_Tbl
--  );
--
--EXCEPTION
--  when others then
--    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--   -- added last  two params
--    BIS_UTILITIES_PVT.Add_Error_Message
--    ( p_error_msg_id      => SQLCODE
--    , p_error_description => SQLERRM
--    , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
--    , p_error_table       => x_error_tbl
--     , x_error_table       => x_error_tbl
--    );
--    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
--END Create_Measure;

-- creates one Measure for the given owner,
-- with the dimensions sequenced in the order they are passed in
Procedure Create_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_count    number;
l_user_id         number;
l_login_id        number;
l_id              number;
l_Measure_Rec     BIS_MEASURE_PUB.Measure_Rec_Type;
l_application_rec BIS_APPLICATION_PVT.Application_rec_type;
l_measure_id      NUMBER;
l_own_appl        VARCHAR2(100) := FND_API.G_FALSE  ; --2465354
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_Mapped_measure  bis_indicators_tl.NAME%TYPE;
l_Return_Status      VARCHAR2(2000);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SetNULL( p_Measure_Rec, l_Measure_Rec);
--trying to phase out NOCOPY this procedure--created two new procedures
--a call to value_id_conversion is already made in the public package
/*
  BIS_MEASURE_PVT.Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Measure_Rec   => l_Measure_Rec
  , x_Measure_Rec   => l_Measure_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_tbl
  );
*/


--    dbms_output.put_line('PVT. val id conv: '||x_return_status );

 --Added this check
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  END IF;
--dbms_output.put_line('1'||'l_measure_rec.function_short_name');

  Validate_Measure( p_api_version
          , p_validation_level
          , l_Measure_Rec
                  , p_owner
          , x_return_status
          , x_error_Tbl
                  );
--dbms_output.put_line('2'||'l_measure_rec.function_short_name');

    --dbms_output.put_line('PVT. validate Measure: '||x_return_status );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
--dbms_output.put_line('inside exception');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  l_Measure_Id := Get_Measure_Id_From_Short_Name(p_measure_rec);

  if (l_measure_id is NOT NULL) then
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_MEASURE_SHORT_NAME_UNIQUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;
  --

  -- mdamle 07/18/2003 - Allow enable_link = Y only if function_name is not null
  if (p_measure_rec.function_name is null and p_measure_rec.enable_link = 'Y') then
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_PMF_ENABLE_LINK_ERR'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

-- ankgoel: bug#3557236
  IF (p_Measure_rec.is_validate <> FND_API.G_FALSE) THEN
	  -- mdamle 07/18/2003 - Check if measure is being mapped to a source
	  -- that's already mapped to another measure.
	  if isSourceColumnMappedAlready(p_Measure_rec, l_Mapped_measure) then
	    l_error_tbl := x_error_tbl;
	    BIS_UTILITIES_PVT.Add_Error_Message
	    ( p_error_msg_name    => 'BIS_PMF_SOURCE_MAPPING_ERR'
	    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
	    , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
	    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
	    , p_token1        => 'MEASURE'
	    , p_value1        => l_Mapped_measure
	    , p_error_table       => l_error_tbl
	    , x_error_table       => x_error_tbl
	    );

	    RAISE FND_API.G_EXC_ERROR;
	  end if;

    --sawu: 9/2/04: need to validate compare-to column also for bug#3859267
      if isCompareColumnMappedAlready(p_Measure_rec, l_Mapped_measure) then
	    l_error_tbl := x_error_tbl;
	    BIS_UTILITIES_PVT.Add_Error_Message
	    ( p_error_msg_name    => 'BIS_PMF_COLUMN_MAPPING_ERR'
	    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
	    , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
	    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
	    , p_token1        => 'MEASURE'
	    , p_value1        => l_Mapped_measure
	    , p_error_table       => l_error_tbl
	    , x_error_table       => x_error_tbl
	    );

	    RAISE FND_API.G_EXC_ERROR;
      end if;
  END IF;

  -- ankgoel: bug#3891748 - Created_By will take precedence over Owner.
  -- Last_Updated_By can be different from Created_By while creating measures
  -- during sync-up
  IF (l_Measure_Rec.Created_By IS NULL) THEN
    l_Measure_Rec.Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  END IF;
  IF (l_Measure_Rec.Last_Updated_By IS NULL) THEN
    l_Measure_Rec.Last_Updated_By := l_Measure_Rec.Created_By;
  END IF;
  IF (l_Measure_Rec.Last_Update_Login IS NULL) THEN
    l_Measure_Rec.Last_Update_Login := fnd_global.LOGIN_ID;
  END IF;
  IF (l_Measure_Rec.Creation_Date IS NULL) THEN
    l_Measure_Rec.Creation_Date := sysdate;
  END IF;
  IF (l_Measure_Rec.Last_Update_Date IS NULL) THEN
    l_Measure_Rec.Last_Update_Date := sysdate;
  END IF;

  --
  select bis_indicators_s.NextVal into l_id from dual;
--dbms_output.put_line('function shortname:::'||l_measure_rec.function_short_name);


  insert into bis_indicators(
    INDICATOR_ID
  , SHORT_NAME
  , UOM_CLASS
  , ACTUAL_DATA_SOURCE_TYPE
  , ACTUAL_DATA_SOURCE
  , FUNCTION_NAME
  , COMPARISON_SOURCE
  , INCREASE_IN_MEASURE
  , ENABLE_LINK -- 2440739
  -- mdamle 4/23/2003 - PMD - Measure Definer
  , ENABLED  -- #3031053
  , OBSOLETE --#3865711
  , MEASURE_TYPE
  , DATASET_ID
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  )
  values
  ( l_id
  , l_Measure_Rec.Measure_Short_Name
  , l_Measure_Rec.Unit_Of_Measure_Class
  , l_Measure_Rec.Actual_Data_Source_Type
  , l_Measure_Rec.Actual_Data_Source
  , l_Measure_Rec.Function_Name
  , l_Measure_Rec.Comparison_Source
  , l_Measure_Rec.Increase_In_Measure
  , NVL(l_Measure_Rec.Enable_Link, 'N')
  -- mdamle 4/23/2003 - PMD - Measure Definer
  , l_Measure_Rec.enabled
  -- #3031053
  , l_Measure_Rec.Obsolete --3865711
  , l_Measure_Rec.Measure_Type
  , l_Measure_Rec.Dataset_id
  , l_Measure_Rec.Creation_Date
  , l_Measure_Rec.Created_By
  , l_Measure_Rec.Last_Update_Date
  , l_Measure_Rec.Last_Updated_By
  , l_Measure_Rec.Last_Update_Login
  );

  insert into bis_INDICATORS_TL (
    INDICATOR_ID,
    LANGUAGE,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    TRANSLATED,
    SOURCE_LANG
  ) select
    l_id
  , L.LANGUAGE_CODE
  , l_Measure_Rec.Measure_Name
  , l_Measure_Rec.Description
  , l_Measure_Rec.Creation_Date
  , l_Measure_Rec.Created_By
  , l_Measure_Rec.Last_Update_Date
  , l_Measure_Rec.Last_Updated_By
  , l_Measure_Rec.Last_Update_Login
  ,  'Y'
  , userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from bis_INDICATORS_TL T
    where T.indicator_ID = l_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

  l_measure_rec.Measure_id := l_id;
  -- dbms_output.put_line('CREATE_MEASURE: '||l_id);

  Create_Indicator_Dimensions(l_measure_Rec ,p_owner ,x_return_status ,x_error_Tbl);
  --  dbms_output.put_line('create measure dimension: '||x_return_status);

    --2465354
  l_application_rec.Application_id := l_Measure_Rec.Application_Id;
  IF (NVL(l_application_rec.Application_id,-1) <> -1 ) THEN
    l_own_appl := FND_API.G_TRUE;
  END IF;
--2465354

  Create_Application_Measure
  ( p_api_version        => p_api_version
   ,p_commit             => p_commit
   ,p_Measure_rec        => l_Measure_rec
   ,p_application_rec    => l_application_rec
   ,p_owning_application => l_own_appl
   ,p_owner              => p_owner
   ,x_return_status      => x_return_status
   ,x_error_Tbl          => x_error_Tbl
  );

  --  dbms_output.put_line('create measure application: '||x_return_status);
  IF (p_Measure_Rec.Func_Area_Short_Name IS NOT NULL ) THEN
    Load_Measure_Extension
    ( p_api_version       => p_api_version
      ,p_commit           => p_commit
      , p_Measure_Rec     => l_Measure_rec
      , p_owner           => p_owner
      , x_return_status   => l_Return_Status
      , x_error_Tbl       => x_error_Tbl
    );
    IF (l_return_status IS NOT NULL AND l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Measure;
--
--
-- creates one Measure for the given owner,
-- with the dimensions sequenced in the order they are passed in
--Overload Create_Measure so that old data model ldts can be uploaded using
--The latest lct file. The lct file can call Load_Measure which calls this
--by passing in Org and Time dimension short_names also
Procedure Create_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_Org_Dimension_ID  IN  NUMBER
, p_Time_Dimension_ID IN  NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_count    number;
l_user_id         number;
l_login_id        number;
l_id              number;
l_Measure_Rec     BIS_MEASURE_PUB.Measure_Rec_Type;
l_application_rec BIS_APPLICATION_PVT.Application_rec_type;
l_measure_id      NUMBER;
l_own_appl        VARCHAR2(100) := FND_API.G_FALSE  ; --2465354
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SetNULL( p_Measure_Rec, l_Measure_Rec);

--trying to phase out NOCOPY this procedure--created two new procedures
--a call to value_id_conversion is already made in the public package
/*
  BIS_MEASURE_PVT.Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Measure_Rec   => l_Measure_Rec
  , x_Measure_Rec   => l_Measure_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_tbl
  );
*/


  --  dbms_output.put_line('PVT. val id conv: '||x_return_status );

 --Added this check
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  Validate_Measure( p_api_version
          , p_validation_level
          , l_Measure_Rec
                  , p_owner
          , x_return_status
          , x_error_Tbl
                  );

   -- dbms_output.put_line('PVT. validate Measure: '||x_return_status );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --added this call to validate Org Dimension
  BIS_MEASURE_VALIDATE_PVT.Validate_Dimension_Id
    ( p_api_version           => p_api_version
    , p_dimension_id          => p_Org_Dimension_ID
    , p_dimension_short_name  => FND_API.G_MISS_CHAR
    , x_return_status         => x_return_status
    , x_error_Tbl             => x_error_Tbl
    );
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --added this call to validate Time Dimension
  BIS_MEASURE_VALIDATE_PVT.Validate_Dimension_Id
    ( p_api_version           => p_api_version
    , p_dimension_id          => p_Time_Dimension_ID
    , p_dimension_short_name  => FND_API.G_MISS_CHAR
    , x_return_status         => x_return_status
    , x_error_Tbl             => x_error_Tbl
    );
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  --
  l_Measure_Id := Get_Measure_Id_From_Short_Name(p_measure_rec);

  if (l_measure_id is NOT NULL) then
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_MEASURE_SHORT_NAME_UNIQUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;
  --

  -- ankgoel: bug#3891748 - Created_By will take precedence over Owner.
  -- Last_Updated_By can be different from Created_By while creating measures
  -- during sync-up
  IF (l_Measure_Rec.Created_By IS NULL) THEN
    l_Measure_Rec.Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  END IF;
  IF (l_Measure_Rec.Last_Updated_By IS NULL) THEN
    l_Measure_Rec.Last_Updated_By := l_Measure_Rec.Created_By;
  END IF;
  IF (l_Measure_Rec.Last_Update_Login IS NULL) THEN
    l_Measure_Rec.Last_Update_Login := fnd_global.LOGIN_ID;
  END IF;
  IF (l_Measure_Rec.Creation_Date IS NULL) THEN
    l_Measure_Rec.Creation_Date := sysdate;
  END IF;
  IF (l_Measure_Rec.Last_Update_Date IS NULL) THEN
    l_Measure_Rec.Last_Update_Date := sysdate;
  END IF;

  --
  select bis_indicators_s.NextVal into l_id from dual;


--Code commented as a fix for 2167619 starts here
  insert into bis_indicators(
    INDICATOR_ID
  , SHORT_NAME
  , UOM_CLASS
  , ACTUAL_DATA_SOURCE_TYPE
  , ACTUAL_DATA_SOURCE
  , FUNCTION_NAME
  , COMPARISON_SOURCE
  , INCREASE_IN_MEASURE
  , ENABLE_LINK
  -- mdamle 4/23/2003 - PMD - Measure Definer
  , ENABLED -- #3031053
  , OBSOLETE --3865711
  , MEASURE_TYPE
  , DATASET_ID
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  )
  values
  ( l_id
  , l_Measure_Rec.Measure_Short_Name
  , l_Measure_Rec.Unit_Of_Measure_Class
  , l_Measure_Rec.Actual_Data_Source_Type
  , l_Measure_Rec.Actual_Data_Source
  , l_Measure_Rec.Function_Name
  , l_Measure_Rec.Comparison_Source
  , l_Measure_Rec.Increase_In_Measure
  , NVL(l_Measure_Rec.Enable_Link, 'N')
  -- mdamle 4/23/2003 - PMD - Measure Definer
  , l_Measure_Rec.enabled
  , l_Measure_Rec.Obsolete --3865711
  , l_Measure_Rec.Measure_Type
  , l_Measure_Rec.Dataset_id
  , l_Measure_Rec.Creation_Date
  , l_Measure_Rec.Created_By
  , l_Measure_Rec.Last_Update_Date
  , l_Measure_Rec.Last_Updated_By
  , l_Measure_Rec.Last_Update_Login
  );
/*
  insert into bis_indicators(
    INDICATOR_ID
  , SHORT_NAME
  , UOM_CLASS
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  )
  values
  ( l_id
  , l_Measure_Rec.Measure_Short_Name
  , l_Measure_Rec.Unit_Of_Measure_Class
  , SYSDATE
  , l_user_id
  , SYSDATE
  , l_user_id
  , l_login_id
  );
*/
--Code commented as a fix for 2167619 ends here
  insert into bis_INDICATORS_TL (
    INDICATOR_ID,
    LANGUAGE,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    TRANSLATED,
    SOURCE_LANG
  ) select
    l_id
  , L.LANGUAGE_CODE
  , l_Measure_Rec.Measure_Name
  , l_Measure_Rec.Description
  , l_Measure_Rec.Creation_Date
  , l_Measure_Rec.Created_By
  , l_Measure_Rec.Last_Update_Date
  , l_Measure_Rec.Last_Updated_By
  , l_Measure_Rec.Last_Update_Login
  ,  'Y'
  , userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from bis_INDICATORS_TL T
    where T.indicator_ID = l_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

  l_measure_rec.Measure_id := l_id;
  -- dbms_output.put_line('CREATE_MEASURE: '||l_id);

  --Changed the call to call the overloaded api with Org and Time
  Create_Indicator_Dimensions
  ( p_Measure_Rec =>l_measure_rec
  , p_Org_Dimension_ID => p_Org_Dimension_ID
  , p_Time_Dimension_ID => p_Time_Dimension_ID
  , p_owner => p_owner
  , x_return_status => x_return_status
  , x_error_tbl =>  x_error_tbl
  );
  --  dbms_output.put_line('create measure dimension: '||x_return_status);

  --2465354
  l_application_rec.Application_id := l_Measure_Rec.Application_Id;
  IF (NVL(l_application_rec.Application_id,-1) <> -1 ) THEN
    l_own_appl := FND_API.G_TRUE ;
  END IF;
--2465354

  Create_Application_Measure
  ( p_api_version        => p_api_version
   ,p_commit             => p_commit
   ,p_Measure_rec        => l_Measure_rec
   ,p_application_rec    => l_application_rec
   ,p_owning_application => l_own_appl
   ,p_owner              => p_owner
   ,x_return_status      => x_return_status
   ,x_error_Tbl          => x_error_Tbl
  );

  --  dbms_output.put_line('create measure application: '||x_return_status);

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Measure;
--
--
--
-- Gets All Performance Measures
-- If information about the dimensions are not required, set all_info to
-- FALSE
Procedure Retrieve_Measures
( p_api_version   IN  NUMBER
, p_all_info      IN  VARCHAR2   := FND_API.G_TRUE
, x_Measure_tbl   OUT NOCOPY BIS_MEASURE_PUB.Measure_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_measure_rec BIS_Measure_PUB.Measure_Rec_Type;
l_dimension_tbl BIS_DIMENSION_PUB.Dimension_Tbl_Type;
l_Measure_Rec_p BIS_Measure_PUB.Measure_Rec_Type;

cursor cr_all_measures is
       select measure_id, measure_short_name, measure_name
       from bisbv_performance_measures
       order by UPPER(MEASURE_NAME);

l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  for cr in cr_all_measures loop

    l_measure_rec.measure_id         := cr.measure_id;
    l_measure_rec.measure_short_name := cr.measure_short_name;
    l_measure_rec.measure_name       := cr.measure_name;

    l_Measure_Rec_p := l_Measure_Rec;
    BIS_MEASURE_PVT.Retrieve_Measure( p_api_version
                          , l_Measure_Rec_p
                          , p_all_info
                          , l_Measure_Rec
                          , x_return_status
                          , x_error_Tbl
                          );

    x_measure_tbl(x_measure_tbl.count + 1) := l_measure_rec;

  end loop;

  IF cr_all_measures%ISOPEN THEN CLOSE cr_all_measures; END IF;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     IF cr_all_measures%ISOPEN THEN CLOSE cr_all_measures; END IF;
     --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF cr_all_measures%ISOPEN THEN CLOSE cr_all_measures; END IF;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF cr_all_measures%ISOPEN THEN CLOSE cr_all_measures; END IF;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF cr_all_measures%ISOPEN THEN CLOSE cr_all_measures; END IF;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measures'
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Measures;
--
--
-- Gets Information for One Performance Measure
-- If information about the dimension are not required, set all_info to FALSE.
Procedure Retrieve_Measure
( p_api_version   IN  NUMBER
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_all_info      IN  VARCHAR2   := FND_API.G_TRUE
, x_Measure_Rec   IN OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_ID NUMBER;
l_dimension_rec BIS_DIMENSION_PUB.DIMENSION_REC_TYPE;
l_Dimension_Rec_p BIS_DIMENSION_PUB.DIMENSION_REC_TYPE;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_Measure_Rec.Measure_Id IS NOT NULL) THEN
  Select Measure_id
       , Measure_short_name
       , Measure_name
       , description
       , actual_data_source_type
       , actual_data_source
       , Function_Name
       , Comparison_Source
       , Increase_In_Measure
       , Enable_Link
       , Enabled
       , Obsolete --3865711
       , Measure_Type
       , Dimension1_Id
       , Dimension2_Id
       , Dimension3_Id
       , Dimension4_Id
       , Dimension5_Id
       , Dimension6_Id
       , Dimension7_Id
       , Unit_of_Measure_Class
       , Dataset_Id
  into x_Measure_rec.Measure_id
     , x_Measure_rec.Measure_short_name
     , x_Measure_rec.Measure_name
     , x_Measure_rec.description
     , x_Measure_rec.Actual_Data_Source_Type
     , x_Measure_rec.Actual_Data_Source
     , x_Measure_rec.Function_Name
     , x_Measure_rec.Comparison_Source
     , x_Measure_rec.Increase_In_Measure
     , x_Measure_rec.Enable_Link
     , x_Measure_rec.Enabled
     , x_Measure_rec.Obsolete --3865711
     , x_Measure_rec.Measure_Type
     , x_Measure_rec.Dimension1_Id
     , x_Measure_rec.Dimension2_Id
     , x_Measure_rec.Dimension3_Id
     , x_Measure_rec.Dimension4_Id
     , x_Measure_rec.Dimension5_Id
     , x_Measure_rec.Dimension6_Id
     , x_Measure_rec.Dimension7_Id
     , x_Measure_rec.Unit_Of_Measure_Class
     , x_Measure_rec.Dataset_Id
  from bisbv_performance_measures
  where measure_id = p_Measure_Rec.Measure_ID;
  END IF;
  IF (p_Measure_Rec.Measure_Short_Name IS NOT NULL AND
      p_Measure_Rec.Measure_Id IS NULL) THEN
  Select Measure_id
       , Measure_short_name
       , Measure_name
       , description
       , actual_data_source_type
       , actual_data_source
       , Function_Name
       , Comparison_Source
       , Increase_In_Measure
       , Enable_Link
       , Enabled
       , Obsolete --3865711
       , Measure_Type
       , Dimension1_Id
       , Dimension2_Id
       , Dimension3_Id
       , Dimension4_Id
       , Dimension5_Id
       , Dimension6_Id
       , Dimension7_Id
       , Unit_of_Measure_Class
       , Dataset_Id
  into x_Measure_rec.Measure_id
     , x_Measure_rec.Measure_short_name
     , x_Measure_rec.Measure_name
     , x_Measure_rec.description
     , x_Measure_rec.Actual_Data_Source_Type
     , x_Measure_rec.Actual_Data_Source
     , x_Measure_rec.Function_Name
     , x_Measure_rec.Comparison_Source
     , x_Measure_rec.Increase_In_Measure
     , x_Measure_rec.Enable_Link
     , x_Measure_rec.Enabled
     , x_Measure_rec.Obsolete --3865711
     , x_Measure_rec.Measure_Type
     , x_Measure_rec.Dimension1_Id
     , x_Measure_rec.Dimension2_Id
     , x_Measure_rec.Dimension3_Id
     , x_Measure_rec.Dimension4_Id
     , x_Measure_rec.Dimension5_Id
     , x_Measure_rec.Dimension6_Id
     , x_Measure_rec.Dimension7_Id
     , x_Measure_rec.Unit_Of_Measure_Class
     , x_Measure_rec.Dataset_Id
  from bisbv_performance_measures
  where measure_short_name = p_Measure_Rec.Measure_Short_Name; -- bug fix -- mahesh
  END IF;
  IF p_all_info = FND_API.G_TRUE THEN

    if (BIS_UTILITIES_PUB.Value_Not_Missing(x_Measure_rec.Dimension1_Id)
               = FND_API.G_TRUE AND
        BIS_UTILITIES_PUB.Value_Not_NULL(x_Measure_rec.Dimension1_Id)
                       = FND_API.G_TRUE) THEN
      l_dimension_rec.dimension_id := x_Measure_rec.Dimension1_Id;
      l_Dimension_Rec_p := l_Dimension_Rec;
      BIS_DIMENSION_PVT.Retrieve_Dimension
      ( p_api_version
      , l_Dimension_Rec_p
      , l_Dimension_Rec
      , x_return_status
      , x_error_Tbl
      );

      x_Measure_rec.Dimension1_Short_Name
                              := l_dimension_rec.Dimension_Short_Name;
      x_Measure_rec.Dimension1_Name := l_dimension_rec.Dimension_Name;
    end if;

    if (BIS_UTILITIES_PUB.Value_Not_Missing(x_Measure_rec.Dimension2_Id)
               = FND_API.G_TRUE AND
    x_return_status = FND_API.G_RET_STS_SUCCESS AND
        BIS_UTILITIES_PUB.Value_Not_NULL(x_Measure_rec.Dimension2_Id)
                       = FND_API.G_TRUE) THEN

      l_dimension_rec.dimension_id := x_Measure_rec.Dimension2_Id;
      l_Dimension_Rec_p := l_Dimension_Rec;
      BIS_DIMENSION_PVT.Retrieve_Dimension
      ( p_api_version
      , l_Dimension_Rec_p
      , l_Dimension_Rec
      , x_return_status
      , x_error_Tbl
      );

      x_Measure_rec.Dimension2_Short_Name
                              := l_dimension_rec.Dimension_Short_Name;
      x_Measure_rec.Dimension2_Name := l_dimension_rec.Dimension_Name;
    else
      return;
    end if;

    if (BIS_UTILITIES_PUB.Value_Not_Missing(x_Measure_rec.Dimension3_Id)
               = FND_API.G_TRUE AND
    x_return_status = FND_API.G_RET_STS_SUCCESS AND
        BIS_UTILITIES_PUB.Value_Not_NULL(x_Measure_rec.Dimension3_Id)
                       = FND_API.G_TRUE) THEN

      l_dimension_rec.dimension_id := x_Measure_rec.Dimension3_Id;
      l_Dimension_Rec_p := l_Dimension_Rec;
      BIS_DIMENSION_PVT.Retrieve_Dimension
      ( p_api_version
      , l_Dimension_Rec_p
      , l_Dimension_Rec
      , x_return_status
      , x_error_Tbl
      );

      x_Measure_rec.Dimension3_Short_Name
                              := l_dimension_rec.Dimension_Short_Name;
      x_Measure_rec.Dimension3_Name := l_dimension_rec.Dimension_Name;
    else
      return;
    end if;

    if (BIS_UTILITIES_PUB.Value_Not_Missing(x_Measure_rec.Dimension4_Id)
               = FND_API.G_TRUE AND
    x_return_status = FND_API.G_RET_STS_SUCCESS AND
        BIS_UTILITIES_PUB.Value_Not_NULL(x_Measure_rec.Dimension4_Id)
                       = FND_API.G_TRUE) THEN

      l_dimension_rec.dimension_id := x_Measure_rec.Dimension4_Id;
      l_Dimension_Rec_p := l_Dimension_Rec;
      BIS_DIMENSION_PVT.Retrieve_Dimension
      ( p_api_version
      , l_Dimension_Rec_p
      , l_Dimension_Rec
      , x_return_status
      , x_error_Tbl
      );

      x_Measure_rec.Dimension4_Short_Name
                              := l_dimension_rec.Dimension_Short_Name;
      x_Measure_rec.Dimension4_Name := l_dimension_rec.Dimension_Name;
    else
      return;
    end if;

    if (BIS_UTILITIES_PUB.Value_Not_Missing(x_Measure_rec.Dimension5_Id)
               = FND_API.G_TRUE AND
    x_return_status = FND_API.G_RET_STS_SUCCESS AND
        BIS_UTILITIES_PUB.Value_Not_NULL(x_Measure_rec.Dimension5_Id)
                       = FND_API.G_TRUE) THEN

      l_dimension_rec.dimension_id := x_Measure_rec.Dimension5_Id;
      l_Dimension_Rec_p := l_Dimension_Rec;
      BIS_DIMENSION_PVT.Retrieve_Dimension
      ( p_api_version
      , l_Dimension_Rec_p
      , l_Dimension_Rec
      , x_return_status
      , x_error_Tbl
      );

      x_Measure_rec.Dimension5_Short_Name
                              := l_dimension_rec.Dimension_Short_Name;
      x_Measure_rec.Dimension5_Name := l_dimension_rec.Dimension_Name;
    else
      return;
    end if;

    if (BIS_UTILITIES_PUB.Value_Not_Missing(x_Measure_rec.Dimension6_Id)
               = FND_API.G_TRUE AND
    x_return_status = FND_API.G_RET_STS_SUCCESS AND
        BIS_UTILITIES_PUB.Value_Not_NULL(x_Measure_rec.Dimension6_Id)
                       = FND_API.G_TRUE) THEN

      l_dimension_rec.dimension_id := x_Measure_rec.Dimension6_Id;
      l_Dimension_Rec_p := l_Dimension_Rec;
      BIS_DIMENSION_PVT.Retrieve_Dimension
      ( p_api_version
      , l_Dimension_Rec_p
      , l_Dimension_Rec
      , x_return_status
      , x_error_Tbl
      );

      x_Measure_rec.Dimension6_Short_Name
                              := l_dimension_rec.Dimension_Short_Name;
      x_Measure_rec.Dimension6_Name := l_dimension_rec.Dimension_Name;
    else
      return;
    end if;

    if (BIS_UTILITIES_PUB.Value_Not_Missing(x_Measure_rec.Dimension7_Id)
               = FND_API.G_TRUE AND
    x_return_status = FND_API.G_RET_STS_SUCCESS AND
        BIS_UTILITIES_PUB.Value_Not_NULL(x_Measure_rec.Dimension7_Id)
                       = FND_API.G_TRUE) THEN

      l_dimension_rec.dimension_id := x_Measure_rec.Dimension7_Id;
      l_Dimension_Rec_p := l_Dimension_Rec;
      BIS_DIMENSION_PVT.Retrieve_Dimension
      ( p_api_version
      , l_Dimension_Rec_p
      , l_Dimension_Rec
      , x_return_status
      , x_error_Tbl
      );

      x_Measure_rec.Dimension7_Short_Name
                              := l_dimension_rec.Dimension_Short_Name;
      x_Measure_rec.Dimension7_Name := l_dimension_rec.Dimension_Name;
    else
      return;
    end if;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --added the error message
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_MEASURE_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measure'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measure'
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Measure;
--
Procedure Update_Indicator_Dimension
( p_Measure_id    number
, p_dimension_id  number
, p_sequence_no   number
, p_owner         IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
l_user_id         number;
l_login_id        number;
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  if (BIS_UTILITIES_PUB.Value_Missing(p_dimension_id) = FND_API.G_TRUE) then
    return;
  end if;

  l_user_id := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_login_id := fnd_global.LOGIN_ID;

  UPDATE bis_indicator_dimensions
  set
    Dimension_ID      = p_dimension_id
  , CREATION_DATE     = SYSDATE
  , CREATED_BY        = l_user_id
  , LAST_UPDATE_DATE  = SYSDATE
  , LAST_UPDATED_BY   = l_user_id
  , LAST_UPDATE_LOGIN = l_login_id
  where INDICATOR_ID  = p_Measure_ID
    AND SEQUENCE_NO   = p_sequence_no;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Indicator_Dimension'
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Update_Indicator_Dimension;

FUNCTION Dimension_Count(p_Measure_Rec IN  BIS_MEASURE_PUB.Measure_Rec_Type)
return NUMBER
IS
l_count NUMBER := 2;
BEGIN

  if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE
     AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE) then
    l_count := 3;
    if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension2_id)
                                                    = FND_API.G_FALSE
        AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension2_id)
                                                   = FND_API.G_FALSE) then
      l_count := 4;
      if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension3_id)
                                  = FND_API.G_FALSE
          AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension3_id)
                                                   = FND_API.G_FALSE) then
        l_count := 5;
        if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension4_id)
                            = FND_API.G_FALSE
            AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension4_id)
                                                   = FND_API.G_FALSE) then
          l_count := 6;
          if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension5_id)
                            = FND_API.G_FALSE
             AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension5_id)
                                                   = FND_API.G_FALSE) then
            l_count := 7;
          end if;
        end if;
      end if;
    end if;
  end if;

  return l_count;
END Dimension_Count;

--OverLoad Dimension Count so that when loader tries to update a measure
--with an old ldt file, it will not fail
FUNCTION Dimension_Count
(p_Measure_Rec IN  BIS_MEASURE_PUB.Measure_Rec_Type
,p_Org_Dimension_Id IN NUMBER
,p_Time_Dimension_Id IN NUMBER
)
return NUMBER
IS
l_count NUMBER;
BEGIN

  if(IS_OLD_DATA_MODEL(p_Measure_Rec,p_Org_Dimension_Id,p_Time_Dimension_Id)) then
   if (BIS_UTILITIES_PUB.Value_Missing(p_Org_Dimension_id)
                                                   = FND_API.G_FALSE
      AND BIS_UTILITIES_PUB.Value_Null(p_Org_Dimension_id)
                                                   = FND_API.G_FALSE) then
      l_count := 1;
     if (BIS_UTILITIES_PUB.Value_Missing(p_Time_Dimension_id)
                                                   = FND_API.G_FALSE
      AND BIS_UTILITIES_PUB.Value_Null(p_Time_Dimension_id)
                                                   = FND_API.G_FALSE) then
      l_count := 2;
   if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE
     AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE) then
    l_count := 3;
    if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension2_id)
                                                    = FND_API.G_FALSE
        AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension2_id)
                                                   = FND_API.G_FALSE) then
      l_count := 4;
      if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension3_id)
                                  = FND_API.G_FALSE
          AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension3_id)
                                                   = FND_API.G_FALSE) then
        l_count := 5;
        if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension4_id)
                            = FND_API.G_FALSE
            AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension4_id)
                                                   = FND_API.G_FALSE) then
          l_count := 6;
          if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension5_id)
                            = FND_API.G_FALSE
             AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension5_id)
                                                   = FND_API.G_FALSE) then
            l_count := 7;
            end if;
           end if;
          end if;
        end if;
      end if;
    end if;
  end if;

  else
  if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE
     AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension1_id)
                                                   = FND_API.G_FALSE) then
    l_count := 1;
    if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension2_id)
                                                    = FND_API.G_FALSE
        AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension2_id)
                                                   = FND_API.G_FALSE) then
      l_count := 2;
      if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension3_id)
                                  = FND_API.G_FALSE
          AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension3_id)
                                                   = FND_API.G_FALSE) then
        l_count := 3;
        if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension4_id)
                            = FND_API.G_FALSE
            AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension4_id)
                                                   = FND_API.G_FALSE) then
          l_count := 4;
          if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension5_id)
                            = FND_API.G_FALSE
             AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension5_id)
                                                   = FND_API.G_FALSE) then
            l_count := 5;
             if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension6_id)
                            = FND_API.G_FALSE
             AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension6_id)
                                                   = FND_API.G_FALSE) then
            l_count := 6;
              if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Rec.Dimension7_id)
                            = FND_API.G_FALSE
              AND BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Dimension7_id)
                                                   = FND_API.G_FALSE) then
              l_count := 7;
              end if;
            end if;
          end if;
        end if;
      end if;
    end if;
  end if;

  end if;

  return l_count;
END Dimension_Count;

PROCEDURE UpdateMeasureRec   -- Changed for 2784713
( p_Measure_Rec  IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_Measure_Rec1 IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec  OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
)
IS

BEGIN

  x_measure_rec := p_Measure_Rec1;

  x_measure_rec.Measure_Short_Name  := p_measure_rec.Measure_Short_Name;
  x_measure_rec.Measure_Name        := p_measure_rec.Measure_Name;
  x_measure_rec.Description     := p_measure_rec.Description;
  x_measure_rec.Actual_Data_Source_Type := p_measure_rec.Actual_Data_Source_Type;
  x_measure_rec.Actual_Data_Source      := p_measure_rec.Actual_Data_Source;
  x_measure_rec.Function_Name           := p_measure_rec.Function_Name;
  x_measure_rec.Comparison_Source       := p_measure_rec.Comparison_Source;
  x_measure_rec.Increase_In_Measure     := p_measure_rec.Increase_In_Measure;
  x_measure_rec.Enable_Link     := p_measure_rec.Enable_Link;
  x_measure_rec.Enabled		:= p_measure_rec.Enabled;
  x_measure_rec.Obsolete   := p_measure_rec.Obsolete; --3865711
  x_measure_rec.Measure_Type   := p_measure_rec.Measure_Type;
  x_measure_rec.Application_Id      := p_measure_rec.Application_Id;
  x_measure_rec.Unit_Of_Measure_Class   := p_measure_rec.Unit_Of_Measure_Class;


  x_measure_rec.Dimension1_ID := return_value_if_not_missing
                                 ( p_number => p_measure_rec.Dimension1_ID );

  x_measure_rec.Dimension1_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension1_Short_Name );

  x_measure_rec.Dimension1_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension1_Name );



  x_measure_rec.Dimension2_ID := return_value_if_not_missing
                                 ( p_number => p_measure_rec.Dimension2_ID );

  x_measure_rec.Dimension2_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension2_Short_Name );

  x_measure_rec.Dimension2_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension2_Name );



  x_measure_rec.Dimension3_ID := return_value_if_not_missing
                                 ( p_number => p_measure_rec.Dimension3_ID );

  x_measure_rec.Dimension3_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension3_Short_Name );

  x_measure_rec.Dimension3_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension3_Name );



  x_measure_rec.Dimension4_ID := return_value_if_not_missing
                                 ( p_number => p_measure_rec.Dimension4_ID );

  x_measure_rec.Dimension4_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension4_Short_Name );

  x_measure_rec.Dimension4_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension4_Name );



  x_measure_rec.Dimension5_ID := return_value_if_not_missing
                                 ( p_number => p_measure_rec.Dimension5_ID );

  x_measure_rec.Dimension5_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension5_Short_Name );

  x_measure_rec.Dimension5_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension5_Name );



  x_measure_rec.Dimension6_ID := return_value_if_not_missing
                                 ( p_number => p_measure_rec.Dimension6_ID );

  x_measure_rec.Dimension6_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension6_Short_Name );

  x_measure_rec.Dimension6_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension6_Name );



  x_measure_rec.Dimension7_ID := return_value_if_not_missing
                                 ( p_number => p_measure_rec.Dimension7_ID );

  x_measure_rec.Dimension7_Short_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension7_Short_Name );

  x_measure_rec.Dimension7_Name := return_value_if_not_missing
                                 ( p_varchar2 => p_measure_rec.Dimension7_Name );

  --
END UpdateMeasureRec;


PROCEDURE ArrangeDimensions   -- Added for 2784713
( p_Measure_Rec       IN         BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec       OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
) IS

  i                     NUMBER;
  j                     NUMBER;
  l_dim_tbl             BIS_DIMENSION_PUB.Dimension_Tbl_Type;
  l_arranged_dim_tbl    BIS_DIMENSION_PUB.Dimension_Tbl_Type;
  l_number_of_dims      NUMBER := 0;

BEGIN

  x_Measure_Rec := p_Measure_Rec ;

  -- see if there are any dimesnions to be deleted
  -- bump all the remaining dimension together

  l_dim_tbl(1).dimension_id := x_measure_rec.Dimension1_ID;
  l_dim_tbl(2).dimension_id := x_measure_rec.Dimension2_ID;
  l_dim_tbl(3).dimension_id := x_measure_rec.Dimension3_ID;
  l_dim_tbl(4).dimension_id := x_measure_rec.Dimension4_ID;
  l_dim_tbl(5).dimension_id := x_measure_rec.Dimension5_ID;
  l_dim_tbl(6).dimension_id := x_measure_rec.Dimension6_ID;
  l_dim_tbl(7).dimension_id := x_measure_rec.Dimension7_ID;


  j := 1;

  FOR i IN 1..7 LOOP -- Dimensions ab_de_f become abdef__

    IF ( bis_utilities_pvt.Value_Not_Missing
           (p_value => l_dim_tbl(i).Dimension_id ) = FND_API.G_TRUE ) THEN

      l_arranged_dim_tbl(j).Dimension_id := l_dim_tbl(i).Dimension_id;
      j := j+1;

    END IF;

  END LOOP;

  -- mdamle 4/23/2003 - PMD - Measure Definer - When a measure is created
  -- through PMD, Dimensions may not be assigned at that time.
  -- Hence LAST causes an exception for empty table.
  --  l_number_of_dims := l_arranged_dim_tbl.LAST;
  l_number_of_dims := l_arranged_dim_tbl.COUNT;

  FOR i IN (l_number_of_dims+1)..7 LOOP
    l_arranged_dim_tbl(i).Dimension_id := NULL;
  END LOOP;


  x_measure_rec.Dimension1_ID :=  l_arranged_dim_tbl(1).dimension_id;
  x_measure_rec.Dimension2_ID :=  l_arranged_dim_tbl(2).dimension_id;
  x_measure_rec.Dimension3_ID :=  l_arranged_dim_tbl(3).dimension_id;
  x_measure_rec.Dimension4_ID :=  l_arranged_dim_tbl(4).dimension_id;
  x_measure_rec.Dimension5_ID :=  l_arranged_dim_tbl(5).dimension_id;
  x_measure_rec.Dimension6_ID :=  l_arranged_dim_tbl(6).dimension_id;
  x_measure_rec.Dimension7_ID :=  l_arranged_dim_tbl(7).dimension_id;

END ArrangeDimensions ;


FUNCTION return_value_if_not_missing -- 2784713
( p_number  IN NUMBER )
RETURN NUMBER IS
BEGIN

  IF  (  bis_utilities_pvt.Value_Missing
           (p_value => p_number ) = FND_API.G_TRUE  ) THEN
    RETURN NULL;
  ELSE
    RETURN p_number;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;


FUNCTION return_value_if_not_missing -- 2784713
( p_varchar2  IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN

  IF  (  bis_utilities_pvt.Value_Missing
           (p_value => p_varchar2 ) = FND_API.G_TRUE ) THEN
    RETURN NULL;
  ELSE
    RETURN p_varchar2;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;


PROCEDURE Update_Measure_Rec_Total -- 2664898
( p_Measure_Rec_orig  IN         BIS_MEASURE_PUB.Measure_Rec_Type
, p_Measure_Rec_new   IN         BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec       OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
)
IS

  l_Measure_Rec       BIS_MEASURE_PUB.Measure_Rec_Type;

BEGIN

  UpdateMeasureRecNoDim
  ( p_Measure_Rec  => p_Measure_Rec_new
  , p_Measure_Rec1 => p_Measure_Rec_Orig
  , x_Measure_Rec  => l_Measure_Rec
  );

  Update_Measure_Rec_Dims
  ( p_Measure_Rec_orig  => l_Measure_Rec
  , p_Measure_Rec_new   => p_Measure_Rec_new
  , x_Measure_Rec       => x_Measure_Rec
  );

END Update_Measure_Rec_Total;



--
--
--Overload  UpdateMeasureRec if loader is trying to Update
-- Measure from old ldt allow update only of Measure Name and Description
PROCEDURE UpdateMeasureRecNoDim
( p_Measure_Rec  IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_Measure_Rec1 IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec  OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
)
IS
l_ret      VARCHAR2(32000);
l_dim_tbl  BIS_DIMENSION_PUB.Dimension_Tbl_Type;
BEGIN

  x_measure_rec := p_Measure_Rec1;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.Measure_Name);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.Measure_Name := p_measure_rec.Measure_Name;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.Description);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.Description := p_measure_rec.Description;
  END IF;

  -- Added for P1 2565752
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.Unit_Of_Measure_Class);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.Unit_Of_Measure_Class := p_measure_rec.Unit_Of_Measure_Class;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.ACTUAL_DATA_SOURCE_TYPE);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.ACTUAL_DATA_SOURCE_TYPE := p_measure_rec.ACTUAL_DATA_SOURCE_TYPE;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.ACTUAL_DATA_SOURCE);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.ACTUAL_DATA_SOURCE := p_measure_rec.ACTUAL_DATA_SOURCE;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.FUNCTION_NAME);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.FUNCTION_NAME := p_measure_rec.FUNCTION_NAME;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.COMPARISON_SOURCE);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.COMPARISON_SOURCE := p_measure_rec.COMPARISON_SOURCE;
  END IF;


  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.INCREASE_IN_MEASURE);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.INCREASE_IN_MEASURE := p_measure_rec.INCREASE_IN_MEASURE;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.ENABLE_LINK);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.ENABLE_LINK := p_measure_rec.ENABLE_LINK;
  END IF;
 -- 3031053
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.ENABLED);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.ENABLED := p_measure_rec.ENABLED;
  END IF;
--3031053
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.Obsolete); --3865711
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.Obsolete := p_measure_rec.Obsolete;
  END IF;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.Measure_Type); --3865711
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.Measure_Type := p_measure_rec.Measure_Type;
  END IF;
--- 2465354
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_rec.Application_Id);
  IF (l_ret = FND_API.G_FALSE) THEN
    x_measure_rec.Application_Id  := p_measure_rec.Application_Id;
  END IF;
--- 2465354


END UpdateMeasureRecNoDim;



-- Updating the dimensions of the measures too...
-- This is for P1 bug reported by BIL team bug 2664898
PROCEDURE Update_Measure_Rec_Dims
( p_Measure_Rec_orig  IN         BIS_MEASURE_PUB.Measure_Rec_Type
, p_Measure_Rec_new   IN         BIS_MEASURE_PUB.Measure_Rec_Type
, x_Measure_Rec       OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
)
IS
BEGIN

  x_Measure_Rec := p_Measure_Rec_orig;

  x_measure_rec.dimension1_id := get_dimension_ID
                                 ( p_dim_id => p_Measure_Rec_new.dimension1_id);

  x_measure_rec.dimension2_id := get_dimension_ID
                                 ( p_dim_id => p_Measure_Rec_new.dimension2_id);

  x_measure_rec.dimension3_id := get_dimension_ID
                                 ( p_dim_id => p_Measure_Rec_new.dimension3_id);

  x_measure_rec.dimension4_id := get_dimension_ID
                                 ( p_dim_id => p_Measure_Rec_new.dimension4_id);

  x_measure_rec.dimension5_id := get_dimension_ID
                                 ( p_dim_id => p_Measure_Rec_new.dimension5_id);

  x_measure_rec.dimension6_id := get_dimension_ID
                                 ( p_dim_id => p_Measure_Rec_new.dimension6_id);

  x_measure_rec.dimension7_id := get_dimension_ID
                                ( p_dim_id => p_Measure_Rec_new.dimension7_id);

END Update_Measure_Rec_Dims;


FUNCTION get_dimension_ID -- 2664898
( p_dim_id  IN NUMBER )
RETURN NUMBER IS

  l_is_missing      VARCHAR2(300);
  l_is_null         VARCHAR2(300);

BEGIN

  l_is_missing := BIS_UTILITIES_PUB.Value_Missing(p_dim_id);
  l_is_null := BIS_UTILITIES_PUB.Value_Null(p_dim_id);

  IF  (   (l_is_missing = FND_API.G_TRUE)
       OR (l_is_null = FND_API.G_TRUE)
      ) THEN
    RETURN NULL;
  ELSE
    RETURN p_dim_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;


--
-- PLEASE VERIFY COMMENT BELOW
-- Update_Measures one Measure if
--   1) no Measure levels or targets exist
--   2) no users have selected to see actuals for the Measure
Procedure Update_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_MEASURE_PVT.Update_Measure
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Measure_Rec       => p_Measure_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

--commented RAISE
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
     , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Measure;

--
-- PLEASE VERIFY COMMENT BELOW
-- Update_Measures one Measure if
--   1) no Measure levels or targets exist
--   2) no users have selected to see actuals for the Measure
Procedure Update_Measure  -- Changed for 2784713
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id             number;
l_login_id            number;
l_Measure_Rec         BIS_MEASURE_PUB.Measure_Rec_Type;
l_Measure_Rec1        BIS_MEASURE_PUB.Measure_Rec_Type;
l_Measure_Rec_Orig    BIS_MEASURE_PUB.Measure_Rec_Type;
l_Measure_Rec_Overlap BIS_MEASURE_PUB.Measure_Rec_Type;
l_count               NUMBER := 0;
l_Measure_Id          NUMBER;
l_application_rec     BIS_APPLICATION_PVT.Application_rec_type; --2465354
l_own_appl            VARCHAR2(100) := FND_API.G_FALSE  ; --2465354
l_error_tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;
l_Mapped_measure      bis_indicators_tl.NAME%TYPE;
l_Return_Status       VARCHAR2(2000);

BEGIN
--  l_measure_rec := p_measure_rec;

  Validate_Measure( p_api_version
          , p_validation_level
          , p_Measure_Rec
                  , p_owner
          , x_return_status
          , x_error_Tbl
                  );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  BIS_MEASURE_PVT.Retrieve_Measure
  ( p_api_version   => 1.0
  , p_Measure_Rec   => p_Measure_Rec
  , p_all_info      => FND_API.G_TRUE
  , x_Measure_Rec   => l_measure_rec_Orig
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

  -- mdamle 07/18/2003 - Allow enable_link = Y only if function_name is not null
  if (p_measure_rec.function_name is null and p_measure_rec.enable_link = 'Y') then
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_PMF_ENABLE_LINK_ERR'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

-- ankgoel: bug#3557236
  IF (p_Measure_rec.is_validate <> FND_API.G_FALSE) THEN
	  -- mdamle 07/18/2003 - Check if measure is being mapped to a source
	  -- that's already mapped to another measure.
	  if isSourceColumnMappedAlready(p_Measure_rec, l_Mapped_measure) then
	    l_error_tbl := x_error_tbl;

	    BIS_UTILITIES_PVT.Add_Error_Message
	    ( p_error_msg_name    => 'BIS_PMF_SOURCE_MAPPING_ERR'
	    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
	    , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
	    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
	    , p_token1        => 'MEASURE'
	    , p_value1        => l_Mapped_measure
	    , p_error_table       => l_error_tbl
	    , x_error_table       => x_error_tbl
	    );
	    RAISE FND_API.G_EXC_ERROR;
	  end if;

      --sawu: 9/2/04: need to validate compare-to column also for bug#3859267
      if isCompareColumnMappedAlready(p_Measure_rec, l_Mapped_measure) then
	    l_error_tbl := x_error_tbl;
	    BIS_UTILITIES_PVT.Add_Error_Message
	    ( p_error_msg_name    => 'BIS_PMF_COLUMN_MAPPING_ERR'
	    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
	    , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
	    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
	    , p_token1        => 'MEASURE'
	    , p_value1        => l_Mapped_measure
	    , p_error_table       => l_error_tbl
	    , x_error_table       => x_error_tbl
	    );

	    RAISE FND_API.G_EXC_ERROR;
      end if;
  END IF;

  l_Measure_Id := l_measure_rec_Orig.measure_id;

  if (l_measure_id is NOT NULL) then
    --added the first condition
    if (p_Measure_Rec.Measure_Id  is NULL or l_measure_id <> p_Measure_Rec.Measure_Id) then
      --added last two params
      --changed error message-used to be 'BIS_MEASURE_SHORT_NAME_UNIQUE'
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_MEASURE_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;
  --
  BIS_TARGET_LEVEL_PVT.Count_Target_Levels( p_api_version   =>1.0
                      , p_Measure_Rec   =>p_Measure_Rec
                      , x_count         =>l_count
                      , x_return_status =>x_return_status
                      , x_error_Tbl     =>x_error_Tbl
                      );

  -- ankgoel: bug#3922308: This part of validation will only run for ldt uploads.
  -- The control coming from JAVA layer doesn't need this validation since all logic
  -- is present at JAVA layer itself.
  IF (  (l_count > 0) AND (p_Measure_rec.is_validate = FND_API.G_FALSE) AND
        ( NVL(l_Measure_Rec_Orig.dimension1_id,1) <> NVL(p_Measure_Rec.dimension1_id,1) OR
          NVL(l_Measure_Rec_Orig.dimension2_id,2) <> NVL(p_Measure_Rec.dimension2_id,2) OR
          NVL(l_Measure_Rec_Orig.dimension3_id,3) <> NVL(p_Measure_Rec.dimension3_id,3) OR
          NVL(l_Measure_Rec_Orig.dimension4_id,4) <> NVL(p_Measure_Rec.dimension4_id,4) OR
          NVL(l_Measure_Rec_Orig.dimension5_id,5) <> NVL(p_Measure_Rec.dimension5_id,5) OR
          NVL(l_Measure_Rec_Orig.dimension6_id,6) <> NVL(p_Measure_Rec.dimension6_id,6) OR
          NVL(l_Measure_Rec_Orig.dimension7_id,7) <> NVL(p_Measure_Rec.dimension7_id,7)
        )
     ) THEN
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_NO_DIMENSION_CHANGE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- ankgoel: bug#3922308: Now that the user can update the actual data source
  -- for a measure, however the new souce having the same set of dimensions,
  -- it may happen that the order of set of dimensions is modified.
  -- Get dimensions from the original record in that order, so that bis_indicator_dimensions
  -- will still have the same sequence of dimensions.
  -- This will be done only if the measure has an existing summary level.
  IF ((l_count > 0) AND (p_Measure_rec.is_validate <> FND_API.G_FALSE)) THEN
    GetOriginalDimensions( p_Measure_Rec_Orig    =>  l_Measure_Rec_Orig
                         , p_Measure_Rec         =>  p_Measure_Rec
			 , x_Measure_Rec_Overlap =>  l_Measure_Rec_Overlap
			 );
  ELSE
    l_Measure_Rec_Overlap := p_Measure_Rec;
  END IF;

  -- retrieve record from database and apply changes
  UpdateMeasureRec
  ( p_Measure_Rec  => l_Measure_Rec_Overlap
  , p_Measure_Rec1 => l_Measure_Rec_Orig
  , x_Measure_Rec  => l_Measure_Rec1
  );

  ArrangeDimensions   -- Added for 2784713
  ( p_Measure_Rec    => l_measure_rec1
  , x_Measure_Rec    => l_measure_rec
  ) ;

  l_user_id := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_login_id := fnd_global.LOGIN_ID;

  l_Measure_Rec.Last_Updated_By := l_user_id;
  l_Measure_Rec.Last_Update_Login := l_login_id;

  l_Measure_Rec.Last_Update_Date := p_Measure_Rec.Last_Update_Date;
  IF (l_Measure_Rec.Last_Update_Date IS NULL) THEN
    l_Measure_Rec.Last_Update_Date := SYSDATE;
  END IF;

  Update bis_indicators
  set
    SHORT_NAME        = l_Measure_Rec.Measure_Short_Name
  , UOM_Class         = l_Measure_Rec.Unit_Of_Measure_Class
  , ACTUAL_DATA_SOURCE_TYPE = l_Measure_Rec.Actual_Data_Source_Type
  , ACTUAL_DATA_SOURCE      = l_Measure_Rec.Actual_Data_Source
  , FUNCTION_NAME           = l_Measure_Rec.Function_Name
  , COMPARISON_SOURCE       = l_Measure_Rec.Comparison_Source
  , INCREASE_IN_MEASURE     = l_Measure_Rec.Increase_In_Measure
  , ENABLE_LINK             = NVL(l_Measure_Rec.Enable_Link, 'N')
  , ENABLED                 = l_Measure_Rec.enabled -- #3031053
  , OBSOLETE                = l_Measure_Rec.Obsolete --3865711
  , MEASURE_TYPE            = l_Measure_Rec.Measure_Type
  , LAST_UPDATE_DATE  = l_Measure_Rec.Last_Update_Date
  , LAST_UPDATED_BY   = l_user_id
  , LAST_UPDATE_LOGIN = l_login_id
  where INDICATOR_ID = l_Measure_Rec.Measure_Id;

  BIS_MEASURE_PVT.Translate_measure
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Measure_Rec       => l_Measure_Rec
  , p_owner             => p_owner
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

  -- delete all the dimension links and reinsert the new ones
  delete from bis_indicator_dimensions
  where indicator_id = l_measure_rec.Measure_id;

  Create_Indicator_Dimensions(l_measure_rec,p_owner,x_return_status,x_error_tbl);

/*ankgoel: bug#3583357
  Added for re-sequencing the dimensions for old style ldt upload
  with org and time levels.
*/
  IF (l_count > 0) THEN
    BIS_PMF_MIGRATION_PVT.resequence_ind_dimensions(l_Measure_Rec.Measure_Id);
  END IF;

--2465354
  l_application_rec.Application_id := l_Measure_Rec.Application_Id;
  IF (NVL(l_application_rec.Application_id,-1) <> -1 ) THEN
    l_own_appl := FND_API.G_TRUE;
  END IF;

Update_Application_Measure
( p_api_version        => p_api_version
, p_commit             => p_commit
, p_Measure_rec        => l_Measure_rec
, p_application_rec    => l_application_rec
, p_owning_application => l_own_appl
, p_owner              => p_owner
, x_return_status      => x_return_status
, x_error_Tbl          => x_error_Tbl
);
--2465354


  -- rpenneru 12/22/04 Update Functional Area short name in Measure Extension
  IF (p_Measure_Rec.Func_Area_Short_Name IS NOT NULL ) THEN
    l_Measure_Rec.Func_Area_Short_Name := p_Measure_Rec.Func_Area_Short_Name;
    Load_Measure_Extension
    ( p_api_version       => p_api_version
      ,p_commit           => p_commit
      , p_Measure_Rec     => l_Measure_rec
      , p_owner           => p_owner
      , x_return_status   => l_Return_Status
      , x_error_Tbl       => x_error_Tbl
    );
    IF (l_return_status IS NOT NULL AND l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Measure;

--
--
--Overload Update_Measure so that old data model ldts can be uploaded using
--The latest lct file. The lct file can call Load_Measure which calls this
--by passing in Org and Time dimension short_names also
Procedure Update_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_Org_Dimension_ID  IN  NUMBER
, p_Time_Dimension_ID IN  NUMBER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_user_id          number;
  l_login_id         number;
  l_Measure_Rec      BIS_MEASURE_PUB.Measure_Rec_Type;
  l_Measure_Rec_Orig BIS_MEASURE_PUB.Measure_Rec_Type;
  l_count            NUMBER := 0;
  l_Measure_Id       NUMBER;
  l_application_rec  BIS_APPLICATION_PVT.Application_rec_type; --2465354
  l_own_appl         VARCHAR2(100) := FND_API.G_FALSE  ; --2465354
  l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
--  l_measure_rec := p_measure_rec;

  Validate_Measure( p_api_version
          , p_validation_level
          , p_Measure_Rec
                  , p_owner
          , x_return_status
          , x_error_Tbl
                  );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --added this call to validate Org Dimension
  BIS_MEASURE_VALIDATE_PVT.Validate_Dimension_Id
    ( p_api_version           => p_api_version
    , p_dimension_id          => p_Org_Dimension_ID
    , p_dimension_short_name  => FND_API.G_MISS_CHAR
    , x_return_status         => x_return_status
    , x_error_Tbl             => x_error_Tbl
    );
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --added this call to validate Time Dimension
  BIS_MEASURE_VALIDATE_PVT.Validate_Dimension_Id
    ( p_api_version           => p_api_version
    , p_dimension_id          => p_Time_Dimension_ID
    , p_dimension_short_name  => FND_API.G_MISS_CHAR
    , x_return_status         => x_return_status
    , x_error_Tbl             => x_error_Tbl
    );
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  BIS_MEASURE_PVT.Retrieve_Measure
  ( p_api_version   => 1.0
  , p_Measure_Rec   => p_Measure_Rec
  , p_all_info      => FND_API.G_FALSE
  , x_Measure_Rec   => l_measure_rec_Orig
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

  l_Measure_Id := l_measure_rec_Orig.measure_id;

  if (l_measure_id is NOT NULL) then
    --added the first condition
    if (p_Measure_Rec.Measure_Id  is NULL or l_measure_id <> p_Measure_Rec.Measure_Id) then
      --added last two params
      --changed error message-used to be 'BIS_MEASURE_SHORT_NAME_UNIQUE'
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_MEASURE_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;
  --
  BIS_TARGET_LEVEL_PVT.Count_Target_Levels( p_api_version   =>1.0
                      , p_Measure_Rec   =>p_Measure_Rec
                      , x_count         =>l_count
                      , x_return_status =>x_return_status
                      , x_error_Tbl     =>x_error_Tbl
                      );

  IF (  (l_count > 0) AND
        ( NVL(l_Measure_Rec_Orig.dimension1_id,1) <> NVL(p_Measure_Rec.dimension1_id,1) OR
          NVL(l_Measure_Rec_Orig.dimension2_id,2) <> NVL(p_Measure_Rec.dimension2_id,2) OR
          NVL(l_Measure_Rec_Orig.dimension3_id,3) <> NVL(p_Measure_Rec.dimension3_id,3) OR
          NVL(l_Measure_Rec_Orig.dimension4_id,4) <> NVL(p_Measure_Rec.dimension4_id,4) OR
          NVL(l_Measure_Rec_Orig.dimension5_id,5) <> NVL(p_Measure_Rec.dimension5_id,5) OR
          NVL(l_Measure_Rec_Orig.dimension6_id,6) <> NVL(p_Measure_Rec.dimension6_id,6) OR
          NVL(l_Measure_Rec_Orig.dimension7_id,7) <> NVL(p_Measure_Rec.dimension7_id,7)
        )
     ) THEN
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_NO_DIMENSION_CHANGE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- retrieve record from database and apply changes


  Update_Measure_Rec_Total -- 2664898
  ( p_Measure_Rec_orig  => l_Measure_Rec_Orig
  , p_Measure_Rec_new   => p_Measure_Rec
  , x_Measure_Rec       => l_Measure_Rec
  );


  l_user_id := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_login_id := fnd_global.LOGIN_ID;

  l_Measure_Rec.Last_Update_Date := p_Measure_Rec.Last_Update_Date;
  IF (l_Measure_Rec.Last_Update_Date IS NULL) THEN
    l_Measure_Rec.Last_Update_Date := SYSDATE;
  END IF;

  Update bis_indicators
  set
    SHORT_NAME        = l_Measure_Rec.Measure_Short_Name
  , UOM_Class         = l_Measure_Rec.Unit_Of_Measure_Class -- Fix for 2167619 starts here
  , ACTUAL_DATA_SOURCE_TYPE = l_Measure_Rec.Actual_Data_Source_Type
  , ACTUAL_DATA_SOURCE     = l_Measure_Rec.Actual_Data_Source
  , FUNCTION_NAME     = l_Measure_Rec.Function_Name
  , COMPARISON_SOURCE = l_Measure_Rec.Comparison_Source
  , INCREASE_IN_MEASURE = l_Measure_Rec.Increase_In_Measure  -- Fix for 2167619 ends here
  , ENABLE_LINK       = NVL(l_Measure_Rec.Enable_Link, 'N') -- 2440739
  , ENABLED           = l_Measure_Rec.enabled -- 3031053
  , OBSOLETE          = l_Measure_Rec.Obsolete --3865711
  , MEASURE_TYPE          = l_Measure_Rec.Measure_Type
  , LAST_UPDATE_DATE  = l_Measure_Rec.Last_Update_Date
  , LAST_UPDATED_BY   = l_user_id
  , LAST_UPDATE_LOGIN = l_login_id
  where INDICATOR_ID = l_Measure_Rec.Measure_Id;

  BIS_MEASURE_PVT.Translate_measure
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Measure_Rec       => l_Measure_Rec
  , p_owner             => p_owner
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

  -- delete all the dimension links and reinsert the new ones
  delete from bis_indicator_dimensions
  where indicator_id = l_measure_rec.Measure_id;

  --Changed the call to call the overloaded api with Org and Time
  Create_Indicator_Dimensions
  ( p_Measure_Rec =>l_measure_rec
  , p_Org_Dimension_ID => p_Org_Dimension_ID
  , p_Time_Dimension_ID => p_Time_Dimension_ID
  , p_owner         => p_owner
  , x_return_status => x_return_status
  , x_error_tbl =>  x_error_tbl
  );

--2465354
  l_application_rec.Application_id := l_Measure_Rec.Application_Id;
  IF (NVL(l_application_rec.Application_id,-1) <> -1 ) THEN
    l_own_appl := FND_API.G_TRUE;
  END IF;

Update_Application_Measure
( p_api_version        => p_api_version
, p_commit             => p_commit
, p_Measure_rec        => l_Measure_rec
, p_application_rec    => l_application_rec
, p_owning_application => l_own_appl
, p_owner              => p_owner
, x_return_status      => x_return_status
, x_error_Tbl          => x_error_Tbl
);
--2465354

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Measure;

--
-- PLEASE VERIFY COMMENT BELOW
-- deletes one Measure if
-- 1) no Measure levels, targets exist and
-- 2) the Measure access has not been granted to a resonsibility
-- 3) no users have selected to see actuals for the Measure
--
Procedure Delete_Measure
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_count number;
l_dcount number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BIS_Target_Level_PVT.Count_Target_Levels( p_api_version
                      , p_Measure_Rec
                      , l_count
                      , x_return_status
                      , x_error_Tbl
                                          );
  if (l_count > 0) then
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_NO_DELETE_MEASURE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Delete_Measure'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

    RAISE FND_API.G_EXC_ERROR;
  end if;

  --added the select and the count check
  select count(1) into l_dcount from bis_application_measures
   where indicator_id = p_Measure_Rec.Measure_Id;
  IF(l_dcount = 0) then
     l_error_tbl := x_error_tbl ;
     BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_MEASURE_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Delete_Measure'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;
---

  delete from bis_application_measures
    where indicator_id = p_Measure_Rec.Measure_Id;

  -- mdamle 4/23/2003 - PMD - Measure Definer - When a measure is created
  -- from PMD, dimensions will not be created within those pages. Hence, add the check.
  select count(1) into l_dcount from bis_indicator_dimensions
    where indicator_id = p_Measure_Rec.Measure_Id;
  if (l_dcount > 0) then
    delete from bis_indicator_dimensions
      where indicator_id = p_Measure_Rec.Measure_Id;
  end if;

  delete from bis_indicators_tl
    where indicator_id = p_Measure_Rec.Measure_Id;

  delete from bis_indicators
    where indicator_id = p_Measure_Rec.Measure_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Measure;
--
--
Procedure Translate_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Translate_Measure
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Measure_Rec       => p_Measure_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );
--commented RAISE
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Translate_Measure'
     , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Translate_Measure;
--
--
Procedure Translate_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id           NUMBER;
l_login_id          NUMBER;
l_count             NUMBER := 0;
--l_Measure_Id        NUMBER;
l_measure_rec       BIS_MEASURE_PUB.Measure_Rec_Type;
l_Measure_Rec_Orig  BIS_MEASURE_PUB.Measure_Rec_Type;
l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_measure_rec := p_measure_rec;
  --
  BIS_MEASURE_PVT.Retrieve_Measure
  ( p_api_version   => 1.0
  , p_Measure_Rec   => l_Measure_Rec
  , p_all_info      => FND_API.G_FALSE
  , x_Measure_Rec   => l_measure_rec_Orig
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

  Validate_Measure( p_api_version
          , p_validation_level
          , l_measure_rec_orig
                  , p_owner
          , x_return_status
          , x_error_Tbl
                  );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*
  if (l_measure_rec_Orig.measure_id is NOT NULL) then
    if (l_measure_rec_Orig.measure_id <> p_Measure_Rec.Measure_Id) then
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_MEASURE_SHORT_NAME_UNIQUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Measure'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  -- retrieve record from database and apply changes
  UpdateMeasureRec
  ( p_Measure_Rec  => p_Measure_Rec
  , p_Measure_Rec1 => l_Measure_Rec_Orig
  , x_Measure_Rec  => l_Measure_Rec
  );
*/
  --

  l_user_id := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);

  l_login_id := fnd_global.LOGIN_ID;
  --

  Update bis_INDICATORS_TL
  set
    NAME              = l_Measure_Rec.Measure_Name
  , DESCRIPTION       = l_Measure_Rec.description
  , LAST_UPDATE_DATE  = l_Measure_Rec.Last_Update_Date
  , LAST_UPDATED_BY   = l_user_id
  , LAST_UPDATE_LOGIN = l_login_id
  , SOURCE_LANG       = userenv('LANG')
  where INDICATOR_ID = l_Measure_Rec_orig.Measure_Id
  and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Measure'
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Translate_Measure;
--
-- Validates measure
PROCEDURE Validate_Measure
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error     VARCHAR2(10) := FND_API.G_FALSE;
l_error_Tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
l_region_code     varchar2(30);
l_pos         number;
l_source_column   varchar2(30);
BEGIN

  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Validate_Dimension1_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Validate_Dimension2_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
  END;

  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Validate_Dimension3_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
 -- EXCEPTION
   -- when FND_API.G_EXC_ERROR then
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Validate_Dimension4_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;


  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Validate_Dimension5_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
 -- EXCEPTION
   -- when FND_API.G_EXC_ERROR then
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Validate_Dimension6_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Validate_Dimension7_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

-- Fix for 1850860 starts here
  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Val_Actual_Data_Sour_Type_Wrap
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;
--

  -- mdamle 08/20/2003 - Source column must be selected if a data source is selected.
  l_pos := instr(p_measure_rec.actual_data_source, '.');
  if (l_pos > 0) then
    l_region_code := substr(p_measure_rec.actual_data_source, 1, instr(p_measure_rec.actual_data_source, '.') -1);
    l_source_column := substr(p_measure_rec.actual_data_source, instr(p_measure_rec.actual_data_source, '.') +1);
  else
    l_region_code := p_measure_rec.actual_data_source;
    l_source_column := null;
  end if;

  if (l_region_code is not null and l_source_column is null) then
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_SOURCE_COLUMN_ERR_TXT'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;


IF p_owner  = BIS_UTILITIES_PUB.G_CUSTOM_OWNER THEN --2240105
  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Val_Actual_Data_Sour_Wrap
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;
--
  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Val_Func_Name_Wrap
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;
--
  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Val_Comparison_Source_Wrap
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;
--
END IF;   -- 2240105
  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Val_Incr_In_Measure_Wrap
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;
-- Fix for 1850860 ends here
-- 2440739
  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Val_Enable_Link_Wrap
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;
-- 2440739

-- Need to add for ENABLED Column ?
-- 3031053
  BEGIN
    BIS_MEASURE_VALIDATE_PVT.Val_Enabled_Wrap
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;
-- 3031053
  BEGIN --3865711
    BIS_MEASURE_VALIDATE_PVT.Val_Obsolete_Wrap
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

 BEGIN
    BIS_MEASURE_VALIDATE_PVT.Val_Measure_Type_Wrap
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Rec      => p_MEASURE_Rec
    , x_return_status    => x_return_status
    , x_error_Tbl        => l_error_Tbl
    );
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  if (l_error = FND_API.G_TRUE) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_Tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Measure'
       , p_error_table       => l_error_Tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Measure;
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Measure_Rec IN  BIS_Measure_PUB.Measure_Rec_Type
, x_Measure_Rec IN OUT NOCOPY BIS_Measure_PUB.Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_convert VARCHAR2(32000);
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_Measure_Rec := p_Measure_Rec;

  if (BIS_UTILITIES_PUB.Value_Missing
         (x_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(x_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) then
    BEGIN
      BIS_Measure_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Measure_Short_Name
      , x_Measure_Rec.Measure_Name
      , x_Measure_Rec.Measure_ID
      , x_return_status
      , x_error_Tbl
      );
  --changed this to if
   -- EXCEPTION
     -- WHEN FND_API.G_EXC_ERROR then
       -- NULL;
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
              RAISE FND_API.G_EXC_ERROR;
       end if;
    END;
  end if;

 l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension1_ID
                            , x_Measure_Rec.Dimension1_Short_Name
                            , x_Measure_Rec.Dimension1_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension1_Short_Name
      , x_Measure_Rec.Dimension1_Name
      , x_Measure_Rec.Dimension1_ID
      , x_return_status
      , x_error_Tbl
      );

  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
     --   NULL;
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         RAISE FND_API.G_EXC_ERROR;
      end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension2_ID
                            , x_Measure_Rec.Dimension2_Short_Name
                            , x_Measure_Rec.Dimension2_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension2_Short_Name
      , x_Measure_Rec.Dimension2_Name
      , x_Measure_Rec.Dimension2_ID
      , x_return_status
      , x_error_Tbl
      );
  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
    --    NULL;
     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
              RAISE FND_API.G_EXC_ERROR;
       end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension3_ID
                            , x_Measure_Rec.Dimension3_Short_Name
                            , x_Measure_Rec.Dimension3_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension3_Short_Name
      , x_Measure_Rec.Dimension3_Name
      , x_Measure_Rec.Dimension3_ID
      , x_return_status
      , x_error_Tbl
      );
 --   EXCEPTION
  --    WHEN FND_API.G_EXC_ERROR then
   --     NULL;
    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
              RAISE FND_API.G_EXC_ERROR;
       end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension4_ID
                            , x_Measure_Rec.Dimension4_Short_Name
                            , x_Measure_Rec.Dimension4_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension4_Short_Name
      , x_Measure_Rec.Dimension4_Name
      , x_Measure_Rec.Dimension4_ID
      , x_return_status
      , x_error_Tbl
      );
  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
     --   NULL;
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
              RAISE FND_API.G_EXC_ERROR;
       end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension5_ID
                            , x_Measure_Rec.Dimension5_Short_Name
                            , x_Measure_Rec.Dimension5_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension5_Short_Name
      , x_Measure_Rec.Dimension5_Name
      , x_Measure_Rec.Dimension5_ID
      , x_return_status
      , x_error_Tbl
      );
  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
   --     NULL;
    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
              RAISE FND_API.G_EXC_ERROR;
       end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension6_ID
                            , x_Measure_Rec.Dimension6_Short_Name
                            , x_Measure_Rec.Dimension6_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension6_Short_Name
      , x_Measure_Rec.Dimension6_Name
      , x_Measure_Rec.Dimension6_ID
      , x_return_status
      , x_error_Tbl
      );
  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
     --   NULL;
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
              RAISE FND_API.G_EXC_ERROR;
       end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension7_ID
                            , x_Measure_Rec.Dimension7_Short_Name
                            , x_Measure_Rec.Dimension7_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension7_Short_Name
      , x_Measure_Rec.Dimension7_Name
      , x_Measure_Rec.Dimension7_ID
      , x_return_status
      , x_error_Tbl
      );
  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
    --    NULL;
     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
              RAISE FND_API.G_EXC_ERROR;
       end if;
    END;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_ID_Conversion;

PROCEDURE Value_ID_Conversion
( p_api_version        IN  NUMBER
, p_Measure_Short_Name IN  VARCHAR2
, p_Measure_Name       IN  VARCHAR2
, x_Measure_ID         OUT NOCOPY NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_error_Tbl          OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  if (BIS_UTILITIES_PUB.Value_Not_Missing(p_Measure_Short_Name)
                       = FND_API.G_TRUE) then
    SELECT Measure_id into x_Measure_ID
    FROM bisbv_Performance_Measures
    WHERE Measure_short_name = p_Measure_Short_Name;
  elsif (BIS_UTILITIES_PUB.Value_Not_Missing(p_Measure_Name)
                       = FND_API.G_TRUE) then
    SELECT Measure_id into x_Measure_ID
    FROM bisbv_Performance_Measures
    WHERE Measure_name = p_Measure_Name;
  else
    -- POLPULATE ERROR TABLE
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_NAME_SHORT_NAME_MISSING'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

    RAISE FND_API.G_EXC_ERROR;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_ID_Conversion;
--

--new procedure to to value id conversion only for measure
PROCEDURE Measure_Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Measure_Rec IN  BIS_Measure_PUB.Measure_Rec_Type
, x_Measure_Rec OUT NOCOPY BIS_Measure_PUB.Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_convert VARCHAR2(32000);
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_Measure_Rec := p_Measure_Rec;

  if (BIS_UTILITIES_PUB.Value_Missing
         (x_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(x_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) then
    BEGIN
      BIS_Measure_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Measure_Short_Name
      , x_Measure_Rec.Measure_Name
      , x_Measure_Rec.Measure_ID
      , x_return_status
      , x_error_Tbl
      );
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_MEASURE_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Measure_Value_ID_Conversion'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
          RAISE FND_API.G_EXC_ERROR;
       end if;
    END;
  end if;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Measure_Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Measure_Value_ID_Conversion;
--

--new procedure to to value id conversion only for dimension
PROCEDURE Dimension_Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Measure_Rec IN  BIS_Measure_PUB.Measure_Rec_Type
, x_Measure_Rec IN OUT NOCOPY BIS_Measure_PUB.Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_convert VARCHAR2(32000);
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_Measure_Rec := p_Measure_Rec;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension1_ID
                            , x_Measure_Rec.Dimension1_Short_Name
                            , x_Measure_Rec.Dimension1_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension1_Short_Name
      , x_Measure_Rec.Dimension1_Name
      , x_Measure_Rec.Dimension1_ID
      , x_return_status
      , x_error_Tbl
      );

  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
     --   NULL;
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
        l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Dimension_Value_ID_Conversion'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension2_ID
                            , x_Measure_Rec.Dimension2_Short_Name
                            , x_Measure_Rec.Dimension2_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension2_Short_Name
      , x_Measure_Rec.Dimension2_Name
      , x_Measure_Rec.Dimension2_ID
      , x_return_status
      , x_error_Tbl
      );
  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
    --    NULL;
     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
        l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Dimension_Value_ID_Conversion'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension3_ID
                            , x_Measure_Rec.Dimension3_Short_Name
                            , x_Measure_Rec.Dimension3_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension3_Short_Name
      , x_Measure_Rec.Dimension3_Name
      , x_Measure_Rec.Dimension3_ID
      , x_return_status
      , x_error_Tbl
      );
 --   EXCEPTION
  --    WHEN FND_API.G_EXC_ERROR then
   --     NULL;
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Dimension_Value_ID_Conversion'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension4_ID
                            , x_Measure_Rec.Dimension4_Short_Name
                            , x_Measure_Rec.Dimension4_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension4_Short_Name
      , x_Measure_Rec.Dimension4_Name
      , x_Measure_Rec.Dimension4_ID
      , x_return_status
      , x_error_Tbl
      );
  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
     --   NULL;
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Dimension_Value_ID_Conversion'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension5_ID
                            , x_Measure_Rec.Dimension5_Short_Name
                            , x_Measure_Rec.Dimension5_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension5_Short_Name
      , x_Measure_Rec.Dimension5_Name
      , x_Measure_Rec.Dimension5_ID
      , x_return_status
      , x_error_Tbl
      );
  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
   --     NULL;
    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
        l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Dimension_Value_ID_Conversion'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension6_ID
                            , x_Measure_Rec.Dimension6_Short_Name
                            , x_Measure_Rec.Dimension6_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension6_Short_Name
      , x_Measure_Rec.Dimension6_Name
      , x_Measure_Rec.Dimension6_ID
      , x_return_status
      , x_error_Tbl
      );
  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
     --   NULL;
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Dimension_Value_ID_Conversion'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
       end if;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Measure_Rec.Dimension7_ID
                            , x_Measure_Rec.Dimension7_Short_Name
                            , x_Measure_Rec.Dimension7_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Measure_Rec.Dimension7_Short_Name
      , x_Measure_Rec.Dimension7_Name
      , x_Measure_Rec.Dimension7_ID
      , x_return_status
      , x_error_Tbl
      );
  --  EXCEPTION
   --   WHEN FND_API.G_EXC_ERROR then
    --    NULL;
     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
        l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Dimension_Value_ID_Conversion'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END;
  end if;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Dimension_Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Dimension_Value_ID_Conversion;
--


Procedure Retrieve_Measure_Dimensions
( p_api_version   IN  NUMBER
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_dimension_Tbl OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

i NUMBER := 0;
l_dimension_rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
l_dimension_rec_p BIS_DIMENSION_PUB.Dimension_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

cursor ind_dim(p_measure_id  number) is
   select id.dimension_id
   from   bis_indicator_dimensions id
   where  id.indicator_id = p_measure_id
   order  by id.sequence_no;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  for indim in ind_dim(p_measure_rec.measure_id) loop

     i := i+1;
     l_dimension_rec.dimension_id := indim.dimension_id;

     l_dimension_rec_p := l_dimension_rec;
     BIS_DIMENSION_PUB.Retrieve_Dimension
     ( p_api_version   => 1.0
     , p_Dimension_Rec => l_dimension_rec_p
     , x_Dimension_Rec => l_dimension_rec
     , x_return_status => x_return_status
     , x_error_Tbl     => x_error_Tbl
     );

     x_dimension_Tbl(i) := l_dimension_rec;

  end loop;

   if (i = 0) then
     l_error_tbl := x_error_tbl;
     BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_MEASURE_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measure_Dimensions'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  IF ind_dim%ISOPEN THEN CLOSE ind_dim; END IF;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF ind_dim%ISOPEN THEN CLOSE ind_dim; END IF;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF ind_dim%ISOPEN THEN CLOSE ind_dim; END IF;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF ind_dim%ISOPEN THEN CLOSE ind_dim; END IF;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF ind_dim%ISOPEN THEN CLOSE ind_dim; END IF;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measure_Dimensions'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Measure_Dimensions;
--
--
PROCEDURE Retrieve_Last_Update_Date
( p_api_version      IN  NUMBER
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_last_update_date OUT NOCOPY DATE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Measure_Rec.Measure_ID)
      = FND_API.G_TRUE
   AND BIS_UTILITIES_PUB.Value_Not_NULL(p_Measure_Rec.Measure_ID)
      = FND_API.G_TRUE
    ) THEN
    SELECT NVL(LAST_UPDATE_DATE, CREATION_DATE)
    INTO x_last_update_date
    FROM bis_indicators
    WHERE INDICATOR_ID = p_Measure_Rec.Measure_ID;
  END IF;
  --

--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     --added this message
     l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_MEASURE_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Last_Update_Date'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status := FND_API.G_RET_STS_ERROR;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Last_Update_Date'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Retrieve_Last_Update_Date;
--
--
PROCEDURE Lock_Record
( p_api_version   IN  NUMBER
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_timestamp     IN  VARCHAR  := NULL
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_form_date        DATE;
l_last_update_date DATE;
l_Measure_Rec      BIS_MEASURE_PUB.Measure_Rec_Type;
l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  l_Measure_Rec.Measure_Id := p_Measure_Rec.Measure_Id;
  BIS_MEASURE_PVT.Retrieve_Last_Update_Date
                 ( p_api_version      => 1.0
                 , p_Measure_Rec      => p_Measure_Rec
                 , x_last_update_date => l_last_update_date
                 , x_return_status    => x_return_status
                 , x_error_Tbl        => x_error_Tbl
                 );
  IF(p_timestamp IS NOT NULL) THEN
    l_form_date := TO_DATE(p_timestamp, BIS_UTILITIES_PVT.G_DATE_FORMAT);
    IF(l_form_date = l_last_update_date) THEN
      x_return_status := FND_API.G_TRUE;
    ELSE
      x_return_status := FND_API.G_FALSE;
    END IF;
  ELSE
    x_return_status := FND_API.G_FALSE;
  END IF;
  --

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Lock_Record'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Lock_Record;
--
--
-- APIS to handle Applicaiton measures
--
--
--
--
--
PROCEDURE Create_Application_Measure
( p_api_version             IN  NUMBER
, p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_rec             IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_application_rec         IN  BIS_Application_PVT.Application_Rec_Type
, p_owning_application      IN  VARCHAR2
, p_owner                   IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status           OUT NOCOPY VARCHAR2
, x_error_Tbl               OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--   l_error_count    number;
   l_rec BIS_APPLICATION_MEASURE_PVT.Application_Measure_Rec_type;
   l_error_tbl    BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_rec.Measure_id         := p_Measure_rec.Measure_id;
  l_rec.Application_id     := p_application_rec.application_id;
  l_rec.owning_application := p_owning_application;
  l_rec.Created_By         := p_Measure_rec.Created_By;
  l_rec.Last_Updated_By    := p_Measure_rec.Last_Updated_By;
  l_rec.Last_Update_Login  := p_Measure_rec.Last_Update_Login;

--  htp.header(2,'POINT 2 CREATE_APPLICATION_MEASURE');
--  BIS_ERROR_MESSAGE_PVT.get_error_count(l_error_count,x_return_status,x_error_tbl);
--  htp.header(3,'Error Count = ' || l_error_count);

  BIS_APPLICATION_MEASURE_PVT.Create_Application_Measure
    ( p_api_version               => p_api_version
      , p_commit                  =>  p_commit
      , p_Application_Measure_Rec => l_rec
      , p_owner                   => p_owner
      , x_return_status           =>  x_return_status
      , x_error_tbl               => x_error_tbl
      );

--  htp.header(2,'POINT 3 CREATE_APPLICATION_MEASURE');
--  BIS_ERROR_MESSAGE_PVT.get_error_count(l_error_count,x_return_status,x_error_tbl);
--  htp.header(3,'Error Count = ' || l_error_count);

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
--      htp.header(2,'EXCEPTION 2 CREATE_APPLICATION_MEASURE');
--      BIS_ERROR_MESSAGE_PVT.get_error_count(l_error_count,x_return_status,x_error_tbl);
--      htp.header(3,'Error Count = ' || l_error_count);

      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Application_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Create_Application_Measure;
--
--
PROCEDURE Retrieve_Application_Measures
( p_api_version     IN  NUMBER
, p_Measure_Rec     IN  BIS_Measure_PUB.Measure_Rec_Type
, p_all_info        IN  VARCHAR2
, x_owning_Application_rec OUT NOCOPY BIS_Application_PVT.Application_Rec_Type
, x_Application_tbl OUT NOCOPY BIS_Application_PVT.Application_Tbl_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_tbl BIS_Application_Measure_PVT.Application_Measure_Tbl_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BIS_APPLICATION_MEASURE_PVT.Retrieve_Application_Measures( p_api_version
                               , p_Measure_Rec                                                                , p_all_info
                                                           , l_tbl
                                                           , x_return_status
                                                           , x_error_Tbl
                                                           );

  for i in 1 .. l_tbl.COUNT LOOP
    x_Application_tbl(i).Application_id := l_tbl(i).Application_id;
    x_Application_tbl(i).Application_short_name :=
                                              l_tbl(i).Application_short_name;
    x_Application_tbl(i).Application_name := l_tbl(i).Application_name;

    if (l_tbl(i).owning_application = FND_API.G_TRUE) then
      x_owning_Application_rec := x_Application_tbl(i);
    end if;
  END LOOP;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Application_Measures'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Retrieve_Application_Measures;
--
--
PROCEDURE Update_Application_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_application_rec  IN  BIS_Application_PVT.Application_Rec_Type
, p_owning_application      IN  VARCHAR2
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_rec BIS_APPLICATION_MEASURE_PVT.Application_Measure_Rec_type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_rec.Measure_id         := p_Measure_rec.Measure_id;
  l_rec.Application_id     := p_application_rec.application_id;
  l_rec.owning_application := p_owning_application;

  BIS_APPLICATION_MEASURE_PVT.Update_Application_Measure( p_api_version
                                                        , p_commit
                                                        , l_rec
                                                        , p_owner
                                                        , x_return_status
                                                        , x_error_tbl
                                                        );
--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Application_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Update_Application_Measure;
--
--
PROCEDURE Delete_Application_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_application_rec  IN  BIS_Application_PVT.Application_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_rec BIS_APPLICATION_MEASURE_PVT.Application_Measure_Rec_type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_rec.Measure_id         := p_Measure_rec.Measure_id;
  l_rec.Application_id     := p_application_rec.application_id;

  BIS_APPLICATION_MEASURE_PVT.Delete_Application_Measure( p_api_version
                                                        , p_commit
                                                        , l_rec
                                                        , x_return_status
                                                        , x_error_tbl
                                                        );

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Application_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Delete_Application_Measure;
--
PROCEDURE Delete_Application_Measures
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_rec BIS_APPLICATION_PVT.Application_Rec_type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- we should call the delete API on BIS_APPLICATION_MEASURE
  -- but this is much faster

  delete from bis_application_measures
  where indicator_id = p_Measure_rec.Measure_id;

  l_rec.Application_id := -1;

  Create_Application_Measure
  ( p_api_version        => p_api_version
   ,p_commit             => p_commit
   ,p_Measure_rec        => p_Measure_rec
   ,p_application_rec    => l_rec
   ,p_owning_application => FND_API.G_FALSE
   ,x_return_status      => x_return_status
   ,x_error_Tbl          => x_error_Tbl
  );

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Application_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Delete_Application_Measures;
--
PROCEDURE Lock_Record
( p_api_version      IN  NUMBER
, p_Measure_rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_application_rec  IN  BIS_Application_PVT.Application_Rec_Type
, p_timestamp        IN  VARCHAR  := NULL
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_rec BIS_APPLICATION_MEASURE_PVT.Application_Measure_Rec_type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_rec.Measure_id         := p_Measure_rec.Measure_id;
  l_rec.Application_id     := p_application_rec.application_id;

  BIS_APPLICATION_MEASURE_PVT.Lock_record( p_api_version
                                         , l_rec
                                         , p_timestamp
                                         , x_return_status
                                         , x_error_tbl
                                         );
--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Lock_Record'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Lock_Record;
--
PROCEDURE Retrieve_Last_Update_Date
( p_api_version      IN  NUMBER
, p_Measure_rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_application_rec  IN  BIS_Application_PVT.Application_Rec_Type
, x_last_update_date OUT NOCOPY DATE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_rec BIS_APPLICATION_MEASURE_PVT.Application_Measure_Rec_type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_rec.Measure_id         := p_Measure_rec.Measure_id;
  l_rec.Application_id     := p_application_rec.application_id;

  BIS_APPLICATION_MEASURE_PVT.Retrieve_Last_Update_Date( p_api_version
                                                   , l_rec
                                                   , x_last_update_date
                                                   , x_return_status
                                                   , x_error_tbl
                                                       );
--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Last_Update_Date'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Retrieve_Last_Update_Date;
--

FUNCTION IS_OLD_DATA_MODEL
( p_Measure_rec    IN BIS_MEASURE_PUB.MEASURE_REC_TYPE
 ,p_Org_Dimension_Id IN NUMBER
 ,p_Time_Dimension_Id IN NUMBER
)
RETURN BOOLEAN
IS
  l_org_time_exists   BOOLEAN;

BEGIN
  -- IF either org or time exists then return true here. As it should never
  -- happen that, only org got migrated and not time
  l_org_time_exists := TRUE;

  IF (BIS_UTILITIES_PUB.Value_Missing(p_Org_Dimension_Id) = FND_API.G_TRUE
   OR BIS_UTILITIES_PUB.Value_NULL(p_Org_Dimension_Id)  = FND_API.G_TRUE)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;

  IF (BIS_UTILITIES_PUB.Value_Missing(p_Time_Dimension_Id) = FND_API.G_TRUE
   OR BIS_UTILITIES_PUB.Value_NULL(p_Time_Dimension_Id)  = FND_API.G_TRUE)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;


  IF (p_Org_Dimension_Id = p_Measure_rec.Dimension1_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Org_Dimension_Id = p_Measure_rec.Dimension2_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Org_Dimension_Id = p_Measure_rec.Dimension3_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Org_Dimension_Id = p_Measure_rec.Dimension4_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Org_Dimension_Id = p_Measure_rec.Dimension5_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Org_Dimension_Id = p_Measure_rec.Dimension6_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Org_Dimension_Id = p_Measure_rec.Dimension7_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Time_Dimension_Id = p_Measure_rec.Dimension1_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Time_Dimension_Id = p_Measure_rec.Dimension2_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Time_Dimension_Id = p_Measure_rec.Dimension3_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Time_Dimension_Id = p_Measure_rec.Dimension4_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (p_Time_Dimension_Id = p_Measure_rec.Dimension5_Id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF p_Time_Dimension_Id = p_Measure_rec.Dimension6_Id
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF p_Time_Dimension_Id = p_Measure_rec.Dimension7_Id
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  <<returnfromproc>>
  RETURN l_org_time_exists;
END ;


PROCEDURE updt_pm_owner(p_pm_short_name  IN VARCHAR2
                       ,x_return_status OUT NOCOPY VARCHAR2) AS
  CURSOR c_updt1 IS
   SELECT indicator_id
   FROM bis_indicators
   WHERE short_name = p_pm_short_name FOR UPDATE OF last_updated_by , created_by;

   l_pm_count NUMBER := 0;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  FOR i IN c_updt1 LOOP

    l_pm_count := l_pm_count + 1;


    UPDATE bis_indicators SET  last_updated_by = 1 , created_by = 1
    WHERE current of c_updt1;

    UPDATE bis_indicators_tl SET last_updated_by = 1 , created_by = 1
    WHERE indicator_id = i.indicator_id;

    UPDATE bis_indicator_dimensions SET last_updated_by = 1 , created_by = 1
    WHERE indicator_id = i.indicator_id;

  END LOOP;

  if l_pm_count = 0 then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    IF c_updt1%ISOPEN THEN
      CLOSE c_updt1;
    END IF;


    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END updt_pm_owner;

--sawu: bug#3859267: common function to check if a particular ak_region_item is mapped already
FUNCTION isColumnMappedAlready(
  p_region_code         IN  Ak_Region_Items.REGION_CODE%TYPE
 ,p_region_app_id       IN  Ak_Region_Items.REGION_APPLICATION_ID%Type
 ,p_attribute_code      IN  Ak_Region_Items.ATTRIBUTE_CODE%Type
 ,p_attribute_app_id    IN  Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type
 ,x_measure_short_name  OUT NOCOPY Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE
 ,x_measure_name        OUT NOCOPY Bisbv_Performance_Measures.MEASURE_NAME%TYPE
) RETURN boolean IS
  l_result      boolean := false;
  l_attribute1  Ak_Region_Items.Attribute1%Type;
  l_attribute2  Bisbv_Performance_Measures.MEASURE_NAME%TYPE;
BEGIN
  SELECT attribute1, attribute2 into l_attribute1, l_attribute2
  FROM Ak_Region_Items
  WHERE region_code = p_region_code
  AND region_application_id = p_region_app_id
  AND attribute_code = p_attribute_code
  AND attribute_application_id = p_attribute_app_id;

  IF (BIS_AK_REGION_PUB.IS_MEASURE_TYPE(l_attribute1)) THEN
    l_result := BIS_AK_REGION_PUB.VALIDATE_MEASURE(p_short_name => l_attribute2,
                                                   x_measure_short_name => x_measure_short_name,
                                                   x_measure_name => x_measure_name);
  ELSIF (BIS_AK_REGION_PUB.IS_COMPARE_TYPE(l_attribute1)) THEN
    l_result := BIS_AK_REGION_PUB.VALIDATE_COMPARE(p_region_code => p_region_code,
                                                   p_region_app_id => p_region_app_id,
                                                   p_compare_code => l_attribute2,
                                                   x_measure_short_name => x_measure_short_name,
                                                   x_measure_name => x_measure_name);
  END IF;

  RETURN l_result;

EXCEPTION
    WHEN others THEN RETURN false;
END isColumnMappedAlready;

-- mdamle 07/18/2003 - Check if measure is being mapped to a source
-- that's already mapped to another measure.
FUNCTION isSourceColumnMappedAlready(
  p_Measure_rec           IN            BIS_MEASURE_PUB.MEASURE_REC_TYPE
 ,x_measure_name OUT NOCOPY    Bisbv_Performance_Measures.MEASURE_NAME%TYPE
) RETURN boolean IS
  l_result              boolean := false;
  l_region_code         Ak_Region_Items.REGION_CODE%TYPE;
  l_source_column       Ak_Region_Items.ATTRIBUTE_CODE%TYPE;
  l_measure_short_name  Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE;
BEGIN
  IF (p_measure_rec.actual_data_source IS NOT NULL) THEN
    l_region_code := substr(p_measure_rec.actual_data_source, 1, instr(p_measure_rec.actual_data_source, '.') -1);
    l_source_column := substr(p_measure_rec.actual_data_source, instr(p_measure_rec.actual_data_source, '.') +1);
    l_result := isColumnMappedAlready(p_region_code => l_region_code,
                                      p_region_app_id => p_measure_rec.Region_App_Id,
                                      p_attribute_code => l_source_column,
                                      p_attribute_app_id => p_measure_rec.Source_Column_App_Id,
                                      x_measure_short_name => l_measure_short_name,
                                      x_measure_name => x_measure_name);
    --make sure current mapping is not to this measure
    IF ((l_result = true) AND (p_Measure_rec.measure_short_name = l_measure_short_name)) THEN
      l_result := false;
    END IF;
  END IF;

  RETURN l_result;

EXCEPTION
  WHEN others THEN RETURN false;
END isSourceColumnMappedAlready;

--sawu: bug#3859267: need to validate compare-to column
FUNCTION isCompareColumnMappedAlready(
  p_Measure_rec             IN          BIS_MEASURE_PUB.MEASURE_REC_TYPE
 ,x_measure_name   OUT NOCOPY  Bisbv_Performance_Measures.MEASURE_NAME%TYPE
) RETURN boolean IS
  l_result              boolean := false;
  l_region_code         Ak_Region_Items.REGION_CODE%TYPE;
  l_compare_column      Ak_Region_Items.ATTRIBUTE_CODE%TYPE;
  l_measure_short_name  Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE;
BEGIN
  IF (p_measure_rec.Comparison_Source IS NOT NULL) THEN
    l_region_code := substr(p_measure_rec.Comparison_Source, 1, instr(p_measure_rec.Comparison_Source, '.') -1);
    l_compare_column := substr(p_measure_rec.Comparison_Source, instr(p_measure_rec.Comparison_Source, '.') +1);
    l_result := isColumnMappedAlready(p_region_code => l_region_code,
                                      p_region_app_id => p_measure_rec.Region_App_Id,
                                      p_attribute_code => l_compare_column,
                                      p_attribute_app_id => p_measure_rec.Compare_Column_App_Id,
                                      x_measure_short_name => l_measure_short_name,
                                      x_measure_name => x_measure_name);
    --make sure current mapping is not to this measure
    IF ((l_result = true) AND (p_Measure_rec.measure_short_name = l_measure_short_name)) THEN
      l_result := false;
    END IF;
  END IF;

  RETURN l_result;

EXCEPTION
  WHEN others THEN RETURN false;
END isCompareColumnMappedAlready;

-- mdamle 09/25/2003 - Sync up measures for all installed languages
Procedure Translate_Measure_by_lang
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_lang              IN  VARCHAR2
, p_source_lang       IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id           NUMBER;
l_login_id          NUMBER;
l_count             NUMBER := 0;
l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  SAVEPOINT TransMeasByLangPvt;

  l_user_id := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);

  l_login_id := fnd_global.LOGIN_ID;

  Update bis_INDICATORS_TL
  set
  NAME                = p_Measure_Rec.Measure_Name
  , DESCRIPTION       = p_Measure_Rec.description
  , LAST_UPDATED_BY   = l_user_id
  , LAST_UPDATE_LOGIN = l_login_id
  , SOURCE_LANG       = p_source_lang
  where INDICATOR_ID =  p_Measure_Rec.Measure_Id
  and LANGUAGE = p_lang;

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      ROLLBACK TO TransMeasByLangPvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      ROLLBACK TO TransMeasByLangPvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      ROLLBACK TO TransMeasByLangPvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      ROLLBACK TO TransMeasByLangPvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Measure_by_lang'
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );


END Translate_Measure_by_lang;

-------------------- Get customized Enabled ----------------------
FUNCTION get_customized_enabled( p_indicator_id IN NUMBER) RETURN VARCHAR2 AS
  CURSOR c_cust IS SELECT
       ENABLED,
       USER_ID,
       APPLICATION_ID,
       RESPONSIBILITY_ID,
       ORG_ID,
       SITE_ID
       FROM BIS_IND_CUSTOMIZATIONS
     WHERE INDICATOR_ID = p_indicator_id
       AND (user_id = fnd_global.user_id
       OR  responsibility_id = fnd_global.RESP_ID
       OR  application_id = fnd_global.RESP_APPL_ID
       OR  org_id = fnd_global.ORG_ID
       OR  site_id = 0) ;
  l_bis_custom_enabled_usr      BIS_INDICATORS.enabled%TYPE;
  l_bis_custom_enabled_resp     BIS_INDICATORS.enabled%TYPE;
  l_bis_custom_enabled_appl     BIS_INDICATORS.enabled%TYPE;
  l_bis_custom_enabled_org      BIS_INDICATORS.enabled%TYPE;
  l_bis_custom_enabled_site     BIS_INDICATORS.enabled%TYPE;
BEGIN
    IF (c_cust%ISOPEN) THEN
      CLOSE c_cust;
    END IF;

    FOR cr IN c_cust LOOP
      IF (cr.user_id IS NOT NULL) THEN
        l_bis_custom_enabled_usr := cr.enabled;
      ELSIF (cr.responsibility_id IS NOT NULL) THEN
        l_bis_custom_enabled_resp := cr.enabled;
      ELSIF (cr.application_id IS NOT NULL) THEN
        l_bis_custom_enabled_appl := cr.enabled;
      ELSIF (cr.org_id IS NOT NULL) THEN
        l_bis_custom_enabled_org := cr.enabled;
      ELSIF (cr.site_id IS NOT NULL) THEN
        l_bis_custom_enabled_site := cr.enabled;
      END IF;
    END LOOP;

    IF ( l_bis_custom_enabled_usr IS NOT NULL) THEN
      RETURN l_bis_custom_enabled_usr ;
    ELSIF (l_bis_custom_enabled_resp IS NOT NULL) THEN
      RETURN l_bis_custom_enabled_resp ;
    ELSIF (l_bis_custom_enabled_appl IS NOT NULL) THEN
      RETURN l_bis_custom_enabled_appl ;
    ELSIF (l_bis_custom_enabled_org IS NOT NULL) THEN
      RETURN l_bis_custom_enabled_org ;
    ELSIF (l_bis_custom_enabled_site IS NOT NULL) THEN
      RETURN l_bis_custom_enabled_site ;
    END IF;

    RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_cust%ISOPEN) THEN
      CLOSE c_cust;
    END IF;
    RETURN NULL;
END get_customized_enabled;
---



PROCEDURE Load_Measure_Extension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
l_Return_Status   VARCHAR2(2000);
l_Msg_Count       NUMBER;
l_Msg_Data        VARCHAR2(2000);
l_Measure_Extension_Rec  BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;
l_custom_mode     VARCHAR2(6);
BEGIN

  -- rpenneru 12/20/2004 - Populate Measure Extension table
  -- Load Measure extension should be called only when LDT is uploaded,
  -- It should not be called for the UI flow
    -- Check if the Functional Area Short name, If it is null
    -- Measure will be assigned under Customer Defined Functional Area.
    l_Measure_Extension_Rec.Func_Area_Short_Name := p_Measure_Rec.Func_Area_Short_Name;
    IF (p_Measure_Rec.Func_Area_Short_Name IS NULL ) THEN
      -- bug#4447273 Don't call the load_measrue_extension
      -- when the p_Measure_Rec.Func_Area_Short_Name is NULL
      --l_Measure_Extension_Rec.Func_Area_Short_Name := 'BIS_UNN';   //Commented..
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;
    --l_Measure_Extension_Rec.Functional_Area_Id :=  BIS_OBJECT_EXTENSIONS_PVT.Get_FA_Id_By_Short_Name(p_Measure_Rec.Func_Area_Short_Name);

    l_Measure_Extension_Rec.Measure_Short_Name := p_Measure_Rec.Measure_Short_Name;
    -- rpenneru bug#4073262, As part of revert back changes bug#4153331.
    -- BIS_MEASURES_EXTENSION table will have the TL Tables. In this case Name and Description values
    -- should not be updateded to the measure extension table, if measure is uploaded from BISPMFLD.lct
    -- The value of the Name and Description from BISPMFLD.lct will be BIS_COMMON_UTILS.G_DEF_CHAR
    l_Measure_Extension_Rec.Name := BIS_COMMON_UTILS.G_DEF_CHAR;
    l_Measure_Extension_Rec.Description := BIS_COMMON_UTILS.G_DEF_CHAR;

    l_Measure_Extension_Rec.Created_By  :=  p_Measure_Rec.Created_By;
    l_Measure_Extension_Rec.Creation_Date  := p_Measure_Rec.Creation_Date;
    l_Measure_Extension_Rec.Last_Updated_By := p_Measure_Rec.Last_Updated_By;
    l_Measure_Extension_Rec.Last_Update_Date := p_Measure_Rec.Last_Update_Date;
    l_Measure_Extension_Rec.Last_Update_Login := p_Measure_Rec.Last_Update_Login;

    -- From the UI Custom Mode is FORCE  but when uploaded through LCT it is NULL
    IF ( p_owner IS NOT NULL AND p_owner <> BIS_UTILITIES_PUB.G_CUSTOM_OWNER ) THEN
      l_custom_mode := NULL;
    ELSE
      l_custom_mode := 'FORCE';
    END IF;
    BIS_OBJECT_EXTENSIONS_PUB.Load_Measure_Extension(
      p_Api_Version       => p_api_version
      ,p_Commit           => p_commit
      ,p_Meas_Extn_Rec    => l_Measure_Extension_Rec
      ,p_Custom_mode      => l_custom_mode
      ,x_Return_Status    => l_return_status
      ,x_Msg_Count        => l_Msg_Count
      ,x_Msg_Data         => l_Msg_Data
   );

    IF (l_return_status IS NOT NULL AND l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	  l_error_tbl := x_error_tbl;
 	  BIS_UTILITIES_PVT.Add_Error_Message
  	  ( p_error_msg_id         => NULL
	    , p_error_description  => l_Msg_Data
	    , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
  	    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
	    , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Measure_by_lang'
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Load_Measure_Extension;


PROCEDURE Update_Measure_Obsolete_Flag(
   p_commit                      IN VARCHAR2 := FND_API.G_FALSE,
   p_measure_short_name          IN VARCHAR2,
   p_obsolete                    IN VARCHAR2,
   x_return_status               OUT nocopy VARCHAR2,
   x_Msg_Count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT nocopy VARCHAR2
) IS
BEGIN
    SAVEPOINT MeasureObsoleteUpdate;
    IF (p_measure_short_name IS NULL OR p_measure_short_name = '') THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_PMF_INVALID_MEASURE_VALUE');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_obsolete IS NULL OR (p_obsolete <> FND_API.G_TRUE AND p_obsolete <> FND_API.G_FALSE)) THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_PMF_INVALID_OBSOLETE_FLAG');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    UPDATE bis_indicators
    SET
      obsolete = p_obsolete ,
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.USER_ID  ,
      last_update_login = FND_GLOBAL.USER_ID
    WHERE short_name = p_measure_short_name;

    IF(p_Commit = FND_API.G_TRUE) THEN
     commit;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
       ROLLBACK TO MeasureObsoleteUpdate;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BIS_FORM_FUNCTIONS_PUB.Update_Measure_Obsolete_Flag ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BIS_FORM_FUNCTIONS_PUB.Update_Measure_Obsolete_Flag ';
       END IF;
END Update_Measure_Obsolete_Flag;


END BIS_MEASURE_PVT;


/
