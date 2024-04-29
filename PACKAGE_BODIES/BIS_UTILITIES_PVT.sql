--------------------------------------------------------
--  DDL for Package Body BIS_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_UTILITIES_PVT" AS
/* $Header: BISVUTLB.pls 120.1 2005/12/28 06:06:51 ashankar noship $ */
--
G_IMG_SRC_DIR               CONSTANT VARCHAR2(100) := '/OA_MEDIA/';


G_PXC_333333_IMG_SRC  CONSTANT VARCHAR2(32000) := G_IMG_SRC_DIR||'BISPX333.gif';
G_PXC_666666_IMG_SRC  CONSTANT VARCHAR2(32000) := G_IMG_SRC_DIR||'BISPX666.gif';
G_PXC_6699CC_IMG_SRC  CONSTANT VARCHAR2(32000) := G_IMG_SRC_DIR||'BISPX69C.gif';
G_PXC_999999_IMG_SRC  CONSTANT VARCHAR2(32000) := G_IMG_SRC_DIR||'BISPX999.gif';
G_PXC_CCCCCC_IMG_SRC  CONSTANT VARCHAR2(32000) := G_IMG_SRC_DIR||'BISPXCCC.gif';
G_PXC_FFFFFF_IMG_SRC  CONSTANT VARCHAR2(32000) := G_IMG_SRC_DIR||'BISPXFFF.gif';

--R12 specific
G_PXC_B3B7BA_IMG_SRC CONSTANT VARCHAR2(32000)  := G_IMG_SRC_DIR||'BISPXB7B.gif';
G_PXC_AEDBEA_IMG_SRC CONSTANT VARCHAR2(32000)  := G_IMG_SRC_DIR||'BISPXAED.gif';


G_GREY_IMAGE_SRC            CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISPXCCC.gif';
G_LEFT_FLAT_EDGE_IMG_SRC    CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISBSQRL.gif';
G_LEFT_ROUND_EDGE_IMG_SRC   CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISBRNDL.gif';
G_RIGHT_FLAT_EDGE_IMG_SRC   CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISBSQRR.gif';
G_RIGHT_ROUND_EDGE_IMG_SRC  CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISBRNDR.gif';

--R12 specific
G_R12_LEFT_FLAT_EDGE_IMG_SRC    CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISFLATL.gif';

G_R12_RIGHT_FLAT_EDGE_IMG_SRC   CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISFLATR.gif';



G_TOP_OUTER_EDGE_IMG_SRC    CONSTANT VARCHAR2(32000) := G_PXC_333333_IMG_SRC;

G_TOP_INNER_EDGE_IMG_SRC    CONSTANT VARCHAR2(32000) := G_PXC_FFFFFF_IMG_SRC;

G_BOT_OUTER_EDGE_IMG_SRC CONSTANT VARCHAR2(32000) := G_PXC_333333_IMG_SRC;

G_BOT_INNER_EDGE_IMG_SRC CONSTANT VARCHAR2(32000) := G_PXC_666666_IMG_SRC;

--R12 specific

G_R12_TOP_OUTER_EDGE_IMG_SRC CONSTANT VARCHAR2(32000) := G_PXC_B3B7BA_IMG_SRC;
G_R12_BOT_OUTER_EDGE_IMG_SRC CONSTANT VARCHAR2(32000) := G_PXC_B3B7BA_IMG_SRC;
G_R12_BOT_INNER_EDGE_IMG_SRC CONSTANT VARCHAR2(32000) := G_PXC_AEDBEA_IMG_SRC;


G_TOP_LEFT_CURVE_IMG_SRC CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISTCLTL.gif';
G_TOP_RIGHT_CURVE_IMG_SRC CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISTCLTR.gif';
G_BOT_LEFT_CURVE_IMG_SRC CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISTCLBL.gif';
G_BOT_RIGHT_CURVE_IMG_SRC CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISTCLBR.gif';
--- NOTE: For he next four files, the BIS file has a  white background
--- and the FND CURVE HAS TRANSPARENT.
G_TOP_LEFT_BLUE_CURVE_IMG_SRC CONSTANT VARCHAR2(32000) :=
---  G_IMG_SRC_DIR||'FNDRTWTL.gif';
                                                G_IMG_SRC_DIR||'BISTCBTL.gif';
G_TOP_RIGHT_BLUE_CURVE_IMG_SRC CONSTANT VARCHAR2(32000) :=
  ---  G_IMG_SRC_DIR||'FNDRTWTR.gif';
                                               G_IMG_SRC_DIR||'BISTCBTR.gif';
G_BOT_LEFT_BLUE_IMG_SRC CONSTANT VARCHAR2(32000) :=
---  G_IMG_SRC_DIR||'BISTCBBL.gif';
                                             G_IMG_SRC_DIR||'FNDRTWBL.gif';
G_BOT_RIGHT_BLUE_IMG_SRC CONSTANT VARCHAR2(32000) :=
--- G_IMG_SRC_DIR||'BISTCBBR.gif';
                                             G_IMG_SRC_DIR||'FNDRTWBR.gif';

G_BOT_LEFT_GREY_CURVE_IMG_SRC CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISTCGBL.gif';
G_BOT_RIGHT_GREY_CURVE_IMG_SRC CONSTANT VARCHAR2(32000) :=
                                                G_IMG_SRC_DIR||'BISTCGBR.gif';

G_PXC_333333   CONSTANT VARCHAR2(1000) := '#333333';
G_PXC_666666   CONSTANT VARCHAR2(1000) := '#666666';
G_PXC_CCCCCC   CONSTANT VARCHAR2(1000) := '#CCCCCC';
G_PXC_FFFFFF   CONSTANT VARCHAR2(1000) := '#FFFFFF';
G_PXC_6699CC   CONSTANT VARCHAR2(1000) := '#6699CC';
G_PXC_999999   CONSTANT VARCHAR2(1000) := '#999999';

G_TOP_OUTER_EDGE_COLOR      CONSTANT VARCHAR2(1000) := G_PXC_333333;
G_TOP_INNER_EDGE_COLOR      CONSTANT VARCHAR2(1000) := G_PXC_FFFFFF;
G_BOT_OUTER_EDGE_COLOR   CONSTANT VARCHAR2(1000) := G_PXC_333333;
G_BOT_INNER_EDGE_COLOR   CONSTANT VARCHAR2(1000) := G_PXC_666666;
G_BUTTON_BG_COLOR           CONSTANT VARCHAR2(1000) := G_PXC_CCCCCC;


--
G_FF_SPACER_THICKNESS       CONSTANT NUMBER         := 3;
G_STD_SPACER_THICKNESS      CONSTANT NUMBER         := 10;
--G_BUTTON_HEIGHT             CONSTANT NUMBER         := 17;
--
G_GROUP_BOX_TABLE_WIDTH_PRCNT  CONSTANT NUMBER    := 100;

TYPE color_tbl_type is
  table of varchar2(32000) index by BINARY_INTEGER;

TYPE imgsrc_tbl_type is
  table of varchar2(32000) index by BINARY_INTEGER;

  TYPE Target_level_Rec_Type IS RECORD
  ( Target_Level_ID       NUMBER
  );
  --
  TYPE Target_level_Tbl_Type IS TABLE of Target_level_Rec_Type
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE Perf_Measure_Rec_Type IS RECORD
  ( Measure_ID                     NUMBER
  );
  --
  TYPE Perf_Measure_Tbl_Type IS TABLE of Perf_Measure_Rec_Type
  INDEX BY BINARY_INTEGER;
  --

--  Functions/ Procedures
Procedure Get_Time_Level_Value      -- where p_date is between start and end dates.
( p_source      IN varchar2,
  p_table_name      IN varchar2,
  p_value_col_name      IN varchar2,
  p_Org_Level_ID    IN varchar2,
  p_org_level_short_name IN varchar2,
  p_flag        IN varchar2,
  p_date        IN date,
  x_time_value      OUT NOCOPY varchar2
);
--
Procedure Get_Min_Max_Start_End_Dates   -- get min start and max end date for a given
( p_source      IN varchar2,    --  time level value.
  p_view_name       IN varchar2,
  p_org_level_id    IN varchar2,
  p_org_level_short_name IN varchar2,
  x_min_start_date  OUT NOCOPY date,
  x_max_end_date    OUT NOCOPY date
);
--
FUNCTION escape_html(
  p_input IN VARCHAR2
 ,p_cr IN VARCHAR2
)
RETURN VARCHAR2;
--

FUNCTION getPrompt
( p_region_code in varchar2
, p_attribute_code in varchar2
) return varchar2
is

l_str varchar2(32000);
begin
--
 l_str := icx_util.getPrompt( BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
                            , p_region_code
                            , BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
                            , p_attribute_code
                            );

 if (l_str is null or Length(l_str)=0) then
   l_str := p_attribute_code;
 end if;

 return l_str;
--
end getPrompt;

FUNCTION
getPrompt( p_attribute_code varchar2)
return varchar2
is
l_str varchar2(32000);
begin
--
 l_str := getPrompt(G_BIS_REGION_CODE,p_attribute_code);

 return l_str;
--
end getPrompt;
--
PROCEDURE PutHtmlNumberTextField
( p_field_name  varchar2
, p_number      number
)
is
begin
--
  if (p_number = FND_API.G_MISS_NUM) then
    htp.formText(p_field_name);
  else
    htp.formText( cname => p_field_name
                , cvalue=>p_number
                );
  end if;
--
end PutHtmlNumberTextField;
--
PROCEDURE PutHtmlNumberOptionField
( p_number      number
, p_selected    varchar2
, p_value       varchar2
)
is
begin
--
  if (p_number <> FND_API.G_MISS_NUM) then
    if (p_value is null) then
      htp.formSelectOption(p_number);
    else
      htp.formSelectOption(p_number, p_selected, 'VALUE="'||p_value||'"');
    end if;
  end if;
--
end PutHtmlNumberOptionField;
--
PROCEDURE PutHtmlNumberHiddenField
( p_field_name  varchar2
, p_number      number
)
is
begin
--
  if (p_number = FND_API.G_MISS_NUM) then
    htp.formHidden(p_field_name);
  else
    htp.formHidden( cname => p_field_name
                  , cvalue=> p_number
                  );
  end if;
--
end PutHtmlNumberHiddenField;
--
PROCEDURE PutHtmlVarcharTextField
( p_field_name  varchar2
, p_varchar     varchar2
)
is
begin
--
  if (p_varchar = FND_API.G_MISS_NUM) then
    htp.formText(p_field_name);
  else
    htp.formText( cname => p_field_name
                , cvalue=>p_varchar
                );
  end if;
--
end PutHtmlVarcharTextField;
--
PROCEDURE PutHtmlVarcharOptionField
( p_varchar     varchar2
, p_selected    varchar2 := NULL
, p_value       varchar2 := NULL
)
is
begin
--
  if (p_varchar <> BIS_UTILITIES_PUB.G_NULL_CHAR) then
    if (p_value is null) then
      htp.formSelectOption(p_varchar);
    else
      htp.formSelectOption(p_varchar, p_selected, 'VALUE="'||p_value||'"');
    end if;
  end if;
--
end PutHtmlVarcharOptionField;
--
PROCEDURE PutHtmlVarcharHiddenField
( p_field_name  varchar2
, p_varchar     varchar2
)
is
begin
--
  if (p_varchar = FND_API.G_MISS_CHAR) then
    htp.formHidden(p_field_name);
  else
    htp.formHidden( cname => p_field_name
                  , cvalue=> p_varchar
                  );
  end if;
--
end PutHtmlVarcharHiddenField;
--
--
-- function to get message from FND_MESSAGES
FUNCTION Get_FND_Message
( p_message_name IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  FND_MESSAGE.set_name( BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME
                      , p_message_name
                      );
  RETURN FND_MESSAGE.get;
END Get_FND_Message;
--
--
FUNCTION Get_FND_Message
( p_message_name   IN VARCHAR2
, p_msg_param1     IN VARCHAR2
, p_msg_param1_val IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  FND_MESSAGE.set_name( BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME
                      , p_message_name
                      );
  FND_MESSAGE.set_token(p_msg_param1, p_msg_param1_val);
  RETURN FND_MESSAGE.get;
END Get_FND_Message;
--
--
FUNCTION Get_FND_Message
( p_message_name   IN VARCHAR2
, p_msg_param1     IN VARCHAR2
, p_msg_param1_val IN VARCHAR2
, p_msg_param2     IN VARCHAR2
, p_msg_param2_val IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  FND_MESSAGE.set_name( BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME
                      , p_message_name
                      );
  FND_MESSAGE.set_token(p_msg_param1, p_msg_param1_val);
  FND_MESSAGE.set_token(p_msg_param2, p_msg_param2_val);
  RETURN FND_MESSAGE.get;
END Get_FND_Message;
--
--
FUNCTION Get_FND_Message
( p_message_name   IN VARCHAR2
, p_msg_param1     IN VARCHAR2
, p_msg_param1_val IN VARCHAR2
, p_msg_param2     IN VARCHAR2
, p_msg_param2_val IN VARCHAR2
, p_msg_param3     IN VARCHAR2
, p_msg_param3_val IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  FND_MESSAGE.set_name( BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME
                      , p_message_name
                      );
  FND_MESSAGE.set_token(p_msg_param1, p_msg_param1_val);
  FND_MESSAGE.set_token(p_msg_param2, p_msg_param2_val);
  FND_MESSAGE.set_token(p_msg_param3, p_msg_param3_val);
  RETURN FND_MESSAGE.get;
END Get_FND_Message;
--
--
-- these procedure check and puts the error message on the message stack
--
PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_error_table       IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_table       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_error_rec BIS_UTILITIES_PUB.Error_Rec_Type;
--
BEGIN
  IF (fnd_msg_pub.check_msg_level(p_error_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME, p_error_msg_name);

    l_error_rec.Error_Msg_ID      := NULL;
    l_error_rec.Error_Msg_Name    := p_error_msg_name;
    l_error_rec.Error_proc_Name   := p_error_proc_name;
    l_error_rec.Error_Description := fnd_message.get;
    l_error_rec.Error_Type        := p_error_type;
    --
    x_error_table := p_error_table;
    x_error_table(x_error_table.COUNT + 1) := l_error_rec;

  END IF;
END Add_Error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
, p_error_table       IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_table       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_error_rec BIS_UTILITIES_PUB.Error_Rec_Type;
--
BEGIN

  IF (fnd_msg_pub.check_msg_level(p_error_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME, p_error_msg_name);
    fnd_message.set_token(p_token1, p_value1);

    -- mdamle 08/06/2003 - Added token and values
    l_error_rec.Error_Token1      := p_token1;
    l_error_rec.Error_Value1      := p_value1;

    l_error_rec.Error_Msg_ID      := NULL;
    l_error_rec.Error_Msg_Name    := p_error_msg_name;
    l_error_rec.Error_proc_Name   := p_error_proc_name;
    l_error_rec.Error_Description := fnd_message.get;
    l_error_rec.Error_Type        := p_error_type;
    --
    x_error_table := p_error_table;
    x_error_table(x_error_table.COUNT + 1) := l_error_rec;

  END IF;

END Add_Error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
, p_token2            IN VARCHAR2
, p_value2            IN VARCHAR2
, p_error_table       IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_table       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_error_rec BIS_UTILITIES_PUB.Error_Rec_Type;
--
BEGIN

  IF (fnd_msg_pub.check_msg_level(p_error_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME, p_error_msg_name);
    fnd_message.set_token(p_token1, p_value1);
    fnd_message.set_token(p_token2, p_value2);

    -- mdamle 08/06/2003 - Added token and values
    l_error_rec.Error_Token1      := p_token1;
    l_error_rec.Error_Value1      := p_value1;
    l_error_rec.Error_Token2      := p_token2;
    l_error_rec.Error_Value2      := p_value2;

    l_error_rec.Error_Msg_ID      := NULL;
    l_error_rec.Error_Msg_Name    := p_error_msg_name;
    l_error_rec.Error_proc_Name   := p_error_proc_name;
    l_error_rec.Error_Description := fnd_message.get;
    l_error_rec.Error_Type        := p_error_type;
    --
    x_error_table := p_error_table;
    x_error_table(x_error_table.COUNT + 1) := l_error_rec;

  END IF;
END Add_Error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
, p_token2            IN VARCHAR2
, p_value2            IN VARCHAR2
, p_token3            IN VARCHAR2
, p_value3            IN VARCHAR2
, p_error_table       IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_table       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_error_rec BIS_UTILITIES_PUB.Error_Rec_Type;
--
BEGIN

  IF (fnd_msg_pub.check_msg_level(p_error_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME, p_error_msg_name);
    fnd_message.set_token(p_token1, p_value1);
    fnd_message.set_token(p_token2, p_value2);
    fnd_message.set_token(p_token3, p_value3);

    -- mdamle 08/06/2003 - Added token and values
    l_error_rec.Error_Token1      := p_token1;
    l_error_rec.Error_Value1      := p_value1;
    l_error_rec.Error_Token2      := p_token2;
    l_error_rec.Error_Value2      := p_value2;
    l_error_rec.Error_Token3      := p_token3;
    l_error_rec.Error_Value3      := p_value3;

    l_error_rec.Error_Msg_ID      := NULL;
    l_error_rec.Error_Msg_Name    := p_error_msg_name;
    l_error_rec.Error_proc_Name   := p_error_proc_name;
    l_error_rec.Error_Description := fnd_message.get;
    l_error_rec.Error_Type        := p_error_type;
    --
    x_error_table := p_error_table;
    x_error_table(x_error_table.COUNT + 1) := l_error_rec;

  END IF;
END Add_Error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_id      IN  NUMBER    := NULL
, p_error_description IN  VARCHAR2  := NULL
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_error_table       IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_table       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_error_rec BIS_UTILITIES_PUB.Error_Rec_Type;
--
BEGIN

  l_error_rec.Error_Msg_ID      := p_error_msg_id;
  l_error_rec.Error_Msg_Name    := NULL;
  l_error_rec.Error_proc_Name   := p_error_proc_name;
  l_error_rec.Error_Description := p_error_description;
  l_error_rec.Error_Type        := p_error_type;
  --
  x_error_table := p_error_table;
  x_error_table(x_error_table.COUNT + 1) := l_error_rec;
END Add_Error_Message;
--
PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error_tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
l_return_status VARCHAR2(32000);
BEGIN
  BIS_UTILITIES_PVT.Add_Error_Message
  ( p_error_msg_name
  , p_error_msg_level
  , p_error_proc_name
  , p_error_type
  , l_error_tbl_p
  , l_error_tbl
  );
  BIS_ERROR_MESSAGE_PVT.Update_Error_Log( l_error_tbl(1)
                                    , l_return_status
                                    , l_error_tbl
                                    );
END Add_error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error_tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
l_return_status VARCHAR2(32000);
BEGIN
  BIS_UTILITIES_PVT.Add_Error_Message
  ( p_error_msg_name
  , p_error_msg_level
  , p_error_proc_name
  , p_error_type
  , p_token1
  , p_value1
  , l_error_tbl_p
  , l_error_tbl
  );
  BIS_ERROR_MESSAGE_PVT.Update_Error_Log( l_error_tbl(1)
                                    , l_return_status
                                    , l_error_tbl
                                    );
END Add_error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
, p_token2            IN VARCHAR2
, p_value2            IN VARCHAR2
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error_tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
l_return_status VARCHAR2(32000);
BEGIN
  BIS_UTILITIES_PVT.Add_Error_Message
  ( p_error_msg_name
  , p_error_msg_level
  , p_error_proc_name
  , p_error_type
  , p_token1
  , p_value1
  , p_token2
  , p_value2
  , l_error_tbl_p
  , l_error_tbl
  );
  BIS_ERROR_MESSAGE_PVT.Update_Error_Log( l_error_tbl(1)
                                    , l_return_status
                                    , l_error_tbl
                                    );
END Add_error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
, p_token2            IN VARCHAR2
, p_value2            IN VARCHAR2
, p_token3            IN VARCHAR2
, p_value3            IN VARCHAR2
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error_tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
l_return_status VARCHAR2(32000);
BEGIN
  BIS_UTILITIES_PVT.Add_Error_Message
  ( p_error_msg_name
  , p_error_msg_level
  , p_error_proc_name
  , p_error_type
  , p_token1
  , p_value1
  , p_token2
  , p_value2
  , p_token3
  , p_value3
  , l_error_tbl_p
  , l_error_tbl
  );
  BIS_ERROR_MESSAGE_PVT.Update_Error_Log( l_error_tbl(1)
                                    , l_return_status
                                    , l_error_tbl
                                    );
END Add_error_Message;

-- this procedure adds a message to the error table
PROCEDURE Add_Error_Message
( p_error_msg_id      IN  NUMBER    := NULL
, p_error_description IN  VARCHAR2  := NULL
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error_tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
l_return_status VARCHAR2(32000);
BEGIN
  BIS_UTILITIES_PVT.Add_Error_Message
  ( p_error_msg_id
  , p_error_description
  , p_error_proc_name
  , p_error_type
  , l_error_tbl_p
  , l_error_tbl
  );
  BIS_ERROR_MESSAGE_PVT.Update_Error_Log( l_error_tbl(1)
                                    , l_return_status
                                    , l_error_tbl
                                    );
END Add_error_Message;
--
PROCEDURE putStyle
IS
BEGIN
      htp.p('
<STYLE TYPE="text/css">
FONT.button
{font-family: arial, sans-serif; color: black; text-decoration: none; font-size: 10pt}

FONT.disbutton
        {font-family: arial, sans-serif; color: #666666; text-decoration: none; font-size: 10pt}

FONT.tableHeader
{font-family: arial, sans-serif; font-weight: bold; color: white; text-decoration: none; font-size: 10pt}

all.normal
{font-family: arial, sans-serif; color: black; font-size: 10pt}

all.bold
{font-family: arial, sans-serif; font-weight: bold; color: black; font-size: 10pt}

TD
{font-family: arial, sans-serif; color: black; font-size: 10pt}

TEXTAREA
{font-family: arial, sans-serif; color: black; font-size: 10pt}

FONT.normalLink
{font-family: arial, sans-serif; font-size: 10pt}
</STYLE>
      ');
END putStyle;

-- This function will return a string
-- The string is a html table with all the images arranged
-- properly in this table according to the buttons desired
PROCEDURE GetButtonString
( p_Button_table in  HTML_Button_Tbl_Type
, x_str          out NOCOPY varchar2
)
is
l_str       varchar2(32000);
l_thickness number;
l_swan_enabled            BOOLEAN;
l_left_flat_image_src     VARCHAR2(1000);
l_top_outer_edge_img_src  VARCHAR2(1000);
l_right_flat_edge_img_src VARCHAR2(1000);
l_bot_inner_edge_img_src  VARCHAR2(1000);
l_bot_outer_edge_img_src  VARCHAR2(1000);
BEGIN
--
  l_swan_enabled := BIS_UTILITIES_PVT.checkSWANEnabled();
  IF(l_swan_enabled)THEN
    l_left_flat_image_src       := '<img src="'||G_R12_LEFT_FLAT_EDGE_IMG_SRC||'">';
    l_top_outer_edge_img_src    := '<img src="'||G_R12_TOP_OUTER_EDGE_IMG_SRC||'">';
    l_right_flat_edge_img_src   := '<img src="'||G_R12_RIGHT_FLAT_EDGE_IMG_SRC||'">';
    l_bot_inner_edge_img_src    := '<img src="'||G_R12_BOT_INNER_EDGE_IMG_SRC||'">';
    l_bot_outer_edge_img_src    := '<img src ="'||G_R12_BOT_OUTER_EDGE_IMG_SRC||'">';
  ELSE
    l_left_flat_image_src       := '<img src="'||G_LEFT_FLAT_EDGE_IMG_SRC||'">';
    l_top_outer_edge_img_src    := '<img src="'||G_TOP_OUTER_EDGE_IMG_SRC||'">';
    l_right_flat_edge_img_src   := '<img src="'||G_RIGHT_FLAT_EDGE_IMG_SRC||'">';
    l_bot_inner_edge_img_src    := '<img src="'||G_BOT_INNER_EDGE_IMG_SRC||'">';
    l_bot_outer_edge_img_src    := '<img src ="'||G_BOT_OUTER_EDGE_IMG_SRC||'">';
  END IF;

  x_str := htf.tableOpen( cborder     => 'border=0'
                        , cattributes => 'cellpadding=0 cellspacing=0'
                        );
--
  -- put in the first row of the table which will put in the from and back
  -- ends and the top row
  x_str := x_str || htf.tableRowOpen;
--
  FOR i IN 1 .. p_Button_table.COUNT LOOP
   IF (p_Button_table(i).left_edge = G_ROUND_EDGE) THEN
      l_str := '<img src="'||G_LEFT_ROUND_EDGE_IMG_SRC||'">';
    ELSIF (p_Button_table(i).left_edge = G_FLAT_EDGE) THEN
      l_str := l_left_flat_image_src;
    END IF;
    x_str := x_str || htf.tableData( cvalue   => l_str
                                   , crowspan => 5
                                   );
--
    l_str := l_top_outer_edge_img_src;
    x_str := x_str || htf.tableData
                      ( cvalue      => l_str
                    --  , cattributes => 'bgcolor="'||G_TOP_OUTER_EDGE_COLOR||'"'
                        , cattributes => 'class="G_TOP_OUTER_EDGE_COLOR"'
                      );
--
--
    if (p_Button_table(i).right_edge = G_ROUND_EDGE) then
      l_str := '<img src="'||G_RIGHT_ROUND_EDGE_IMG_SRC||'">';
    elsif (p_Button_table(i).right_edge = G_FLAT_EDGE) then
      l_str := l_right_flat_edge_img_src;
    end if;
    x_str := x_str || htf.tableData( cvalue   => l_str
                                   , crowspan => 5
                                   );
--
    if (i < p_Button_table.COUNT) then
      if (   p_Button_table(i).right_edge = G_FLAT_EDGE
         AND p_Button_table(i+1).left_edge = G_FLAT_EDGE
     ) then
        l_thickness := G_FF_SPACER_THICKNESS;
      else
        l_thickness := G_STD_SPACER_THICKNESS;
      end if;
--
      x_str := x_str || htf.tableData( crowspan => 5
                                     , cattributes=>'width="'||l_thickness||'"'
                                     );
    end if;
  end loop;
  x_str := x_str || htf.tableRowClose;
--
  -- put the top inner white line
  x_str := x_str || htf.tableRowOpen;
  for i in 1 .. p_Button_table.COUNT loop
    l_str := '<img src ="'||G_TOP_INNER_EDGE_IMG_SRC||'">';
    x_str := x_str || htf.tableData
                      ( cvalue      => l_str
                   --   , cattributes => 'bgcolor="'||G_TOP_INNER_EDGE_COLOR||'"'
                        , cattributes => 'class="G_TOP_INNER_EDGE_COLOR"'
                      );
  end loop;
  x_str := x_str || htf.tableRowClose;
--
  -- put the images etc. for the button
  x_str := x_str || htf.tableRowOpen;
  for i in 1 .. p_Button_table.COUNT loop
--
    if (p_Button_table(i).disabled = FND_API.G_TRUE) then
      l_str := htf.FontOpen(cattributes => 'class=disbutton');
    elsif(p_Button_table(i).disabled = FND_API.G_FALSE) then
      l_str := htf.FontOpen(cattributes => 'class=button');
    end if;
--
    l_str := l_str || p_Button_table(i).label;
    l_str := l_str || htf.fontClose;
--

    if(p_Button_table(i).disabled = FND_API.G_FALSE) then
      l_str := htf.anchor( curl  => p_Button_table(i).href
                         , ctext => l_str
                         );
    end if;
--
   --l_str := 'class="G_BUTTON_BG_COLOR" height="'||G_BUTTON_HEIGHT || '"';
    x_str := x_str || htf.tableData( cvalue  => l_str
                                   , cnowrap => 'Y'
                                   /*, cattributes => 'bgcolor="'
                                                 --|| G_BUTTON_BG_COLOR
                                                 || G_BUTTON_BG_COLOR
                                                 || '" height="'
                                                 || G_BUTTON_HEIGHT||'"'  */
                                   /* , cattributes => 'class="G_BUTTON_BG_COLOR"
                                                    || " height="'
                                                    || G_BUTTON_HEIGHT||'"'*/
                                       , cattributes => 'class="G_BUTTON_BG_COLOR" height="'||BIS_PORTLET_CUSTOM_PUB.c_BUTTON_HEIGHT || '"'
                                   );
  end loop;
  x_str := x_str || htf.tableRowClose;
--
  -- put the bottom inner line
  x_str := x_str || htf.tableRowOpen;
  for i in 1 .. p_Button_table.COUNT loop
    l_str := l_bot_inner_edge_img_src;--'<img src ="'||G_BOT_INNER_EDGE_IMG_SRC||'">';
    x_str := x_str ||
             htf.tableData
             ( cvalue      => l_str
            -- , cattributes => 'bgcolor="'||G_BOT_INNER_EDGE_COLOR||'"'
               , cattributes => 'class="G_BOT_INNER_EDGE_COLOR"'
             );
  end loop;
  x_str := x_str || htf.tableRowClose;
--
  -- put the bottom outer line
  x_str := x_str || htf.tableRowOpen;
  for i in 1 .. p_Button_table.COUNT loop
     null;
    l_str := l_bot_outer_edge_img_src;--'<img src ="'||G_BOT_OUTER_EDGE_IMG_SRC||'">';
    x_str := x_str ||
             htf.tableData
                ( cvalue      => l_str
              --  , cattributes => 'bgcolor="'||G_BOT_OUTER_EDGE_COLOR||'"'
                  , cattributes => 'class="G_BOT_OUTER_EDGE_COLOR"'
                );
  end loop;
  x_str := x_str || htf.tableRowClose;
  x_str := x_str || htf.tableClose;
--
end GetButtonString;
--
-- This function starts table with the
-- standard margins on left and right
-- takes in the number of columns and rows in the table
PROCEDURE tableOpen
( p_num_row  in NUMBER
, p_num_col  in NUMBER
)
is
begin
  htp.tableOpen( calign      => 'CENTER'
               , cborder     => 'BORDER=0'
               , cattributes => 'WIDTH="100%"'
               );
  htp.tableRowOpen;
  htp.tableData( crowspan    => p_num_row + 1
               , cattributes => 'width="'
                             || BIS_UTILITIES_PVT.G_TABLE_LEFT_MARGIN_PERCENT
                             || '%"'
               );
  htp.tableData(ccolspan => p_num_col);
  htp.tableData( crowspan    => p_num_row + 1
               , cattributes => 'width="'
                             || BIS_UTILITIES_PVT.G_TABLE_RIGHT_MARGIN_PERCENT
                             || '%"'
               );
  htp.tableRowClose;
end tableOpen;

PROCEDURE tableClose
is
begin
  htp.tableClose;
end tableClose;

PROCEDURE putSaveFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_submit_form     varchar2
)
is
begin
  putFunction( p_form_name
             , p_action_var
             , p_str
             , G_FUNCTION_SUBMIT_FORM_SAVE
             , G_ACTION_SAVE
             , p_submit_form
             );
end putSaveFunction;

PROCEDURE putDeleteFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_submit_form     varchar2
)
is
begin

   htp.p('function ' || G_FUNCTION_SUBMIT_FORM_DELETE || '()
     {
     if (confirm("'
             || BIS_UTILITIES_PVT.Get_FND_Message
                           ( p_message_name => 'BIS_CONFIRM_DELETE_MESSAGE' )
             || '"))
          {document.'
           || p_form_name
           ||'.'
           || p_action_var
           || '.value="'
           || G_ACTION_DELETE
           || '";'
             );

  if (p_str is not null) then
     htp.p(p_str);
   end if;

  if (p_submit_form = FND_API.G_TRUE) then
    htp.p('document.'|| p_form_name||'.submit();');
  end if;

  htp.p('}
         }');


end putDeleteFunction;

PROCEDURE putNewFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_submit_form     varchar2
)
is
begin
  putFunction( p_form_name
             , p_action_var
             , p_str
             , G_FUNCTION_SUBMIT_FORM_NEW
             , G_ACTION_NEW
             , p_submit_form
             );
end putNewFunction;

PROCEDURE putUpdateFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_submit_form     varchar2
)
is
begin
  putFunction( p_form_name
             , p_action_var
             , p_str
             , G_FUNCTION_SUBMIT_FORM_UPDATE
             , G_ACTION_UPDATE
             , p_submit_form
             );
end putUpdateFunction;

PROCEDURE putBackFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_submit_form     varchar2
)
is
begin
  putFunction( p_form_name
             , p_action_var
             , p_str
             , G_FUNCTION_SUBMIT_FORM_BACK
             , G_ACTION_BACK
             , p_submit_form
             );
end putBackFunction;

PROCEDURE putNextFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_submit_form     varchar2
)
is
begin
  putFunction( p_form_name
             , p_action_var
             , p_str
             , G_FUNCTION_SUBMIT_FORM_NEXT
             , G_ACTION_NEXT
             , p_submit_form
             );
end putNextFunction;

PROCEDURE putCancelFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_submit_form     varchar2
)
is
begin
  putFunction( p_form_name
             , p_action_var
             , p_str
             , G_FUNCTION_SUBMIT_FORM_CANCEL
             , G_ACTION_CANCEL
             , p_submit_form
             );
end putCancelFunction;

PROCEDURE putRevertFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_submit_form     varchar2
)
is
begin
  putFunction( p_form_name
             , p_action_var
             , p_str
             , G_FUNCTION_SUBMIT_FORM_REVERT
             , G_ACTION_REVERT
             , p_submit_form
             );
end putRevertFunction;

PROCEDURE putDoneFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_submit_form     varchar2
)
is
begin
  putFunction( p_form_name
             , p_action_var
             , p_str
             , G_FUNCTION_SUBMIT_FORM_DONE
             , G_ACTION_DONE
             , p_submit_form
             );
end putDoneFunction;

PROCEDURE putOKFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_submit_form     varchar2
)
is
begin
  putFunction( p_form_name
             , p_action_var
             , p_str
             , G_FUNCTION_SUBMIT_FORM_OK
             , G_ACTION_OK
             , p_submit_form
             );
end putOKFunction;

PROCEDURE putFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2
, p_function_name   varchar2
, p_action          varchar2
, p_submit_form     varchar2
)
is
begin
  htp.p('function '||p_function_name||'(){
          document.'|| p_form_name||'.'||p_action_var||'.value="'
                    ||p_action||'";'
       );

  if (p_str is not null) then
    htp.p(p_str);
  end if;

  if (p_submit_form = FND_API.G_TRUE) then
    htp.p('document.'|| p_form_name||'.submit();');
  end if;

  htp.p('}');

end putFunction;

PROCEDURE putVerticalSpacer(p_col_num NUMBER)
is
begin
  htp.tableRowOpen;
  htp.tableData( cvalue      => '<img src='||G_PXC_FFFFFF_IMG_SRC||'>'
               , ccolspan    => p_col_num
               , cattributes => 'bgcolor=#FFFFFF'
               );
  htp.tableRowClose;
end putVerticalSpacer;

PROCEDURE putGreyLine(p_col_num NUMBER)
is
begin
  htp.tableRowOpen;
  htp.tableData( cvalue      => htf.img( curl => G_PXC_CCCCCC_IMG_SRC
                                               , cattributes => 'height=1 width=100%')
               , ccolspan    => p_col_num
---               , cattributes => 'height=1 valign=bottom align=left bgcolor=#CCCCCC '
               );
  htp.tableRowClose;
end putGreyLine;
---
PROCEDURE getGroupBoxString
( p_title_string IN  varchar2
, p_title_bold   IN  varchar2 := FND_API.G_FALSE
, p_data_string  IN  varchar2
, x_str          OUT NOCOPY varchar2
)
is
begin
  x_str := htf.tableOpen( calign      => 'CENTER'
                        , cattributes => 'border=0 cellpadding=0 cellspacing=0
                                          width="'
                                      ||  G_GROUP_BOX_TABLE_WIDTH_PRCNT||'%"'
                        );
  x_str := x_str || htf.tableRowOpen;
  x_str := x_str || htf.tableData(ccolspan=>3, cattributes=>'height="12"');

  IF p_title_bold = FND_API.G_TRUE THEN
    x_str := x_str || htf.tableData( cvalue
                                =>   htf.fontOpen(cattributes=>'class=bold')
                 || '&'||'nbsp;'||p_title_string||'&'||'nbsp;'
                 || htf.fontClose
                   , crowspan    => 3
                   , cattributes => 'valign=bottom NOWRAP'
                   );
  ELSE
    x_str := x_str || htf.tableData( cvalue
                                =>   htf.fontOpen(cattributes=>'class=normal')
                 || '&'||'nbsp;'||p_title_string||'&'||'nbsp;'
                 || htf.fontClose
                   , crowspan    => 3
                   , cattributes => 'valign=bottom NOWRAP'
                   );
  END IF;
  x_str := x_str || htf.tableData(cattributes=>'width = 1000');
  x_str := x_str || htf.tableData(ccolspan=>3, cattributes=>'height=12');
  x_str := x_str || htf.tableRowClose;

  x_str := x_str || htf.tableRowOpen;
  x_str := x_str || htf.tableData( cvalue  =>htf.img(G_TOP_LEFT_CURVE_IMG_SRC)
                                 , ccolspan=>2
                                 , crowspan=>2
                                 , cattributes=>'height=1 width=1'
                                 );
  x_str := x_str || htf.tableData( cvalue      => htf.img(G_PXC_666666_IMG_SRC)
                                 , cattributes => 'height=1 bgcolor='||
                                                  G_PXC_666666
                                 );
  x_str := x_str || htf.tableData( cvalue      => htf.img(G_PXC_666666_IMG_SRC)
                                 , cattributes => 'height=1 bgcolor='||
                                                  G_PXC_666666
                                 );
  x_str := x_str || htf.tableData( cvalue  =>htf.img(G_TOP_RIGHT_CURVE_IMG_SRC)
                                 , ccolspan=>2
                                 , crowspan=>2
                                 , cattributes=>'height=1 width=1'
                                 );
  x_str := x_str || htf.tableRowClose;

  x_str := x_str || htf.tableRowOpen;
  x_str := x_str || htf.tableData( cattributes => 'height=5');
  x_str := x_str || htf.tableData( cattributes => 'height=5');
  x_str := x_str || htf.tableRowClose;

  x_str := x_str || htf.tableRowOpen;
  x_str := x_str || htf.tableData( cvalue => htf.img(G_PXC_666666_IMG_SRC)
                                 , cattributes => 'width=1 bgcolor='
                                               || G_PXC_666666
                                 );
  x_str := x_str || htf.tableData( cattributes => 'width=5');
  x_str := x_str || htf.tableData( cattributes => 'width=10');
  x_str := x_str || htf.tableData( cvalue   => p_data_string
                                 , ccolspan => 2
                                 , calign   => 'CENTER'
                                 );
  x_str := x_str || htf.tableData(cattributes => 'width=5');
  x_str := x_str || htf.tableData(cattributes => 'width=1');
  x_str := x_str || htf.tableData( cvalue => htf.img(G_PXC_666666_IMG_SRC)
                                 , cattributes => 'width=1 bgcolor='
                                               || G_PXC_666666
                                 );
  x_str := x_str || htf.tableRowClose;

  x_str := x_str || htf.tableRowOpen;
  x_str := x_str || htf.tableData(cvalue =>htf.img(G_BOT_LEFT_CURVE_IMG_SRC)
                                 , cattributes => 'height=1 width=1'
                                 , ccolspan    => 2
                                 , crowspan    => 2
                                 );
  x_str := x_str || htf.tableData( ccolspan    => 3
                                 , cattributes => 'height=5'
                                 );
  x_str := x_str || htf.tableData(cvalue=>htf.img(G_BOT_RIGHT_CURVE_IMG_SRC)
                                 , cattributes => 'height=1 width=1'
                                 , ccolspan    => 2
                                 , crowspan    => 2
                                 );
  x_str := x_str || htf.tableRowClose;

  x_str := x_str || htf.tableRowOpen;
  x_str := x_str || htf.tableData(cvalue=>htf.img(G_PXC_666666_IMG_SRC)
                                 , ccolspan    => 3
                                 , cattributes =>'height=1 width=1000 bgcolor='
                                 || G_PXC_666666
                                 );
  x_str := x_str || htf.tableRowClose;
  x_str := x_str || htf.tableClose;

end getGroupBoxString;

PROCEDURE getGroupBoxString
( p_title_string IN  varchar2
, p_title_bold   IN  varchar2 := FND_API.G_FALSE
, p_data_tbl     IN  BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_data_tbl     OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS
l_str VARCHAR2(32000);
BEGIN

  l_str := htf.tableOpen( calign      => 'CENTER'
                        , cattributes => 'border=0 cellpadding=0 cellspacing=0
                                          width='
                                      ||  G_GROUP_BOX_TABLE_WIDTH_PRCNT||'%'
                        );
  l_str := l_str || htf.tableRowOpen;
  l_str := l_str || htf.tableData(ccolspan=>3, cattributes=>'height=12');

  IF p_title_bold = FND_API.G_TRUE THEN
    l_str := l_str || htf.tableData( cvalue
                                 =>   htf.fontOpen(cattributes=>'class=bold')
                                 || '&'||'nbsp;'||p_title_string||'&'||'nbsp;'
                                 || htf.fontClose
                   , crowspan    => 3
                   , cattributes => 'valign=bottom NOWRAP'
                   );
  ELSE
    l_str := l_str || htf.tableData( cvalue
                                 =>   htf.fontOpen(cattributes=>'class=normal')
                                 || '&'||'nbsp;'||p_title_string||'&'||'nbsp;'
                                 || htf.fontClose
                   , crowspan    => 3
                   , cattributes => 'valign=bottom NOWRAP'
                   );
  END IF;

  l_str := l_str || htf.tableData(cattributes=>'width = 1000');
  l_str := l_str || htf.tableData(ccolspan=>3, cattributes=>'height=12');
  l_str := l_str || htf.tableRowClose;

  l_str := l_str || htf.tableRowOpen;
  l_str := l_str || htf.tableData( cvalue  =>htf.img(G_TOP_LEFT_CURVE_IMG_SRC)
                                 , ccolspan=>2
                                 , crowspan=>2
                                 , cattributes=>'height=1 width=1'
                                 );
  l_str := l_str || htf.tableData( cvalue      => htf.img(G_PXC_666666_IMG_SRC)
                                 , cattributes => 'height=1 bgcolor='||
                                                  G_PXC_666666
                                 );
  l_str := l_str || htf.tableData( cvalue      => htf.img(G_PXC_666666_IMG_SRC)
                                 , cattributes => 'height=1 bgcolor='||
                                                  G_PXC_666666
                                 );
  l_str := l_str || htf.tableData( cvalue  =>htf.img(G_TOP_RIGHT_CURVE_IMG_SRC)
                                 , ccolspan=>2
                                 , crowspan=>2
                                 , cattributes=>'height=1 width=1'
                                 );
  l_str := l_str || htf.tableRowClose;

  l_str := l_str || htf.tableRowOpen;
  l_str := l_str || htf.tableData( cattributes => 'height=5');
  l_str := l_str || htf.tableData( cattributes => 'height=5');
  l_str := l_str || htf.tableRowClose;

  l_str := l_str || htf.tableRowOpen;
  l_str := l_str || htf.tableData( cvalue => htf.img(G_PXC_666666_IMG_SRC)
                                 , cattributes => 'width=1 bgcolor='
                                               || G_PXC_666666
                                 );
  l_str := l_str || htf.tableData( cattributes => 'width=5');
  l_str := l_str || htf.tableData( cattributes => 'width=10');

  x_data_tbl(1) := l_str;
  x_data_tbl(2) := '<TD COLSPAN="2" ALIGN="CENTER">';
  for i in 1 .. p_data_tbl.COUNT LOOP
    x_data_tbl(i+2) := p_data_tbl(i);
  END LOOP;
  x_data_tbl(x_data_tbl.COUNT + 1) := '</TD>';

  l_str := htf.tableData(cattributes => 'width=5');
  l_str := l_str || htf.tableData(cattributes => 'width=1');
  l_str := l_str || htf.tableData( cvalue => htf.img(G_PXC_666666_IMG_SRC)
                                 , cattributes => 'width=1 bgcolor='
                                               || G_PXC_666666
                                 );
  l_str := l_str || htf.tableRowClose;

  l_str := l_str || htf.tableRowOpen;
  l_str := l_str || htf.tableData(cvalue =>htf.img(G_BOT_LEFT_CURVE_IMG_SRC)
                                 , cattributes => 'height=1 width=1'
                                 , ccolspan    => 2
                                 , crowspan    => 2
                                 );
  l_str := l_str || htf.tableData( ccolspan    => 3
                                 , cattributes => 'height=5'
                                 );
  l_str := l_str || htf.tableData(cvalue=>htf.img(G_BOT_RIGHT_CURVE_IMG_SRC)
                                 , cattributes => 'height=1 width=1'
                                 , ccolspan    => 2
                                 , crowspan    => 2
                                 );
  l_str := l_str || htf.tableRowClose;

  l_str := l_str || htf.tableRowOpen;
  l_str := l_str || htf.tableData(cvalue=>htf.img(G_PXC_666666_IMG_SRC)
                                 , ccolspan    => 3
                                 , cattributes =>'height=1 width=1000 bgcolor='
                                 || G_PXC_666666
                                 );
  l_str := l_str || htf.tableRowClose;
  l_str := l_str || htf.tableClose;

  x_data_tbl(x_data_tbl.COUNT + 1) := l_str;

END getGroupBoxString;

--- Obsolete Procedures
--- 1) getRightSide
--- 1) getLeftSide
--- 1) getTopRightSide
--- 1) getTopLeftSide


PROCEDURE getLeftEdge
( p_row_num IN  NUMBER
, p_heading IN  VARCHAR2
, x_str     OUT NOCOPY VARCHAR2
)
IS
l_line_color   VARCHAR2(32000);
l_img_src      VARCHAR2(32000);
BEGIN

  if (p_heading = FND_API.G_TRUE) then

--- rounded corners no longer needed

      x_str := x_str || htf.tableData
                       ( cvalue        => htf.img(curl => G_PXC_6699CC_IMG_SRC
                                                 , cattributes => 'width=6'
                                                 )
               , calign      => 'RIGHT'
                       , ccolspan    => 2
               , cattributes => ' bgcolor='||G_PXC_6699CC
               );
---    end if;
  else
    if (mod(p_row_num, 2) = 1) then
      l_line_color := G_PXC_FFFFFF;
      l_img_src := G_PXC_FFFFFF_IMG_SRC;
    else
      l_line_color := G_PXC_CCCCCC;
      l_img_src := G_PXC_CCCCCC_IMG_SRC;
    end if;

    x_str := x_str || htf.tableData
                         ( cvalue      => htf.img( curl => G_PXC_6699CC_IMG_SRC
                                                 , cattributes => 'width=1'
                                                 )
             , calign      => 'RIGHT'
             , cattributes => ' bgcolor='||G_PXC_6699CC
             );

    x_str := x_str || htf.tableData
                         ( cvalue      => htf.img( curl => l_img_src
                                                 , cattributes => 'width=5'
                                                 )
             , calign      => 'RIGHT'
             , cattributes => ' bgcolor='||l_line_color
             );
  end if;

end getLeftEdge;

PROCEDURE getRightEdge
( p_row_num IN  NUMBER
, p_heading IN  VARCHAR2
, x_str     OUT NOCOPY VARCHAR2
)
IS
l_line_color   VARCHAR2(32000);
l_img_src      VARCHAR2(32000);
BEGIN

  if (p_heading = FND_API.G_TRUE) then
     ---rounded corners no longer needed
       x_str := x_str || htf.tableData
                       ( cvalue        => htf.img(curl => G_PXC_6699CC_IMG_SRC
                                                 , cattributes => 'width=6'
                                                 )
               , calign      => 'LEFT'
                       , ccolspan    => 2
               , cattributes => ' bgcolor='||G_PXC_6699CC
               );
---     end if;
  else
    if (mod(p_row_num, 2) = 1) then
      l_line_color := G_PXC_FFFFFF;
      l_img_src := G_PXC_FFFFFF_IMG_SRC;
    else
      l_line_color := G_PXC_CCCCCC;
      l_img_src := G_PXC_CCCCCC_IMG_SRC;
    end if;

    x_str := x_str || htf.tableData
                         ( cvalue      => htf.img( curl => l_img_src
                                                 , cattributes => 'width=5'
                                                 )
             , calign      => 'RIGHT'
             , cattributes => ' bgcolor='||l_line_color
             );

    x_str := x_str || htf.tableData
                         ( cvalue      => htf.img( curl => G_PXC_6699CC_IMG_SRC
                                                 , cattributes => 'width=1'
                                                 )
             , calign      => 'RIGHT'
             , cattributes => ' width=1 bgcolor='||G_PXC_6699CC
             );

  end if;
end getRightEdge;

PROCEDURE getTopHeadingLine
( p_table   IN  HTML_Table_Element_Tbl_Type
, p_row_num IN  NUMBER
, p_index   IN  NUMBER
, p_heading IN  VARCHAR2
, p_width   IN  NUMBER
, x_index   OUT NOCOPY NUMBER
, x_str     OUT NOCOPY VARCHAR2
)
IS
l_rec          HTML_Table_Element_Rec_Type;
l_str          VARCHAR2(32000);
l_color_table  color_tbl_type;
l_color        VARCHAR2(32000);
l_img_src      VARCHAR2(32000);
BEGIN

  l_color_table(0) := G_PXC_CCCCCC;
  l_color_table(1) := G_PXC_FFFFFF;

  x_index := p_index;
  l_rec := p_table(x_index);

  x_str := htf.tableData( cvalue      =>htf.img(G_TOP_RIGHT_BLUE_CURVE_IMG_SRC)
                        , calign      => 'RIGHT'
                        , cattributes =>
                          'valign=top width=6'
                        );

  while (l_rec.row_num = p_row_num) loop
    if(x_index > p_index) then

      l_color := G_PXC_6699CC;
      l_img_src := G_PXC_6699CC_IMG_SRC;

      x_str := x_str || htf.tableData
                        ( cvalue        => htf.img( curl => l_img_src
                                                  , cattributes => 'width=1'
                                                  )
            , calign      => 'LEFT'
            , cattributes =>' width=1 bgcolor='||l_color
            );
    end if;

    l_str := l_rec.display_name;

    if BIS_UTILITIES_PVT.Value_Missing(l_str) = FND_API.G_TRUE
    OR BIS_UTILITIES_PVT.Value_NULL(l_str) = FND_API.G_TRUE then
      l_str := '&'||'nbsp';
    end if;

    -- we have a separator line in between columns
    -- thus we need to increase the col span to accomodate
    -- rowspan is increased by 1 as we are putting two rows for heading
    x_str := x_str
      || htf.tableHeader( cvalue =>
                     htf.fontOpen(cattributes=>'class=tableheader')
                                         || l_str
                                         || htf.fontClose
                            , calign      => l_rec.align
                            , crowspan    => l_rec.row_span + 1
                            , ccolspan => l_rec.col_span + l_rec.col_span - 1
                            , cattributes => l_rec.attributes||' BGCOLOR='
                                                             ||G_PXC_6699CC
                            );

    x_index := x_index + 1;
    if (x_index > p_table.COUNT) then
      exit;
    end if;

    l_rec := p_table(x_index);
  end loop;

  x_str := htf.tableData( cvalue      =>htf.img(G_TOP_RIGHT_BLUE_CURVE_IMG_SRC)
                        , calign      => 'LEFT'
                        , cattributes =>
                          'valign=top width=6'
                        );

  x_str := x_str || htf.tableRowClose;
  x_str := x_str || htf.tableRowOpen
                       ( cvalign => 'TOP'
                       , cattributes => 'height=19'
                       );

  x_str := x_str || htf.tableData
                         ( cvalue      => htf.img(G_PXC_6699CC_IMG_SRC)
             , calign      => 'LEFT'
             , cattributes =>
                   'valign=bottom'
                         ||' bgcolor='||G_PXC_6699CC
             );

  x_str := x_str || htf.tableData
                         ( cvalue      => htf.img(G_PXC_6699CC_IMG_SRC)
             , calign      => 'LEFT'
             , cattributes =>
                   'valign=bottom'
                         ||' bgcolor='||G_PXC_6699CC
             );

END getTopHeadingLine;

PROCEDURE putRowData
( p_table   IN  HTML_Table_Element_Tbl_Type
, p_row_num IN  NUMBER
, p_index   IN  NUMBER
, p_heading IN  VARCHAR2
, p_width   IN  NUMBER
, x_index   OUT NOCOPY NUMBER
, x_str     OUT NOCOPY VARCHAR2
)
IS
l_rec          HTML_Table_Element_Rec_Type;
l_str          VARCHAR2(32000);
l_color_table  color_tbl_type;
l_color        VARCHAR2(32000);
l_img_src      VARCHAR2(32000);
BEGIN

  l_color_table(0) := G_PXC_CCCCCC;
  l_color_table(1) := G_PXC_FFFFFF;

  x_index := p_index;
  l_rec := p_table(x_index);

  getLeftEdge(p_row_num, p_heading, x_str);
  while (l_rec.row_num = p_row_num) loop
    if(x_index > p_index) then
      -- put the separation line in the beginning
--      if(p_heading = FND_API.G_TRUE) then
    l_color := G_PXC_6699CC;
        l_img_src := G_PXC_6699CC_IMG_SRC;
--      else
--        l_color := G_PXC_999999;
--        l_img_src := G_PXC_999999_IMG_SRC;
--      end if;

      x_str := x_str || htf.tableData
                        ( cvalue        => htf.img( curl => l_img_src
                                                  , cattributes => 'width=1'
                                                  )
            , calign      => 'LEFT'
            , cattributes =>' width=1 bgcolor='||l_color
            );
    end if;

    l_str := l_rec.display_name;
    if (l_rec.href is not null) then
      l_str := htf.anchor2( curl  => l_rec.href
                          , ctext => l_rec.display_name
                          );
    end if;

    if BIS_UTILITIES_PVT.Value_Missing(l_str) = FND_API.G_TRUE
    OR BIS_UTILITIES_PVT.Value_NULL(l_str) = FND_API.G_TRUE then
      l_str := '&'||'nbsp';
    end if;

--    l_str := 'xx';
    -- take care of the vertical separators between columns
    l_rec.col_span := l_rec.col_span + l_rec.col_span - 1;
    if (p_heading = FND_API.G_TRUE) then
       -- we have a separator line in between columns
       -- thus we need to increase the col span to accomodate
      x_str := x_str
    || htf.tableHeader( cvalue =>
                  htf.fontOpen(
                        cattributes=>'class=tableheader'
                       )
                                           || l_str
                                           || htf.fontClose
                              , calign      => l_rec.align
                              , crowspan    => l_rec.row_span
                              , ccolspan => l_rec.col_span
                              , cattributes => l_rec.attributes||' BGCOLOR='
                                                               ||G_PXC_6699CC
                              );

    else
      l_color := l_color_table(mod(p_row_num, 2));
      x_str := x_str || htf.tableData(cvalue      =>
                        htf.fontOpen(
                            cattributes=>'class=normal'
                            )
                                           || l_str
                                           || htf.fontClose
                                     , calign      => l_rec.align
                                     , crowspan    => l_rec.row_span
                                     , ccolspan    => l_rec.col_span
                                     , cattributes => l_rec.attributes
                                                   || ' BGCOLOR='||l_color
                                     );
    end if;

    x_index := x_index + 1;
    if (x_index > p_table.COUNT) then
      exit;
    end if;

    l_rec := p_table(x_index);
  end loop;
  getRightEdge(p_row_num, p_heading, l_str);
  x_str := x_str || l_str;

END putRowData;

PROCEDURE getTableString
( p_heading_table  IN  HTML_Table_Element_Tbl_Type
, p_data_table     IN  HTML_Table_Element_Tbl_Type
, p_head_row_count IN  number
, p_data_row_count IN  number
, p_col_count      IN  NUMBER
, x_str            OUT NOCOPY varchar2
)
is

l_row_pixel_height     number := 19;
l_table_corner_height  number := 6;

l_bottom_right_img varchar2(32000) := G_BOT_RIGHT_CURVE_IMG_SRC;
l_bottom_left_img  varchar2(32000) := G_BOT_LEFT_CURVE_IMG_SRC;
l_total_rows       number := p_head_row_count + p_data_row_count + 1;
l_row_height       number := p_data_row_count * l_row_pixel_height;
l_str              varchar2(32000) := '';
l_temp             number;

l_color_table  color_tbl_type;
l_imgsrc_table imgsrc_tbl_type;
l_cur_row      number := 1;
l_cur_row_p NUMBER := 1;
l_width        number;

BEGIN
--  if (mod(p_data_row_count, 2) = 0 AND p_data_row_count > 0) then
--    l_bottom_left_img  := G_BOT_LEFT_BLUE_IMG_SRC;
--    l_bottom_right_img  := G_BOT_RIGHT_BLUE_IMG_SRC;
--  end if;

  -- open the top level table
  x_str := htf.tableOpen( cborder     => 'border=0'
                        , calign      => 'CENTER'
                        , cattributes => p_col_count ||
                          ' align=center cellpadding=0 cellspacing=0 width=96%'
                        );

  l_width := (100-2)/p_col_count;

  for i in 1 .. p_head_row_count loop

    x_str := x_str || htf.tableRowOpen
                         ( cvalign => 'TOP'
                         , cattributes => 'height='||l_row_pixel_height
                         );

    l_cur_row_p := l_cur_row;
    putRowData( p_heading_table
              , i
              , l_cur_row_p
              , FND_API.G_TRUE
              , l_width
              , l_cur_row
              , l_str
              );

    x_str := x_str || l_str;
    x_str := x_str || htf.tableRowClose;

  end loop;

  l_cur_row := 1;

  for i in 1 .. p_data_row_count loop

    x_str := x_str || htf.tableRowOpen
                         ( cvalign => 'TOP'
                         , cattributes => 'height='||l_row_pixel_height
                         );
    l_cur_row_p := l_cur_row;
    putRowData( p_data_table
              , i
              , l_cur_row_p
              , FND_API.G_FALSE
              , l_width
              , l_cur_row
              , l_str
              );

    x_str := x_str || l_str;
    x_str := x_str || htf.tableRowClose;

  end loop;

  x_str := x_str || htf.tableRowOpen;

  --- Rounded corners not needed anymore
  x_str := x_str || htf.tableData
                       ( cvalue      => htf.img( curl => G_PXC_6699CC_IMG_SRC
                                               , cattributes => 'height=1'
                                               )
               , calign      => 'LEFT'
                       , ccolspan    => 2*p_col_count +3
               , cattributes =>
                     'valign=bottom height=1 bgcolor='||G_PXC_6699CC
             );
    x_str := x_str || htf.tableData( cvalue      =>
                             htf.img(G_PXC_FFFFFF_IMG_SRC)
                     , ccolspan    => 1
                     );
  --- Rounded corners no longer required
  x_str := x_str || htf.tableRowClose;

  x_str := x_str || htf.tableClose;
end getTableString;
--
PROCEDURE getTableString
( p_heading_table  IN  HTML_Table_Element_Tbl_Type
, p_data_table     IN  HTML_Table_Element_Tbl_Type
, p_head_row_count IN  number
, p_data_row_count IN  number
, p_col_count      IN  NUMBER
, x_str            OUT NOCOPY HTML_Tablerow_Strings_Tbl_type
)
is

l_row_pixel_height     number := 19;
l_table_corner_height  number := 6;

l_bottom_right_img varchar2(32000) := G_BOT_RIGHT_CURVE_IMG_SRC;
l_bottom_left_img  varchar2(32000) := G_BOT_LEFT_CURVE_IMG_SRC;
l_total_rows       number := p_head_row_count + p_data_row_count + 1;
l_row_height       number := p_data_row_count * l_row_pixel_height;
l_str              varchar2(32000) := '';
l_temp             number;

l_color_table  color_tbl_type;
l_imgsrc_table imgsrc_tbl_type;
l_cur_row      number := 1;
l_cur_row_p NUMBER := 1;
l_width        number;
l_string_ct    number ;
l_str1         varchar2(32000) := '';

BEGIN
--  if (mod(p_data_row_count, 2) = 0 AND p_data_row_count > 0) then
--    l_bottom_left_img  := G_BOT_LEFT_BLUE_IMG_SRC;
--    l_bottom_right_img  := G_BOT_RIGHT_BLUE_IMG_SRC;
--  end if;

  -- open the top level table
  l_string_Ct := 1;
  x_str(l_string_ct) := htf.tableOpen( cborder     => 'border=0'
                        , calign      => 'CENTER'
                        , cattributes => p_col_count ||
                          ' align=center cellpadding=0 cellspacing=0 width=96%'
                        );

  l_width := (100-2)/p_col_count;

  for i in 1 .. p_head_row_count loop
    l_string_ct := l_string_ct + 1;
    l_str1 := '';
    l_str1 := l_str1  || htf.tableRowOpen
                         ( cvalign => 'TOP'
                         , cattributes => 'height='||l_row_pixel_height
                         );

    l_cur_row_p := l_cur_row;
    putRowData( p_heading_table
              , i
              , l_cur_row_p
              , FND_API.G_TRUE
              , l_width
              , l_cur_row
              , l_str
              );
    l_str1 := l_str1 || l_str;
    l_str1 := l_str1 || htf.tableRowClose;
    x_str(l_string_ct) := l_str1;


  end loop;
  l_cur_row := 1;

  for i in 1 .. p_data_row_count loop
    l_string_ct := l_string_ct + 1;
    l_str1 := '';
    l_str1 := l_str1 || htf.tableRowOpen
                         ( cvalign => 'TOP'
                         , cattributes => 'height='||l_row_pixel_height
                         );
    l_cur_row_p := l_cur_row;
    putRowData( p_data_table
              , i
              , l_cur_row_p
              , FND_API.G_FALSE
              , l_width
              , l_cur_row
              , l_str
              );
    l_str1 := l_str1 || l_str;
    l_str1 := l_str1 || htf.tableRowClose;
    x_str(l_string_ct) := l_str1;
    --x_str(l_string_ct) := x_str(l_string_ct) || l_str;
    --x_str(l_string_ct) := x_str(l_string_ct) || htf.tableRowClose;

  end loop;
  l_string_ct := l_string_ct + 1;
  x_str(l_string_ct) := htf.tableRowOpen;

  --- Rounded corners not needed anymore
  x_str(l_string_ct) := x_str(l_string_ct) || htf.tableData
                       ( cvalue      => htf.img( curl => G_PXC_6699CC_IMG_SRC
                                               , cattributes => 'height=1'
                                               )
               , calign      => 'LEFT'
                       , ccolspan    => 2*p_col_count +3
               , cattributes =>
                     'valign=bottom height=1 bgcolor='||G_PXC_6699CC
             );
    x_str(l_string_ct) := x_str(l_string_ct) || htf.tableData( cvalue   =>
                             htf.img(G_PXC_FFFFFF_IMG_SRC)
                     , ccolspan    => 1
                     );
  --- Rounded corners no longer required
  x_str(l_string_ct) := x_str(l_string_ct) || htf.tableRowClose;

  l_string_ct := l_string_ct + 1;
  x_str(l_string_ct) := htf.tableClose;
end getTableString;
--
-- concatenate the two error tables into one
PROCEDURE concatenateErrorTables
( p_error_Tbl1 IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, p_error_Tbl2 IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_Tbl  OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_ind   NUMBER;
l_Count NUMBER;
--
BEGIN
  x_error_Tbl := p_error_Tbl1;
  l_Count := p_error_Tbl1.COUNT;
  FOR l_ind IN 1..p_error_Tbl2.COUNT LOOP
    x_error_Tbl(l_Count + l_ind) := p_error_Tbl2(l_ind);
  END LOOP;
END concatenateErrorTables;
--

-- function to return NULL if G_MISS_CHAR
FUNCTION CheckMissChar
( p_char IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  IF(p_char = FND_API.G_MISS_CHAR) THEN
    RETURN NULL;
  ELSE
    RETURN p_char;
  END IF;
END CheckMissChar;
--
-- function to return NULL if G_MISS_NUM
FUNCTION CheckMissNum
( p_num IN NUMBER
)
RETURN NUMBER
IS
BEGIN
  IF(p_num = FND_API.G_MISS_NUM) THEN
    RETURN NULL;
  ELSE
    RETURN p_num;
  END IF;
END CheckMissNum;
--
FUNCTION CheckMissDate
( p_date IN DATE
)
RETURN DATE
IS
BEGIN
  IF(p_date = BIS_UTILITIES_PUB.G_NULL_DATE) THEN
    RETURN NULL;
  ELSE
    RETURN p_date;
  END IF;
END CheckMissDate;
--

FUNCTION PutNullString
( p_Str    varchar2
, p_align  varchar2
, p_rowspan NUMBER
, p_colspan NUMBER
)
return VARCHAR2
is
begin

  if BIS_UTILITIES_PVT.Value_Missing(p_str) = FND_API.G_TRUE
  OR BIS_UTILITIES_PVT.Value_NOT_NULL(p_str) = FND_API.G_FALSE then
    return htf.tableData( cvalue => '&'||'nbsp'
                    , calign => p_align
                    , crowspan => p_rowspan
                    , ccolspan => p_colspan
                        );
  else
    return htf.tableData( cvalue => p_str
                    , calign => p_align
                    , crowspan => p_rowspan
                    , ccolspan => p_colspan
                        );
  end if;
end PutNullString;



FUNCTION Value_Missing_Or_Null(  -- 2730145
    p_value      IN VARCHAR )
RETURN VARCHAR2
IS
BEGIN
  IF ((Value_Missing(p_value) = FND_API.G_TRUE)
       OR
      (Value_Null(p_value) = FND_API.G_TRUE)) THEN
    RETURN FND_API.G_TRUE;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;
END Value_Missing_Or_Null;



FUNCTION Value_Missing_Or_Null( -- 2730145
    p_value      IN NUMBER )
RETURN VARCHAR2
IS
BEGIN
  IF ((Value_Missing(p_value) = FND_API.G_TRUE)
       OR
      (Value_Null(p_value) = FND_API.G_TRUE )) THEN
    RETURN FND_API.G_TRUE;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;
END Value_Missing_Or_Null;


FUNCTION Value_Missing_Or_Null( -- 2730145
    p_value      IN DATE )
RETURN VARCHAR2
IS
BEGIN
  IF ((Value_Missing(p_value) = FND_API.G_TRUE)
       OR
      (Value_Null(p_value) = FND_API.G_TRUE)) THEN
    RETURN FND_API.G_TRUE;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;
END Value_Missing_Or_Null;


FUNCTION Value_Not_Missing_Not_Null(  -- 2730145
    p_value      IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
  IF ((Value_Not_Missing(p_value) = FND_API.G_TRUE)
         AND
      (Value_Not_Null(p_value) = FND_API.G_TRUE)) THEN
    RETURN FND_API.G_TRUE;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;
END Value_Not_Missing_Not_Null;


FUNCTION Value_Not_Missing_Not_Null(-- 2730145
    p_value      IN NUMBER )
RETURN VARCHAR2
IS
BEGIN
  IF ((Value_Not_Missing(p_value) = FND_API.G_TRUE)
         AND
      (Value_Not_Null(p_value) = FND_API.G_TRUE)) THEN
    RETURN FND_API.G_TRUE;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;
END Value_Not_Missing_Not_Null;


FUNCTION Value_Not_Missing_Not_Null(-- 2730145
    p_value      IN DATE )
RETURN VARCHAR2
IS
BEGIN
  IF ((Value_Not_Missing(p_value) = FND_API.G_TRUE)
         AND
      (Value_Not_Null(p_value) = FND_API.G_TRUE)) THEN
    RETURN FND_API.G_TRUE;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;
END Value_Not_Missing_Not_Null;


FUNCTION Value_Not_Missing(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
    if ( (p_value IS NULL) OR (p_value = FND_API.G_MISS_CHAR) ) THEN --2694965
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_Not_Missing;

FUNCTION Value_Not_Missing(
    p_value      IN NUMBER )
RETURN VARCHAR2
IS
BEGIN
    if ( (p_value IS NULL) OR (p_value = FND_API.G_MISS_NUM) ) THEN --2694965
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_Not_Missing;

FUNCTION Value_Not_Missing(
    p_value      IN DATE )
RETURN VARCHAR2
IS
BEGIN
    if ( (p_value IS NULL) OR (p_value = FND_API.G_MISS_DATE) ) THEN --2694965
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_Not_Missing;

FUNCTION Value_Missing(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
    if (Value_Not_Missing(p_value) = FND_API.G_TRUE) then
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_Missing;

FUNCTION Value_Missing(
    p_value      IN NUMBER )
RETURN VARCHAR2
IS
BEGIN
    if (Value_Not_Missing(p_value) = FND_API.G_TRUE) then
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_Missing;

FUNCTION Value_Missing(
    p_value      IN DATE )
RETURN VARCHAR2
IS
BEGIN
    if (Value_Not_Missing(p_value) = FND_API.G_TRUE) then
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_Missing;

FUNCTION Value_Not_NULL(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
    if (p_value IS NULL) THEN
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_Not_NULL;

FUNCTION Value_Not_NULL(
    p_value      IN NUMBER )
RETURN VARCHAR2
IS
BEGIN
    if (p_value IS NULL) THEN
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_Not_NULL;

FUNCTION Value_Not_NULL(
    p_value      IN DATE )
RETURN VARCHAR2
IS
BEGIN
    if (p_value is NULL) THEN
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_Not_NULL;

FUNCTION Value_NULL(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
    if (Value_Not_NULL(p_value) = FND_API.G_TRUE) then
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_NULL;

FUNCTION Value_NULL(
    p_value      IN NUMBER )
RETURN VARCHAR2
IS
BEGIN
    if (Value_Not_NULL(p_value) = FND_API.G_TRUE) then
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_NULL;

FUNCTION Value_NULL(
    p_value      IN DATE )
RETURN VARCHAR2
IS
BEGIN
    if (Value_Not_NULL(p_value) = FND_API.G_TRUE) then
       return FND_API.G_FALSE;
    else
       return FND_API.G_TRUE;
    end if;
END Value_NULL;





PROCEDURE Set_Debug_Flag
IS
BEGIN
  BIS_UTILITIES_PVT.G_DEBUG_FLAG := 0;
END Set_Debug_Flag;

FUNCTION Convert_to_ID
( p_id         NUMBER
, p_short_name VARCHAR2
, p_name       VARCHAR2
)
return VARCHAR2
is
BEGIN

  if (BIS_UTILITIES_PUB.Value_Missing(p_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(p_id) = FND_API.G_TRUE) then
    -- id is not there

      if ((BIS_UTILITIES_PUB.Value_Missing(p_short_name) = FND_API.G_TRUE
       OR BIS_UTILITIES_PUB.Value_NULL(p_short_name)= FND_API.G_TRUE)
       AND (BIS_UTILITIES_PUB.Value_Missing(p_name) = FND_API.G_TRUE
         OR BIS_UTILITIES_PUB.Value_NULL(p_name) = FND_API.G_TRUE))
        then
        return FND_API.G_FALSE;
      else
        return FND_API.G_TRUE;
      end if;
  else
    return FND_API.G_FALSE;
  end if;

END Convert_to_ID;
--
--
procedure Replace_String
( p_string    IN VARCHAR2
, x_string    OUT NOCOPY VARCHAR2
)
IS

BEGIN
  select DECODE(p_string,
                  NULL,'NULL',
                  FND_API.G_MISS_CHAR,'NULL',
                  ''''||p_string||'''')
  into x_string
  from dual;

END  Replace_String;
--
Procedure Retrieve_User_Target_Level
( p_user_id                 IN NUMBER
, x_Target_Level_Tbl        OUT NOCOPY Target_Level_Tbl_Type
, x_return_status           OUT NOCOPY VARCHAR2
)
IS

  l_temp_Target_Level_tbl BIS_Target_LEVEL_PUB.Target_Level_Tbl_Type;
  l_Target_Level_Tbl      Target_level_Tbl_Type;
  l_return_status         VARCHAR2(1000);
  l_error_Tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  BIS_Target_LEVEL_PUB.Retrieve_User_Target_Levels
  ( p_api_version      => 1.0
  , p_user_id          => p_user_id
  , p_all_info         => FND_API.G_FALSE
  , x_Target_Level_Tbl => l_temp_Target_Level_tbl
  , x_return_status    => l_return_status
  , x_error_tbl        => l_error_tbl
  );

  FOR i IN 1..l_temp_Target_Level_tbl.COUNT LOOP
    l_Target_Level_tbl(l_Target_Level_tbl.COUNT+1).target_level_id
      := l_temp_Target_Level_tbl(i).target_level_id ;
  END LOOP;

  x_target_level_tbl := l_target_level_tbl;

EXCEPTION
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => 'Retrieve_User_Target_Level'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_User_Target_Level;
--
--

Procedure Retrieve_User_perf_measure
( p_user_id           IN NUMBER
, x_Perf_measure_Tbl  OUT NOCOPY Perf_Measure_Tbl_Type
, x_return_status     OUT NOCOPY VARCHAR2
)
IS

  l_Target_Level_tbl      BIS_Target_LEVEL_PUB.Target_Level_Tbl_Type;
  l_return_status         VARCHAR2(1000);
  l_error_Tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_perf_measure_tbl      perf_measure_tbl_Type;

BEGIN

  BIS_Target_LEVEL_PUB.Retrieve_User_Target_Levels
  ( p_api_version      => 1.0
  , p_user_id          => p_user_id
  , p_all_info         => FND_API.G_FALSE
  , x_Target_Level_Tbl => l_Target_Level_tbl
  , x_return_status    => l_return_status
  , x_error_tbl        => l_error_tbl
  );

  FOR i IN 1..l_Target_Level_tbl.COUNT LOOP
  l_perf_measure_tbl(l_perf_measure_tbl.COUNT+1).measure_id
    := l_Target_Level_tbl(i).measure_id;
  END LOOP;

  x_perf_measure_tbl := l_perf_measure_tbl;

EXCEPTION
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => 'Retrieve_User_Perf_Measure'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_User_Perf_Measure;
--
function target_level_where_clause
return varchar2 is

 l_target_level_Tbl         target_level_Tbl_Type;
 l_where_clause             VARCHAR2(32000) := 'target_level_id in (';
 l_return_status            VARCHAR2(200);

begin

    FND_MSG_PUB.initialize;

  Retrieve_User_target_level
     ( p_user_id                  => icx_sec.getID(icx_sec.PV_USER_ID, '', icx_sec.g_session_id) --2751984
     , x_Target_Level_Tbl         => l_Target_Level_Tbl
     , x_return_status            => l_return_status);

  if l_Target_Level_Tbl.COUNT <> 0 then
    --
    for i in l_Target_Level_Tbl.first .. l_Target_Level_Tbl.last
    loop
      --
      if i <> 1 then
        --
        l_where_clause := l_where_clause || ',';
        --
      end if;
      --
      l_where_clause := l_where_clause ||
                to_char(l_Target_Level_Tbl(i).Target_level_id);
      --
    end loop;
    --
    l_where_clause := l_where_clause || ')';
    --
  else
    l_where_clause := '';
  end if;
  --
  return (l_where_clause);

end Target_Level_where_clause;
--

----
function target_level_where_clause
(p_user_id IN NUMBER)
return varchar2 is

 l_target_level_Tbl         target_level_Tbl_Type;
 l_where_clause             VARCHAR2(32000) := 'target_level_id in (';
 l_return_status            VARCHAR2(200);

begin

    FND_MSG_PUB.initialize;

  Retrieve_User_target_level
     ( p_user_id                  => p_user_id
     , x_Target_Level_Tbl         => l_Target_Level_Tbl
     , x_return_status            => l_return_status);

  if l_Target_Level_Tbl.COUNT <> 0 then
    --
    for i in l_Target_Level_Tbl.first .. l_Target_Level_Tbl.last
    loop
      --
      if i <> 1 then
        --
        l_where_clause := l_where_clause || ',';
        --
      end if;
      --
      l_where_clause := l_where_clause ||
                to_char(l_Target_Level_Tbl(i).Target_level_id);
      --
    end loop;
    --
    l_where_clause := l_where_clause || ')';
    --
  else
    l_where_clause := '';
  end if;
  --
  return (l_where_clause);

end Target_Level_where_clause;
--
--
function Perf_measure_where_clause
                             return varchar2 is

 l_Perf_measure_Tbl  Perf_Measure_Tbl_Type;
 l_where_clause             VARCHAR2(32000) := 'measure_id in (';
 l_return_status            VARCHAR2(200);

begin

    FND_MSG_PUB.initialize;

  Retrieve_User_perf_measure
     ( p_user_id           => icx_sec.getID(icx_sec.PV_USER_ID, '', icx_sec.g_session_id) --2751984
     , x_Perf_measure_Tbl  => l_Perf_measure_Tbl
     , x_return_status     => l_return_status);

  if l_Perf_measure_Tbl.COUNT <> 0 then
    --
    for i in l_Perf_measure_Tbl.first .. l_Perf_measure_Tbl.last
    loop
      --
      if i <> 1 then
        --
        l_where_clause := l_where_clause || ',';
        --
      end if;
      --
      l_where_clause := l_where_clause ||
                to_char(l_perf_measure_Tbl(i).measure_id);
      --
    end loop;
    --
    l_where_clause := l_where_clause || ')';
  else
    l_where_clause := '';
  end if;
  --
  return (l_where_clause);

end perf_measure_where_clause;

--
function Perf_measure_where_clause
(p_user_id IN NUMBER)
 return varchar2 is

 l_Perf_measure_Tbl  Perf_Measure_Tbl_Type;
 l_where_clause             VARCHAR2(32000) := 'measure_id in (';
 l_return_status            VARCHAR2(200);

begin

    FND_MSG_PUB.initialize;

  Retrieve_User_perf_measure
     ( p_user_id           => p_user_id
     , x_Perf_measure_Tbl  => l_Perf_measure_Tbl
     , x_return_status     => l_return_status);

  if l_Perf_measure_Tbl.COUNT <> 0 then
    --
    for i in l_Perf_measure_Tbl.first .. l_Perf_measure_Tbl.last
    loop
      --
      if i <> 1 then
        --
        l_where_clause := l_where_clause || ',';
        --
      end if;
      --
      l_where_clause := l_where_clause ||
                to_char(l_perf_measure_Tbl(i).measure_id);
      --
    end loop;
    --
    l_where_clause := l_where_clause || ')';
  else
    l_where_clause := '';
  end if;
  --
  return (l_where_clause);

end perf_measure_where_clause;

--
PROCEDURE resequence_dim_level_values
(p_dim_values_rec   IN   BIS_TARGET_PUB.TARGET_REC_TYPE
,p_sequence_dir     IN   VARCHAR2
,x_dim_values_rec   IN OUT NOCOPY  BIS_TARGET_PUB.TARGET_REC_TYPE
,x_error_tbl        OUT NOCOPY  BIS_UTILITIES_PUB.ERROR_TBL_TYPE
)
IS
   CURSOR c_seq(p_targetlevel_id in NUMBER, p_dim IN VARCHAR2)  IS
   SELECT x.sequence_no
   FROM   bis_indicator_dimensions x, bis_dimensions y, bis_target_levels z
   WHERE  x.dimension_id = y.dimension_id
   AND    y.short_name like p_dim
   AND    x.indicator_id = z.indicator_id
   AND    ((z.target_level_id = p_targetlevel_id  and  p_targetlevel_id is not null) OR
          (z.short_name = p_dim_values_rec.target_level_short_name
            and p_dim_values_rec.target_level_short_name IS NOT NULL))
   ;
   l_org_Seq                  NUMBER;
   l_time_Seq                 NUMBER;
BEGIN
      x_dim_values_rec := p_dim_Values_rec;
      IF (p_sequence_dir = 'N') THEN
          IF ((BIS_UTILITIES_PVT.value_missing(p_dim_values_rec.org_level_value_id) = FND_API.G_FALSE ) OR
             (BIS_UTILITIES_PVT.value_missing(p_dim_values_rec.time_level_value_id) = FND_API.G_FALSE))
          THEN
          OPEN c_seq(p_dim_values_rec.target_level_id
                    ,BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_TargetLevelId => p_dim_values_rec.target_level_id
                                                                ,p_TargetLevelName => NULL));
          FETCH c_seq INTO l_org_seq;
          CLOSE c_seq;
          OPEN c_seq(p_dim_values_rec.target_level_id
                    ,BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_TargetLevelId => p_dim_values_rec.target_level_id
                                                                 ,p_TargetLevelName => NULL));
          FETCH c_seq INTO l_time_seq;
          CLOSE c_seq;
          x_dim_values_rec := p_dim_Values_rec;
          IF (l_org_Seq = 1) THEN
             x_dim_values_rec.dim1_level_Value_id:= p_dim_values_rec.org_level_value_id ;
             x_dim_values_rec.dim1_level_value_name:= p_dim_values_rec.org_level_value_name ;
          END IF;
         IF (l_org_Seq = 2) THEN
            x_dim_values_rec.dim2_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim2_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 3) THEN
            x_dim_values_rec.dim3_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim3_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 4) THEN
            x_dim_values_rec.dim4_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim4_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 5) THEN
            x_dim_values_rec.dim5_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim5_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 6) THEN
            x_dim_values_rec.dim6_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim6_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 7) THEN
            x_dim_values_rec.dim7_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim7_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_time_seq = 1) THEN
            x_dim_values_rec.dim1_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim1_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 2) THEN
            x_dim_values_rec.dim2_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim2_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 3) THEN
            x_dim_values_rec.dim3_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim3_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 4) THEN
            x_dim_values_rec.dim4_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim4_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 5) THEN
            x_dim_values_rec.dim5_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim5_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 6) THEN
            x_dim_values_rec.dim6_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim6_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 7) THEN
            x_dim_values_rec.dim7_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim7_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         END IF;
          /*x_dim_values_rec := p_dim_Values_rec;
          IF (p_dim_values_rec.dim1_level_value_id =  FND_API.G_MISS_CHAR) THEN
             IF ((p_dim_values_rec.dim2_level_value_id = FND_API.G_MISS_CHAR) AND
                (p_dim_values_rec.dim3_level_value_id = FND_API.G_MISS_CHAR) AND
                (p_dim_values_Rec.dim4_level_value_id = FND_API.G_MISS_CHAR) AND
                (p_dim_values_rec.dim5_level_value_id = FND_API.G_MISS_CHAR)) THEN
                x_dim_values_rec.dim1_level_value_id := p_dim_Values_rec.org_level_value_id;
                x_dim_values_rec.dim2_level_value_id := p_dim_Values_rec.time_level_value_id;
            RETURN;
          END IF;
          END IF;
          IF (p_dim_values_rec.dim2_level_value_id = FND_API.G_MISS_CHAR) THEN
              IF ((p_dim_values_rec.dim3_level_value_id = FND_API.G_MISS_CHAR) AND
                 (p_dim_values_Rec.dim4_level_value_id = FND_API.G_MISS_CHAR) AND
                 (p_dim_values_Rec.dim5_level_Value_id = FND_API.G_MISS_CHAR)) THEN
                 x_Dim_values_rec.dim2_level_Value_id := p_dim_Values_rec.org_level_Value_id;
                 x_dim_values_rec.dim3_level_value_id := p_dim_Values_rec.time_level_Value_id;
             RETURN;
              END IF;
          END IF;
          IF (p_dim_values_rec.dim3_level_value_id IS NULL) THEN
             IF ((p_dim_values_rec.dim4_level_value_id IS NULL) AND
                (p_dim_values_Rec.dim5_level_value_id IS NULL) ) THEN
                x_Dim_values_rec.dim3_level_Value_id := p_dim_Values_rec.org_level_Value_id;
                x_dim_values_rec.dim4_level_value_id := p_dim_Values_rec.time_level_Value_id;
            RETURN;
             END IF;
          END IF;
          IF (p_dim_values_rec.dim4_level_value_id IS NULL) THEN
              IF (p_dim_values_rec.dim5_level_value_id IS NULL)  THEN
                 x_Dim_values_rec.dim4_level_Value_id := p_dim_Values_rec.org_level_Value_id;
                 x_dim_values_rec.dim5_level_value_id := p_dim_Values_rec.time_level_Value_id;
             RETURN;
              END IF;
          END IF;
          IF (p_dim_values_rec.dim5_level_value_id IS NULL) THEN
              x_Dim_values_rec.dim5_level_Value_id := p_dim_Values_rec.org_level_Value_id;
              x_dim_values_rec.dim6_level_value_id := p_dim_Values_rec.time_level_Value_id;
          RETURN;
          END IF;
          x_dim_values_rec.dim6_level_value_id := p_dim_Values_rec.org_level_value_id;
          x_dim_values_rec.dim7_level_value_id := p_dim_Values_rec.time_level_value_id;
          */
   END IF;
   IF (p_Sequence_dir = 'R') THEN
      --Get the sequence number for Org and Time Dimensions
      OPEN c_seq(p_dim_values_rec.target_level_id
                ,BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_TargetLevelId => p_dim_values_rec.target_level_id
                                                            ,p_TargetLevelName => NULL));
      FETCH c_seq INTO l_org_seq;
      CLOSE c_seq;
      OPEN c_seq(p_dim_values_rec.target_level_id
                ,BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_TargetLevelId => p_dim_values_rec.target_level_id
                                                             ,p_TargetLevelName => NULL));
      FETCH c_seq INTO l_time_seq;
      CLOSE c_seq;
      x_dim_values_rec := p_dim_Values_rec;
      IF (l_org_Seq = 1) THEN
         x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim1_level_Value_id;
         x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim1_level_value_name;
      END IF;
      IF (l_org_Seq = 2) THEN
         x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim2_level_Value_id;
         x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim2_level_value_name;
      END IF;
      IF (l_org_Seq = 3) THEN
         x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim3_level_Value_id;
         x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim3_level_value_name;
      END IF;
      IF (l_org_Seq = 4) THEN
         x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim4_level_Value_id;
         x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim4_level_value_name;
      END IF;
      IF (l_org_Seq = 5) THEN
         x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim5_level_Value_id;
         x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim5_level_value_name;
      END IF;
      IF (l_org_Seq = 6) THEN
         x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim6_level_Value_id;
         x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim6_level_value_name;
      END IF;
      IF (l_org_Seq = 7) THEN
         x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim7_level_Value_id;
         x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim7_level_value_name;
      END IF;
      IF (l_time_seq = 1) THEN
         x_dim_values_rec.time_level_value_id := p_dim_values_rec.dim1_level_Value_id;
         x_dim_values_rec.time_level_value_name := p_dim_values_rec.dim1_level_value_name;
      END IF;
      IF (l_time_seq = 2) THEN
         x_dim_values_rec.time_level_value_id := p_dim_values_rec.dim2_level_Value_id;
         x_dim_values_rec.time_level_value_name := p_dim_values_rec.dim2_level_value_name;
      END IF;
      IF (l_time_seq = 3) THEN
         x_dim_values_rec.time_level_value_id := p_dim_values_rec.dim3_level_Value_id;
         x_dim_values_rec.time_level_value_name := p_dim_values_rec.dim3_level_value_name;
      END IF;
      IF (l_time_seq = 4) THEN
         x_dim_values_rec.time_level_value_id := p_dim_values_rec.dim4_level_Value_id;
         x_dim_values_rec.time_level_value_name := p_dim_values_rec.dim4_level_value_name;
      END IF;
      IF (l_time_seq = 5) THEN
         x_dim_values_rec.time_level_value_id := p_dim_values_rec.dim5_level_Value_id;
         x_dim_values_rec.time_level_value_name := p_dim_values_rec.dim5_level_value_name;
      END IF;
      IF (l_time_seq = 6) THEN
         x_dim_values_rec.time_level_value_id := p_dim_values_rec.dim6_level_Value_id;
         x_dim_values_rec.time_level_value_name := p_dim_values_rec.dim6_level_value_name;
      END IF;
      IF (l_time_seq = 7) THEN
         x_dim_values_rec.time_level_value_id := p_dim_values_rec.dim7_level_Value_id;
         x_dim_values_rec.time_level_value_name := p_dim_values_rec.dim7_level_value_name;
      END IF;
  END IF;

EXCEPTION
WHEN OTHERS
    THEN NULL;
END;
--
PROCEDURE resequence_dim_levels
(p_dim_level_rec    IN   BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE
,p_sequence_dir     IN   VARCHAR2
,x_dim_level_rec    IN OUT NOCOPY  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE
,x_error_tbl        OUT NOCOPY  BIS_UTILITIES_PUB.ERROR_TBL_TYPE
)
IS
   CURSOR c_seq(p_targetlevel_id in NUMBER, p_dim IN VARCHAR2)  IS
   SELECT x.sequence_no
   FROM   bis_indicator_dimensions x, bis_dimensions y, bis_target_levels z
   WHERE  x.dimension_id = y.dimension_id
   AND    y.short_name like p_dim
   AND    x.indicator_id = z.indicator_id
   AND    z.target_level_id = p_targetlevel_id;
   l_org_Seq                  NUMBER;
   l_time_Seq                 NUMBER;
BEGIN
      x_dim_level_rec := p_Dim_level_rec;
   IF (p_sequence_dir = 'N') THEN
     IF ((p_Dim_level_rec.org_level_id <> FND_API.G_MISS_NUM) OR
        (p_dim_level_Rec.time_level_id <> FND_API.G_MISS_NUM)) THEN
       OPEN c_seq(x_dim_level_rec.target_level_id
                , BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_TargetLevelId => x_dim_level_rec.target_level_id
                                                             ,p_TargetLevelName => NULL));
       FETCH c_seq INTO l_org_seq;
       CLOSE c_seq;
       OPEN c_seq(x_dim_level_Rec.target_level_id
                 , BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_TargetLevelId => x_dim_level_Rec.target_level_id
                                                               ,p_TargetLevelName => NULL));
       FETCH c_seq INTO l_time_seq;
       CLOSE c_seq;
       x_dim_level_rec := p_dim_level_rec;
       IF (l_org_seq = 1) THEN
          x_dim_level_rec.dimension1_level_id:= p_dim_level_rec.org_level_id ;
          x_dim_level_rec.dimension1_level_name:= p_dim_level_rec.org_level_name ;
          x_dim_level_rec.dimension1_level_short_name:= p_dim_level_rec.org_level_short_name ;
       END IF;
       IF (l_org_seq = 2) THEN
          x_dim_level_rec.dimension2_level_id:= p_dim_level_rec.org_level_id ;
          x_dim_level_rec.dimension2_level_name:= p_dim_level_rec.org_level_name ;
          x_dim_level_rec.dimension2_level_short_name:= p_dim_level_rec.org_level_short_name ;
       END IF;
       IF (l_org_seq = 3) THEN
          x_dim_level_rec.dimension3_level_id:= p_dim_level_rec.org_level_id ;
          x_dim_level_rec.dimension3_level_name:= p_dim_level_rec.org_level_name ;
          -- meastmon 08/14/2001 Fix this typing error  ---------------------------
          -- x_dim_level_rec.dimension4_level_short_name:= p_dim_level_rec.org_level_short_name ;
          x_dim_level_rec.dimension3_level_short_name:= p_dim_level_rec.org_level_short_name ;
          -- ---------------------------------------------------------------------------
       END IF;
       -- meastmon 08/14/2001 Add condition for l_org_seq = 4 -------------------
       IF (l_org_seq = 4) THEN
          x_dim_level_rec.dimension4_level_id:= p_dim_level_rec.org_level_id ;
          x_dim_level_rec.dimension4_level_name:= p_dim_level_rec.org_level_name ;
          x_dim_level_rec.dimension4_level_short_name:= p_dim_level_rec.org_level_short_name ;
       END IF;
       -- ---------------------------------------------------------------------------
       IF (l_org_seq = 5) THEN
          x_dim_level_rec.dimension5_level_id:= p_dim_level_rec.org_level_id ;
          x_dim_level_rec.dimension5_level_name:= p_dim_level_rec.org_level_name ;
          x_dim_level_rec.dimension5_level_short_name:= p_dim_level_rec.org_level_short_name ;
       END IF;
       IF (l_org_seq = 6) THEN
          x_dim_level_rec.dimension6_level_id:= p_dim_level_rec.org_level_id ;
          x_dim_level_rec.dimension6_level_name:= p_dim_level_rec.org_level_name ;
          x_dim_level_rec.dimension6_level_short_name:= p_dim_level_rec.org_level_short_name ;
       END IF;
       IF (l_org_seq = 7) THEN
          x_dim_level_rec.dimension7_level_id:= p_dim_level_rec.org_level_id ;
          x_dim_level_rec.dimension7_level_name:= p_dim_level_rec.org_level_name ;
          x_dim_level_rec.dimension7_level_short_name:= p_dim_level_rec.org_level_short_name ;
       END IF;
       IF (l_time_seq = 1) THEN
          x_dim_level_rec.dimension1_level_id:= p_dim_level_rec.time_level_id ;
          x_dim_level_Rec.dimension1_level_name:= p_dim_level_rec.time_level_name ;
          x_dim_level_rec.dimension1_level_short_name:= p_dim_level_rec.time_level_short_name ;
       END IF;
       IF (l_time_seq = 2) THEN
          x_dim_level_rec.dimension2_level_id:= p_dim_level_rec.time_level_id ;
          x_dim_level_Rec.dimension2_level_name:= p_dim_level_rec.time_level_name ;
          x_dim_level_rec.dimension2_level_short_name:= p_dim_level_rec.time_level_short_name ;
       END IF;
       IF (l_time_seq = 3) THEN
          x_dim_level_rec.dimension3_level_id:= p_dim_level_rec.time_level_id ;
          x_dim_level_Rec.dimension3_level_name:= p_dim_level_rec.time_level_name ;
          x_dim_level_rec.dimension3_level_short_name:= p_dim_level_rec.time_level_short_name ;
       END IF;
       IF (l_time_seq = 4) THEN
          x_dim_level_rec.dimension4_level_id:= p_dim_level_rec.time_level_id ;
          x_dim_level_Rec.dimension4_level_name:= p_dim_level_rec.time_level_name ;
          x_dim_level_rec.dimension4_level_short_name:= p_dim_level_rec.time_level_short_name ;
       END IF;
       IF (l_time_seq = 5) THEN
          x_dim_level_rec.dimension5_level_id:= p_dim_level_rec.time_level_id ;
          x_dim_level_Rec.dimension5_level_name:= p_dim_level_rec.time_level_name ;
          x_dim_level_rec.dimension5_level_short_name:= p_dim_level_rec.time_level_short_name ;
       END IF;
       IF (l_time_seq = 6) THEN
          x_dim_level_rec.dimension6_level_id:= p_dim_level_rec.time_level_id ;
          x_dim_level_Rec.dimension6_level_name:= p_dim_level_rec.time_level_name ;
          x_dim_level_rec.dimension6_level_short_name:= p_dim_level_rec.time_level_short_name ;
       END IF;
       IF (l_time_seq = 7) THEN
          x_dim_level_rec.dimension7_level_id:= p_dim_level_rec.time_level_id ;
          x_dim_level_Rec.dimension7_level_name:= p_dim_level_rec.time_level_name ;
          x_dim_level_rec.dimension7_level_short_name:= p_dim_level_rec.time_level_short_name ;
       END IF;
       END IF;
   END IF;
   IF (p_sequence_dir = 'R' ) THEN
       OPEN c_seq(x_dim_level_rec.target_level_id
                , BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_TargetLevelId => x_dim_level_rec.target_level_id
                                                             ,p_TargetLevelName => NULL));
       FETCH c_seq INTO l_org_seq;
       CLOSE c_seq;
       OPEN c_seq(x_dim_level_Rec.target_level_id
                , BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_TargetLevelId => x_dim_level_Rec.target_level_id
                                                              ,p_TargetLevelName => NULL));
       FETCH c_seq INTO l_time_seq;
       CLOSE c_seq;
       x_dim_level_rec := p_dim_level_rec;
       IF (l_org_seq = 1) THEN
          x_dim_level_rec.org_level_id := p_dim_level_rec.dimension1_level_id;
          x_dim_level_rec.org_level_name := p_dim_level_rec.dimension1_level_name;
          x_dim_level_rec.org_level_short_name := p_dim_level_rec.dimension1_level_short_name;
       END IF;
       IF (l_org_seq = 2) THEN
          x_dim_level_rec.org_level_id := p_dim_level_rec.dimension2_level_id;
          x_dim_level_rec.org_level_name := p_dim_level_rec.dimension2_level_name;
          x_dim_level_rec.org_level_short_name := p_dim_level_rec.dimension2_level_short_name;
       END IF;
       IF (l_org_seq = 3) THEN
          x_dim_level_rec.org_level_id := p_dim_level_rec.dimension3_level_id;
          x_dim_level_rec.org_level_name := p_dim_level_rec.dimension3_level_name;
          x_dim_level_rec.org_level_short_name := p_dim_level_rec.dimension3_level_short_name;
       END IF;
       IF (l_org_seq = 4) THEN
          x_dim_level_rec.org_level_id := p_dim_level_rec.dimension4_level_id;
          x_dim_level_rec.org_level_name := p_dim_level_rec.dimension4_level_name;
          x_dim_level_rec.org_level_short_name := p_dim_level_rec.dimension4_level_short_name;
       END IF;
       IF (l_org_seq = 5) THEN
          x_dim_level_rec.org_level_id := p_dim_level_rec.dimension5_level_id;
          x_dim_level_rec.org_level_name := p_dim_level_rec.dimension5_level_name;
          x_dim_level_rec.org_level_short_name := p_dim_level_rec.dimension5_level_short_name;
       END IF;
       IF (l_org_seq = 6) THEN
          x_dim_level_rec.org_level_id := p_dim_level_rec.dimension6_level_id;
          x_dim_level_rec.org_level_name := p_dim_level_rec.dimension6_level_name;
          x_dim_level_rec.org_level_short_name := p_dim_level_rec.dimension6_level_short_name;
       END IF;
       IF (l_org_seq = 7) THEN
          x_dim_level_rec.org_level_id := p_dim_level_rec.dimension7_level_id;
          x_dim_level_rec.org_level_name := p_dim_level_rec.dimension7_level_name;
          x_dim_level_rec.org_level_short_name := p_dim_level_rec.dimension7_level_short_name;
       END IF;
       IF (l_time_seq = 1) THEN
          x_dim_level_rec.time_level_id := p_dim_level_rec.dimension1_level_id;
          x_dim_level_Rec.time_level_name := p_dim_level_rec.dimension1_level_name;
          x_dim_level_rec.time_level_short_name := p_dim_level_rec.dimension1_level_short_name;
       END IF;
       IF (l_time_seq = 2) THEN
          x_dim_level_rec.time_level_id := p_dim_level_rec.dimension2_level_id;
          x_dim_level_Rec.time_level_name := p_dim_level_rec.dimension2_level_name;
          x_dim_level_rec.time_level_short_name := p_dim_level_rec.dimension2_level_short_name;
       END IF;
       IF (l_time_seq = 3) THEN
          x_dim_level_rec.time_level_id := p_dim_level_rec.dimension3_level_id;
          x_dim_level_Rec.time_level_name := p_dim_level_rec.dimension3_level_name;
          x_dim_level_rec.time_level_short_name := p_dim_level_rec.dimension3_level_short_name;
       END IF;
       IF (l_time_seq = 4) THEN
          x_dim_level_rec.time_level_id := p_dim_level_rec.dimension4_level_id;
          x_dim_level_Rec.time_level_name := p_dim_level_rec.dimension4_level_name;
          x_dim_level_rec.time_level_short_name := p_dim_level_rec.dimension4_level_short_name;
       END IF;
       IF (l_time_seq = 5) THEN
          x_dim_level_rec.time_level_id := p_dim_level_rec.dimension5_level_id;
          x_dim_level_Rec.time_level_name := p_dim_level_rec.dimension5_level_name;
          x_dim_level_rec.time_level_short_name := p_dim_level_rec.dimension5_level_short_name;
       END IF;
       IF (l_time_seq = 6) THEN
          x_dim_level_rec.time_level_id := p_dim_level_rec.dimension6_level_id;
          x_dim_level_Rec.time_level_name := p_dim_level_rec.dimension6_level_name;
          x_dim_level_rec.time_level_short_name := p_dim_level_rec.dimension6_level_short_name;
       END IF;
       IF (l_time_seq = 7) THEN
          x_dim_level_rec.time_level_id := p_dim_level_rec.dimension7_level_id;
          x_dim_level_Rec.time_level_name := p_dim_level_rec.dimension7_level_name;
          x_dim_level_rec.time_level_short_name := p_dim_level_rec.dimension7_level_short_name;
       END IF;
   END IF;
END;
--
PROCEDURE reseq_actual_dim_level_values
(p_dim_values_Rec   IN   BIS_ACTUAL_PUB.Actual_rec_type
,p_Sequence_dir     IN   VARCHAR2
,x_dim_values_rec   IN OUT NOCOPY  BIS_ACTUAL_PUB.Actual_rec_type
,x_error_tbl        OUT NOCOPY  BIS_UTILITIES_PUB.ERROR_TBL_TYPE
)
IS
   CURSOR c_seq(p_targetlevel_id in NUMBER, p_dim IN VARCHAR2)  IS
   SELECT x.sequence_no
   FROM   bis_indicator_dimensions x, bis_dimensions y, bis_target_levels z
   WHERE  x.dimension_id = y.dimension_id
   AND    y.short_name like p_dim
   AND    x.indicator_id = z.indicator_id
   AND    ((z.target_level_id = p_targetlevel_id  and  p_targetlevel_id is not null) OR
          (z.short_name = p_dim_values_rec.target_level_short_name
            and p_dim_values_rec.target_level_short_name IS NOT NULL))
   ;
   l_org_Seq                  NUMBER;
   l_time_Seq                 NUMBER;
BEGIN
      x_dim_values_rec := p_Dim_values_rec;
   IF (p_sequence_dir = 'N') THEN
          IF ((BIS_UTILITIES_PVT.value_missing(p_dim_values_rec.org_level_value_id) = FND_API.G_FALSE ) OR
             (BIS_UTILITIES_PVT.value_missing(p_dim_values_rec.time_level_value_id) = FND_API.G_FALSE))
          THEN
          OPEN c_seq(p_dim_values_rec.target_level_id
                    ,BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_TargetLevelId => p_dim_values_rec.target_level_id
                                                               , p_TargetLevelName => NULL));
          FETCH c_seq INTO l_org_seq;
          CLOSE c_seq;
          OPEN c_seq(p_dim_values_rec.target_level_id
                    ,BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_TargetLevelId => p_dim_values_rec.target_level_id
                                                                 ,p_TargetLevelName => NULL));
          FETCH c_seq INTO l_time_seq;
          CLOSE c_seq;
          x_dim_values_rec := p_dim_Values_rec;
          IF (l_org_Seq = 1) THEN
             x_dim_values_rec.dim1_level_Value_id:= p_dim_values_rec.org_level_value_id ;
             x_dim_values_rec.dim1_level_value_name:= p_dim_values_rec.org_level_value_name ;
          END IF;
         IF (l_org_Seq = 2) THEN
            x_dim_values_rec.dim2_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim2_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 3) THEN
            x_dim_values_rec.dim3_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim3_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 4) THEN
            x_dim_values_rec.dim4_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim4_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 5) THEN
            x_dim_values_rec.dim5_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim5_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 6) THEN
            x_dim_values_rec.dim6_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim6_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 7) THEN
            x_dim_values_rec.dim7_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim7_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_time_seq = 1) THEN
            x_dim_values_rec.dim1_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim1_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 2) THEN
            x_dim_values_rec.dim2_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim2_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 3) THEN
            x_dim_values_rec.dim3_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim3_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 4) THEN
            x_dim_values_rec.dim4_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim4_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 5) THEN
            x_dim_values_rec.dim5_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim5_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 6) THEN
            x_dim_values_rec.dim6_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim6_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         IF (l_time_seq = 7) THEN
            x_dim_values_rec.dim7_level_Value_id:= p_dim_values_rec.time_level_value_id ;
            x_dim_values_rec.dim7_level_value_name:= p_dim_values_rec.time_level_value_name ;
         END IF;
         END IF;
   END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END;
--
-- mdamle 01/12/2001 - Resequence Indicator record
PROCEDURE reseq_ind_dim_level_values
(p_dim_values_Rec   IN   BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type
,p_Sequence_dir     IN   VARCHAR2
,x_dim_values_rec   IN OUT NOCOPY  BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type
,x_error_tbl        OUT NOCOPY  BIS_UTILITIES_PUB.ERROR_TBL_TYPE
)
IS
   CURSOR c_seq(p_targetlevel_id in NUMBER, p_dim IN VARCHAR2)  IS
   SELECT x.sequence_no
   FROM   bis_indicator_dimensions x, bis_dimensions y, bis_target_levels z
   WHERE  x.dimension_id = y.dimension_id
   AND    y.short_name like p_dim
   AND    x.indicator_id = z.indicator_id
   AND    ((z.target_level_id = p_targetlevel_id  and  p_targetlevel_id is not null) OR
          (z.short_name = p_dim_values_rec.target_level_short_name
            and p_dim_values_rec.target_level_short_name IS NOT NULL))
   ;
   l_org_Seq                  NUMBER;
   -- l_time_Seq                 NUMBER;
BEGIN
      x_dim_values_rec := p_Dim_values_rec;
   IF (p_sequence_dir = 'N') THEN

          IF ((BIS_UTILITIES_PVT.value_missing(p_dim_values_rec.org_level_value_id) = FND_API.G_FALSE ))
             -- OR (BIS_UTILITIES_PVT.value_missing(p_dim_values_rec.time_level_value_id) = FND_API.G_FALSE))
          THEN
          OPEN c_seq(p_dim_values_rec.target_level_id
                    ,BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_TargetLevelId => p_dim_values_rec.target_level_id
                                                                ,p_TargetLevelName => NULL));
          FETCH c_seq INTO l_org_seq;
          CLOSE c_seq;
          -- OPEN c_seq(p_dim_values_rec.target_level_id
          --   ,BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_TargetLevelId => p_dim_values_rec.target_level_i,p_TargetLevelName => NULL));
          -- FETCH c_seq INTO l_time_seq;
          -- CLOSE c_seq;
          x_dim_values_rec := p_dim_Values_rec;
          IF (l_org_Seq = 1) THEN
             x_dim_values_rec.dim1_level_Value_id:= p_dim_values_rec.org_level_value_id ;
             x_dim_values_rec.dim1_level_value_name:= p_dim_values_rec.org_level_value_name ;
          END IF;
         IF (l_org_Seq = 2) THEN
            x_dim_values_rec.dim2_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim2_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 3) THEN
            x_dim_values_rec.dim3_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim3_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 4) THEN
            x_dim_values_rec.dim4_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim4_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 5) THEN
            x_dim_values_rec.dim5_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim5_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 6) THEN
            x_dim_values_rec.dim6_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim6_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         IF (l_org_Seq = 7) THEN
            x_dim_values_rec.dim7_level_Value_id:= p_dim_values_rec.org_level_value_id ;
            x_dim_values_rec.dim7_level_value_name:= p_dim_values_rec.org_level_value_name ;
         END IF;
         END IF;
   END IF;
   -- mdamle 06/29/2001 - Bug#1842840 - Added the 'R' condition
      IF (p_sequence_dir = 'R' ) THEN
       OPEN c_seq(x_dim_values_rec.target_level_id
                , BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_TargetLevelId => x_dim_values_rec.target_level_id
                                                             ,p_TargetLevelName => NULL));
       FETCH c_seq INTO l_org_seq;
       CLOSE c_seq;
       x_dim_values_rec := p_dim_values_rec;
       IF (l_org_seq = 1) THEN
          x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim1_level_value_id;
          x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim1_level_value_name;
       END IF;
       IF (l_org_seq = 2) THEN
          x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim2_level_value_id;
          x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim2_level_value_name;
       END IF;
       IF (l_org_seq = 3) THEN
          x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim3_level_value_id;
          x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim3_level_value_name;
       END IF;
       -- meastmon 08/14/2001 Add condition for l_org_seq = 4 -------------------
       IF (l_org_seq = 4) THEN
          x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim4_level_value_id;
          x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim4_level_value_name;
       END IF;
       -- ----------------------------------------------------------------------
       IF (l_org_seq = 5) THEN
          x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim5_level_value_id;
          x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim5_level_value_name;
       END IF;
       IF (l_org_seq = 6) THEN
          x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim6_level_value_id;
          x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim6_level_value_name;
       END IF;
       IF (l_org_seq = 7) THEN
          x_dim_values_rec.org_level_value_id := p_dim_values_rec.dim7_level_value_id;
          x_dim_values_rec.org_level_value_name := p_dim_values_rec.dim7_level_value_name;
       END IF;
   END IF;


EXCEPTION
WHEN OTHERS THEN
  NULL;
END;
--
FUNCTION GET_TIME_DIMENSION_NAME
(p_DimLevelId IN NUMBER  := NULL
 ,p_DimLevelName IN VARCHAR2  := NULL
)
RETURN VARCHAR2
IS
  ------------------------
  CURSOR c_dim_id IS
  SELECT source
  FROM  bis_levels
  WHERE level_id = p_DimLevelId
  ;

  CURSOR c_dim_name IS
  SELECT source
  FROM  bis_levels
  WHERE short_name = p_DimLevelName
  ;
  ---------------------------
  l_source                 VARCHAR2(32000);
BEGIN
     -----------------
     if (p_DimLevelId is NOT NULL)
     then
       OPEN c_dim_id;
       FETCH c_dim_id INTO l_Source;
       CLOSE c_dim_id;
     else
       OPEN c_dim_name;
       FETCH c_dim_name INTO l_Source;
       CLOSE c_dim_name;
     end if;
     -----------------

    -- l_source := FND_PROFILE.value('BIS_SOURCE');
     IF (l_source = 'EDW')
     THEN
         RETURN 'EDW_TIME_M';
     END IF;
     IF (l_source = 'OLTP')
     THEN
        RETURN 'TIME';
     END IF;

END GET_TIME_DIMENSION_NAME;
--
FUNCTION GET_SOURCE_FROM_DIM_LEVEL
(p_DimLevelId IN NUMBER  := NULL
 ,p_DimLevelShortName IN VARCHAR2  := NULL
)
RETURN VARCHAR2
IS
  ------------------------
  CURSOR c_dim_id IS
  SELECT source
  FROM  bis_levels
  WHERE level_id = p_DimLevelId
  ;

  CURSOR c_dim_name IS
  SELECT source
  FROM  bis_levels
  WHERE short_name = p_DimLevelShortName
  ;
  ---------------------------
  l_source                 VARCHAR2(32000);
BEGIN
     -----------------
     if (p_DimLevelId is NOT NULL)
     then
       OPEN c_dim_id;
       FETCH c_dim_id INTO l_Source;
       CLOSE c_dim_id;
     else
       OPEN c_dim_name;
       FETCH c_dim_name INTO l_Source;
       CLOSE c_dim_name;
     end if;
     -----------------

     RETURN l_source;

EXCEPTION
  when others then
    BIS_UTILITIES_PUB.put_line(p_text => ' GET_SOURCE_FROM_DIM_LEVEL Error 0100 ' || sqlerrm ) ;
END GET_SOURCE_FROM_DIM_LEVEL;

--

FUNCTION GET_ORG_DIMENSION_NAME
(p_DimLevelId IN NUMBER  := NULL
 ,p_DimLevelName IN VARCHAR2  := NULL
)
RETURN VARCHAR2
IS
    ------------------------
  CURSOR c_dim_id IS
  SELECT source
  FROM  bis_levels
  WHERE level_id = p_DimLevelId
  ;

  CURSOR c_dim_name IS
  SELECT source
  FROM  bis_levels
  WHERE short_name = p_DimLevelName
  ;
  ---------------------------
    l_source                 VARCHAR2(32000);
BEGIN

     -----------------
     if (p_DimLevelId is NOT NULL)
     then
       OPEN c_dim_id;
       FETCH c_dim_id INTO l_Source;
       CLOSE c_dim_id;
     else
       OPEN c_dim_name;
       FETCH c_dim_name INTO l_Source;
       CLOSE c_dim_name;
     end if;
     -----------------
    --l_source := FND_PROFILE.value('BIS_SOURCE');
    IF (l_source = 'EDW')
    THEN
       RETURN 'EDW_ORGANIZATION_M';
    END IF;
    IF (l_Source = 'OLTP')
    THEN
       RETURN 'ORGANIZATION';
    END IF;


END GET_ORG_DIMENSION_NAME;
--
FUNCTION GET_INV_LOC_DIMENSION_NAME -- 2525408
(p_DimLevelId IN NUMBER  := NULL
,p_DimLevelName IN VARCHAR2  := NULL
)
RETURN VARCHAR2
IS
  CURSOR c_dim_id IS
  SELECT source
  FROM  bis_levels
  WHERE level_id = p_DimLevelId;

  CURSOR c_dim_name IS
  SELECT source
  FROM  bis_levels
  WHERE short_name = p_DimLevelName;

  l_source                 VARCHAR2(32000);
  l_dim_name               VARCHAR2(80);

BEGIN
  IF (p_DimLevelId is NOT NULL) THEN
    IF ( c_dim_id%ISOPEN ) THEN
      CLOSE c_dim_id;
    END IF;
    OPEN c_dim_id;
    FETCH c_dim_id INTO l_Source;
    CLOSE c_dim_id;
  ELSE
    IF ( c_dim_name%ISOPEN ) THEN
      CLOSE c_dim_id;
    END IF;
    OPEN c_dim_name;
    FETCH c_dim_name INTO l_Source;
    CLOSE c_dim_name;
  END IF;
  l_dim_name := BIS_UTILITIES_PVT.GET_INV_LOC_DIMENSION_NAME_SRC (p_source => l_source);
  RETURN l_dim_name;

EXCEPTION
  WHEN OTHERS THEN
    IF ( c_dim_id%ISOPEN ) THEN
      CLOSE c_dim_id;
    END IF;
    IF ( c_dim_name%ISOPEN ) THEN
      CLOSE c_dim_id;
    END IF;
END GET_INV_LOC_DIMENSION_NAME;
--
FUNCTION GET_TIME_DIMENSION_NAME_TL
(p_TargetLevelId IN NUMBER := NULL
 ,p_TargetLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2
IS
  ------------------------
  CURSOR c_dim_id IS
  SELECT source
  FROM  bis_target_levels
  WHERE target_level_id = p_TargetLevelId
  ;

  CURSOR c_dim_name IS
  SELECT source
  FROM  bis_target_levels
  WHERE short_name = p_TargetLevelName
  ;
  ---------------------------
  l_source                 VARCHAR2(32000);
BEGIN
     -----------------
     if (p_TargetLevelId is NOT NULL)
     then
       OPEN c_dim_id;
       FETCH c_dim_id INTO l_Source;
       CLOSE c_dim_id;
     else
       OPEN c_dim_name;
       FETCH c_dim_name INTO l_Source;
       CLOSE c_dim_name;
     end if;
     -----------------

    -- l_source := FND_PROFILE.value('BIS_SOURCE');
     IF (l_source = 'EDW')
     THEN
         RETURN 'EDW_TIME_M';
     END IF;
     IF (l_source = 'OLTP')
     THEN
        RETURN 'TIME';
     END IF;

END GET_TIME_DIMENSION_NAME_TL;
--
FUNCTION GET_ORG_DIMENSION_NAME_TL
(p_TargetLevelId IN NUMBER := NULL
 ,p_TargetLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2
IS
  l_dim_short_name  VARCHAR2(80);
  l_source              VARCHAR2(32000);
  l_return_status   VARCHAR2(80);
  l_return_msg      VARCHAR2(32000);

    ------------------------
  CURSOR c_dim_id IS
  SELECT source
  FROM  bis_target_levels
  WHERE target_level_id = p_TargetLevelId
  ;

  CURSOR c_dim_name IS
  SELECT source
  FROM  bis_target_levels
  WHERE short_name = p_TargetLevelName
  ;
  ---------------------------

BEGIN

     -----------------
     if (p_TargetLevelId is NOT NULL)
     then
       OPEN c_dim_id;
       FETCH c_dim_id INTO l_Source;
       CLOSE c_dim_id;
     else
       OPEN c_dim_name;
       FETCH c_dim_name INTO l_Source;
       CLOSE c_dim_name;
     end if;
     -----------------
    --l_source := FND_PROFILE.value('BIS_SOURCE');

    IF (l_source = 'EDW')
    THEN
       get_org_dim_name_tl_edw
       ( p_tgt_lvl_short_name    => p_TargetLevelName,
     p_tgt_lvl_ID        => p_TargetLevelId,
     x_dimension_short_name  => l_dim_short_name,
     x_return_status     => l_return_status,
     x_return_msg        => l_return_msg);

      -- BIS_UTILITIES_PUB.put_line(p_text => ' l_dim_short_name = ' || l_dim_short_name ) ;
      RETURN l_dim_short_name ; -- 'EDW_ORGANIZATION_M';

    END IF;
    IF (l_Source = 'OLTP')
    THEN
       RETURN 'ORGANIZATION';
    END IF;


END GET_ORG_DIMENSION_NAME_TL;
--

PROCEDURE  get_org_dim_name_tl_edw
( p_tgt_lvl_short_name   IN VARCHAR2,
  p_tgt_lvl_ID       IN NUMBER,
  x_dimension_short_name OUT NOCOPY VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_return_msg       OUT NOCOPY VARCHAR2) IS

  l_tgt_lvl_short_name  VARCHAR2(80);
  l_err_track       NUMBER := 0;
  l_level_short_name    VARCHAR2(80);
  l_dim_short_name  VARCHAR2(80);

BEGIN

  IF p_tgt_lvl_short_name IS NULL THEN

    SELECT short_name
    INTO l_tgt_lvl_short_name
    FROM bis_target_levels
    WHERE target_level_id = p_tgt_lvl_ID;

  ELSE

    l_tgt_lvl_short_name := p_tgt_lvl_short_name;

  END IF;

  begin

    SELECT BL.short_name  -- 2735844
    INTO   l_level_short_name
    FROM   bis_levels BL,
           bis_target_levels BTL
    WHERE  BTL.short_name = l_tgt_lvl_short_name
         AND
       ( BL.level_id = BTL.dimension1_level_id
          OR BL.level_id = BTL.dimension2_level_id
          OR BL.level_id = BTL.dimension3_level_id
          OR BL.level_id = BTL.dimension4_level_id
          OR BL.level_id = BTL.dimension5_level_id
          OR BL.level_id = BTL.dimension6_level_id
          OR BL.level_id = BTL.dimension7_level_id )
         AND BL.short_name                         -- 2735844
               IN ('EDW_MTL_ILDM_OU', 'EDW_MTL_ILDM_PLANT',
                   'EDW_ORGA_OPER_UNIT', 'EDW_ORGA_ORG');

    select short_name
    into l_dim_short_name
    from bis_dimensions where dimension_id in
      (select dimension_id from bis_levels where short_name = l_level_short_name);


  exception
    when others then
      l_dim_short_name := 'EDW_ORGANIZATION_M';

  end;

  x_dimension_short_name := l_dim_short_name;

  l_err_track := 200;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>' Error in bisvutlb.get_org_dimension_name_tl_edw ' || l_err_track || sqlerrm);
    x_return_status := FND_API.G_RET_STS_ERROR;
END get_org_dim_name_tl_edw;

--

FUNCTION GET_TIME_DIMENSION_NAME_SRC
(p_source IN  VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  IF (p_source = 'EDW')
    THEN
       RETURN 'EDW_TIME_M';
    END IF;
  IF (p_Source = 'OLTP')
    THEN
       RETURN 'TIME';
    END IF;
END GET_TIME_DIMENSION_NAME_SRC;
--
FUNCTION GET_ORG_DIMENSION_NAME_SRC
(p_source IN  VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  IF (p_source = 'EDW')
    THEN
       RETURN 'EDW_ORGANIZATION_M';
    END IF;
  IF (p_Source = 'OLTP')
    THEN
       RETURN 'ORGANIZATION';
    END IF;
END GET_ORG_DIMENSION_NAME_SRC;
--
FUNCTION GET_INV_LOC_DIMENSION_NAME_SRC -- 2525408
(p_source IN  VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  IF ( p_source = 'EDW' ) THEN
    RETURN 'EDW_MTL_INVENTORY_LOC_M';
  END IF;
  IF ( p_Source = 'OLTP' ) THEN
    RETURN 'INVENTORY LOCATION';
  END IF;
END GET_INV_LOC_DIMENSION_NAME_SRC;
--
FUNCTION IS_TOTAL_DIMLEVEL
(p_dim_Level_short_name    IN    VARCHAR2
,  x_return_status           OUT NOCOPY   VARCHAR2
)
RETURN BOOLEAN
IS

  CURSOR c_dim_name IS
  SELECT source
  FROM  bis_levels
  WHERE short_name = p_dim_Level_short_name
  ;

  l_dimlevel_cut         VARCHAR2(2000);
  l_source               VARCHAR2(2000);
  l_length               NUMBER;
  l_is_total             BOOLEAN := FALSE;

BEGIN

    OPEN c_dim_name;
    FETCH c_dim_name INTO l_Source;
    IF c_dim_name%NOTFOUND THEN
      CLOSE c_dim_name;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RETURN FALSE;
    END IF;

    -- found now
    CLOSE c_dim_name;
    l_length := length(p_dim_level_short_name);

    IF (l_source = 'EDW') THEN

      l_dimlevel_cut := substr(p_dim_level_short_name,(l_length-1),2 );
--bug#2252888
--      BIS_UTILITIES_PUB.put_line(p_text =>'Dimensional Cut : ' || l_dimlevel_cut );

      if l_dimlevel_cut = '_A' then

        l_is_total := TRUE;

      end if;

   ELSIF (l_source = 'OLTP') THEN
     IF ( l_length >= 5 ) THEN

       l_dimlevel_cut := substr(p_dim_level_short_name,1, 5 );

       IF l_dimlevel_cut = 'TOTAL'  THEN

          l_is_total := TRUE;
       END IF;
     END IF;

    END IF;

    RETURN l_is_total;

  EXCEPTION
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => 'IS_TOTAL_DIMLEVEL'
      );

END IS_TOTAL_DIMLEVEL;


FUNCTION GET_TOTAL_DIMLEVEL_NAME
(p_dim_short_name    IN    VARCHAR2
 ,p_DimLevelId IN NUMBER := NULL
 ,p_DimLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2
IS
       ------------------------
  CURSOR c_dim_id IS
  SELECT source
  FROM  bis_levels
  WHERE level_id = p_DimLevelId
  ;

  CURSOR c_dim_name IS
  SELECT source
  FROM  bis_levels
  WHERE short_name = p_DimLevelName
  ;
  ---------------------------
    l_total_name           VARCHAR2(2000);
    l_source               VARCHAR2(2000);
BEGIN
    --This function just replaces or appends the characters to get the level short name
    -- for TOTAL level shortnames. It does not attempt to validate anything. This logic
    -- can be added if desired.

      -----------------
     if (p_DimLevelId is NOT NULL)
     then
       OPEN c_dim_id;
       FETCH c_dim_id INTO l_Source;
       CLOSE c_dim_id;
     else
       OPEN c_dim_name;
       FETCH c_dim_name INTO l_Source;
       CLOSE c_dim_name;
     end if;
     -----------------
--  2617369, use newly created get_total_dimlevel_name_src
    l_total_name := BIS_UTILITIES_PVT.GET_TOTAL_DIMLEVEL_NAME_SRC(p_dim_short_name => p_dim_short_name
                                                                 ,p_source => l_source);
    RETURN l_total_name;

END GET_TOTAL_DIMLEVEL_NAME;
--

FUNCTION GET_TOTAL_DIMLEVEL_NAME_TL
(p_dim_short_name    IN    VARCHAR2
 ,p_TargetLevelId IN NUMBER := NULL
 ,p_TargetLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2
IS
       ------------------------
  CURSOR c_dim_id IS
  SELECT source
  FROM  bis_target_levels
  WHERE target_level_id = p_TargetLevelId
  ;

  CURSOR c_dim_name IS
  SELECT source
  FROM  bis_target_levels
  WHERE short_name = p_TargetLevelName
  ;
  ---------------------------
    l_total_name           VARCHAR2(2000);
    l_source               VARCHAR2(2000);
    l_length               NUMBER;
BEGIN
    --This function just replaces or appends the characters to get the level short name
    -- for TOTAL level shortnames. It does not attempt to validate anything. This logic
    -- can be added if desired.

      -----------------
     if (p_TargetLevelId is NOT NULL)
     then
       OPEN c_dim_id;
       FETCH c_dim_id INTO l_Source;
       CLOSE c_dim_id;
     else
       OPEN c_dim_name;
       FETCH c_dim_name INTO l_Source;
       CLOSE c_dim_name;
     end if;
     -----------------

   -- l_source := FND_PROFILE.value('BIS_SOURCE');
    l_length := length(p_dim_short_name);
    IF (l_source = 'EDW')
    THEN
      l_total_name := substr(p_dim_short_name,1,(l_length-1) );
      l_total_name := l_total_name || 'A';
    END IF;
    IF (l_source = 'OLTP')
    THEN
       l_total_name := 'TOTAL_'||p_dim_short_name;
    END IF;
    RETURN l_total_name;

END GET_TOTAL_DIMLEVEL_NAME_TL;

--
FUNCTION GET_TOTAL_DIMLEVEL_NAME_SRC -- 2617369
(p_dim_short_name    IN    VARCHAR2
,p_source            IN    VARCHAR2
)
RETURN VARCHAR2
IS
  l_total_name           VARCHAR2(2000);
  l_length               NUMBER;

BEGIN

  l_length := length(p_dim_short_name);
  IF (p_source = 'EDW')
  THEN
    l_total_name := substr(p_dim_short_name,1,(l_length-1) );
    l_total_name := l_total_name || 'A';
  END IF;
  IF (p_source = 'OLTP')
  THEN
    l_total_name := 'TOTAL_'||p_dim_short_name;
  END IF;
  RETURN l_total_name;

END GET_TOTAL_DIMLEVEL_NAME_SRC;
--

FUNCTION GET_TIME_SHORT_NAME
(p_dim_level_id    IN   NUMBER
)
RETURN VARCHAR2
IS
   l_time_level_short_name  VARCHAR2(32000);
BEGIN

   SELECT SHORT_NAME
   INTO l_time_level_short_name
   FROM BIS_LEVELS
   WHERE LEVEL_ID = p_dim_level_id;

   RETURN l_time_level_short_name;

END GET_TIME_SHORT_NAME;



FUNCTION GET_TIME_FROM
( p_duration         IN   NUMBER
, p_table_name       IN   VARCHAR2
, p_time             IN   VARCHAR2
, p_id               IN   VARCHAR2
, p_id_col_name      IN   VARCHAR2
, p_value_col_name   IN   VARCHAR2
, p_Org_Level_ID     IN   VARCHAR2
, p_Org_Level_Short_name IN   VARCHAR2
, p_time_level_id    IN   NUMBER        -- :=11, 99 on bis115dv -- 1740789 -- sashaik
, p_time_level_sh_name IN   VARCHAR2
)
RETURN VARCHAR2
IS
   l_start_date          DATE;
   l_end_date            DATE;
   l_num                 NUMBER;
   l_date                DATE;
   l_time_value      VARCHAR2(240);
   v_value2              VARCHAR2(240);
   v_value3              VARCHAR2(240);

   l_selectStmt          VARCHAR2(32000);

   l_source      VARCHAR2(80);

   l_star   VARCHAR2(2) := '*';

   TYPE tcursor     IS REF CURSOR;
   l_cursor     tcursor;

   l_Org_Level_Id   VARCHAR2(50) := null; -- 'XXX' ;
   l_Org_Level_Short_name VARCHAR2(50) := null; -- 'XXX' ;
   l_value               VARCHAR2(240);
   l_min_start_date DATE;
   l_max_end_date   DATE;


BEGIN

  -- BIS_UTILITIES_PUB.put_line(p_text => ' Inside get_time_from ' );

  l_source := bis_utilities_pvt.GET_SOURCE_FROM_DIM_LEVEL
                (
                   p_DimLevelId         => p_time_level_id
                 , p_DimLevelShortName  => p_time_level_sh_name  -- l_level_name
                );

  BIS_UTILITIES_PUB.put_line(p_text =>' Source is '|| l_source );


  if ( l_source = 'OLTP' ) then
      bis_utilities_pvt.Get_Org_Info_Based_On_Source
      ( p_source        => l_source,
        p_org_level_id      => p_org_level_id,
        p_org_level_short_name  => p_org_level_short_name,
        x_org_level_id      => l_org_level_id,
        x_org_level_short_name  => l_org_level_short_name
      );
  elsif ( l_source = 'EDW') then
        l_org_level_id      := p_org_level_id;
        l_org_level_short_name  := p_org_level_short_name;
  elsif ( l_source <> 'EDW') then
       BIS_UTILITIES_PUB.put_line(p_text => ' ERROR: GET_TIME_FROM : source can be only either OLTP or EDW ' );
  end if;


  -- bis_utilities_pvt.
  Get_Start_End_Dates
  ( p_source        => l_source,
    p_view_name     => p_table_name,
    p_id_col_name       => p_id_col_name,
    p_id_value_name     => p_id,
    p_org_level_id  => l_org_level_id,
    p_org_level_short_name => l_org_level_short_name,
    x_start_date    => l_start_date,
    x_end_date      => l_end_date
  );


  l_num := l_end_date - l_start_date + 1;

  l_num := l_num * p_duration;

  l_date := l_start_date + l_num;


  -- bis_utilities_pvt.
  Get_Time_Level_Value
  ( p_source        => l_source ,
    p_table_name    => p_table_name,
    p_value_col_name    => p_value_col_name,
    p_Org_Level_ID  => l_Org_Level_ID,
    p_org_level_short_name => l_org_level_short_name,
    p_flag      => 'BOTH',
    p_date      => l_date,
    x_time_value    => l_time_value
  );


  if ( l_time_value is null ) then

     -- bis_utilities_pvt.
     Get_Min_Max_Start_End_Dates
     ( p_source     => l_source,
       p_view_name  => p_table_name,
       p_Org_Level_ID   => l_Org_Level_ID,
       p_org_level_short_name => l_org_level_short_name,
       x_min_start_date => l_min_start_date,
       x_max_end_date   => l_max_end_date
     );


     bis_utilities_pvt.Get_Time_Level_Value
     ( p_source     => l_source,
       p_table_name => p_table_name,
       p_value_col_name => p_value_col_name,
       p_Org_Level_ID   => l_Org_Level_ID,
       p_org_level_short_name => l_org_level_short_name,
       p_flag       => 'START',
       p_date       => l_min_start_date,
       x_time_value => l_time_value
     );

  end if;


--  v_from := l_time_value;
  BIS_UTILITIES_PUB.put_line(p_text => '  Time from = ' || l_time_value );

  return l_time_value;


 Exception
     when others then
    BIS_UTILITIES_PUB.put_line(p_text =>'GET_TIME_FROM : SQL Statement is  '|| l_selectStmt);
        BIS_UTILITIES_PUB.put_line(p_text =>'Error in Procedure   BIS_UTILITIES_PVT.GET_TIME_FROM 1000 : '||sqlerrm);

END GET_TIME_FROM;


FUNCTION GET_TIME_TO
(p_duration         IN   NUMBER
,p_table_name       IN   VARCHAR2
,p_time             IN   VARCHAR2
,p_id               IN   VARCHAR2
,p_id_col_name      IN   VARCHAR2
,p_value_col_name   IN   VARCHAR2
,p_Org_Level_ID     IN   VARCHAR2
,p_Org_Level_Short_name IN   VARCHAR2
,p_time_level_id    IN   NUMBER        -- :=11, 99 on bis115dv -- 1740789 -- sashaik
,p_time_level_sh_name IN VARCHAR2
)
RETURN VARCHAR2
IS
   l_start_date          DATE;
   l_end_date            DATE;
   l_num                 NUMBER;
   l_date                DATE;
   l_value               VARCHAR2(240);
   v_value2              VARCHAR2(240);
   v_value3              VARCHAR2(240);

   l_time_value      VARCHAR2(240);

   l_selectStmt          VARCHAR2(32000);
   v_Dummy               INTEGER;
   v_to                 VARCHAR2(32000);

   l_source     VARCHAR2(80);

   l_star       VARCHAR2(2) := '*';

   TYPE tcursor     IS REF CURSOR;
   l_cursor     tcursor;

   l_Org_Level_Id   VARCHAR2(50) := null; -- 'XXX' ;
   l_Org_Level_Short_name VARCHAR2(50) := null; -- 'XXX' ;
   l_min_start_date DATE;
   l_max_end_date   DATE;

BEGIN

  -- BIS_UTILITIES_PUB.put_line(p_text => ' Inside get_time_to ' );

  -- BIS_UTILITIES_PUB.put_line(p_text => ' p_id ' || p_id ) ;
  -- BIS_UTILITIES_PUB.put_line(p_text => ' p_id_col_name ' || p_id_col_name ) ;
  -- BIS_UTILITIES_PUB.put_line(p_text => ' p_value_col_name ' || p_value_col_name ) ;


  l_source := bis_utilities_pvt.GET_SOURCE_FROM_DIM_LEVEL
                (
                   p_DimLevelId         => p_time_level_id
                 , p_DimLevelShortName  => p_time_level_sh_name  -- l_level_name
                );


  if ( l_source = 'OLTP' ) then
      bis_utilities_pvt.Get_Org_Info_Based_On_Source
      ( p_source        => l_source,
        p_org_level_id      => p_org_level_id,
        p_org_level_short_name  => p_org_level_short_name,
        x_org_level_id      => l_org_level_id,
        x_org_level_short_name  => l_org_level_short_name
      );
  elsif ( l_source = 'EDW') then
        l_org_level_id      := p_org_level_id;
        l_org_level_short_name  := p_org_level_short_name;
  elsif ( l_source <> 'EDW') then
       BIS_UTILITIES_PUB.put_line(p_text => ' ERROR: GET_TIME_TO : source can be only either OLTP or EDW ' );
  end if;

  BIS_UTILITIES_PUB.put_line(p_text =>' Source is '|| l_source );



  bis_utilities_pvt.Get_Start_End_Dates
  ( p_source        => l_source,
    p_view_name     => p_table_name,
    p_id_col_name       => p_id_col_name,
    p_id_value_name     => p_id,
    p_org_level_id  => l_org_level_id,
    p_org_level_short_name => l_org_level_short_name,
    x_start_date    => l_start_date,
    x_end_date      => l_end_date
  );


  l_num := l_end_date - l_start_date + 1;

  l_num := l_num * p_duration;

  l_date := l_start_date + l_num;


  bis_utilities_pvt.Get_Time_Level_Value
  ( p_source        => l_source ,
    p_table_name    => p_table_name,
    p_value_col_name    => p_value_col_name,
    p_Org_Level_ID  => l_Org_Level_ID,
    p_org_level_short_name => l_org_level_short_name,
    p_flag      => 'BOTH',
    p_date      => l_date,
    x_time_value    => l_time_value
  );


  if ( l_time_value is null ) then

     bis_utilities_pvt.Get_Min_Max_Start_End_Dates
     ( p_source     => l_source,
       p_view_name  => p_table_name,
       p_Org_Level_ID   => l_Org_Level_ID,
       p_org_level_short_name => l_org_level_short_name,
       x_min_start_date => l_min_start_date,
       x_max_end_date   => l_max_end_date
     );


     bis_utilities_pvt.Get_Time_Level_Value
     ( p_source     => l_source,
       p_table_name => p_table_name,
       p_value_col_name => p_value_col_name,
       p_Org_Level_ID   => l_Org_Level_ID,
       p_org_level_short_name => l_org_level_short_name,
       p_flag       => 'END',
       p_date       => l_max_end_date,
       x_time_value => l_time_value
     );

  end if;


--  v_from := l_time_value;
  BIS_UTILITIES_PUB.put_line(p_text => '  Time to = ' || l_time_value );

  return l_time_value;


 Exception
     when others then
      BIS_UTILITIES_PUB.put_line(p_text => ' l_selectStmt is : ' || l_selectStmt);
      BIS_UTILITIES_PUB.put_line(p_text =>'Error in Procedure   BIS_UTILITIES_PVT.GET_TIME_TO : '||sqlerrm);

END GET_TIME_TO;


--***************************************************************************************
--***************************************************************************************


Procedure Get_Org_Info_Based_On_Source  -- what to do if org_id/short_name is missing.
( p_source       IN varchar2,
  p_org_level_id     IN varchar2,
  p_org_level_short_name IN varchar2,
  x_org_level_id     OUT NOCOPY varchar2,
  x_org_level_short_name OUT NOCOPY varchar2
)
IS

   l_org_level_id   varchar2(80);
  l_org_level_short_name varchar2(80);

BEGIN

    if ( p_source = 'OLTP' ) then

       if  ( bis_utilities_pub.value_not_missing ( p_org_level_id ) = FND_API.G_TRUE ) then
         l_Org_Level_Id := p_Org_Level_Id;
       else
         -- BIS_UTILITIES_PUB.put_line(p_text =>' org level id is missing ');
         l_Org_Level_Id := null;
       end if;

       if ( bis_utilities_pub.value_not_missing ( p_org_level_short_name ) = FND_API.G_TRUE ) then
         l_org_level_short_name := p_org_level_short_name;
       else
         -- BIS_UTILITIES_PUB.put_line(p_text =>' org level short name is missing ');
         l_org_level_short_name := null;
       end if;

    x_org_level_id := l_org_level_id;
    x_org_level_short_name := l_org_level_short_name;

    end if;

Exception

  when others then
        BIS_UTILITIES_PUB.put_line(p_text =>'Exception executing sql in Get_Org_Info_Based_On_Source 0100: '||sqlerrm);

END Get_Org_Info_Based_On_Source;



Procedure Get_Time_Level_Value_ID_Minus -- where (sysdate - p_sysdate_less) is between start and end dates..
( p_source      IN varchar2,
  p_view_name       IN varchar2,
  p_id_name         IN varchar2,
  p_org_level_id    IN varchar2,
  p_org_level_short_name IN varchar2,
  p_sysdate_less    IN number,
  x_time_id     OUT NOCOPY varchar2
)

IS

  l_date    DATE;
  l_time_id     VARCHAR2(32000) := NULL;

BEGIN


    l_date := trunc(sysdate) - p_sysdate_less;

    Get_Time_Level_Value_ID_Date
    ( p_source      => p_source,
      p_view_name       => p_view_name,
      p_id_name         => p_id_name,
      p_org_level_id    => p_org_level_id,
      p_org_level_short_name => p_org_level_short_name,
      p_target_date     => l_date,
      x_time_id     => l_time_id
    );

    x_time_id := l_time_id;

Exception

  when others then
        BIS_UTILITIES_PUB.put_line(p_text =>'Exception executing sql in Get_Time_Level_Value_ID_Minus 0100: '||sqlerrm);

END Get_Time_Level_Value_ID_Minus;

Procedure Get_Time_Level_Value_ID_Date  -- where target_date is between start and end dates..
( p_source      IN varchar2,        -- this and Get_Time_Level_Value_ID1 need to be combined.
  p_view_name       IN varchar2,
  p_id_name         IN varchar2,
  p_org_level_id    IN varchar2,
  p_org_level_short_name IN varchar2,
  p_target_date     IN date,
  x_time_id     OUT NOCOPY varchar2
)
IS
  l_sql     VARCHAR2(32000);
  l_time_id     VARCHAR2(32000) := NULL;
  l_star    VARCHAR2(2) := '*';
  l_star1       NUMBER := -9999;

--2684911
  CURSOR c_dim_lvl_sn( cp_lvl_values_view IN VARCHAR2) IS SELECT short_name FROM bis_levels WHERE
    level_values_view_name =  cp_lvl_values_view ;
  l_short_name   bis_levels.short_name%TYPE;
  l_time_lvl_dep_on_org    NUMBER(3);
  l_is_dep_on_org          BOOLEAN := FALSE;

  TYPE tcursor  IS REF CURSOR;
  l1_cursor tcursor;
BEGIN

  -- 2684911
  IF (c_dim_lvl_sn%ISOPEN) THEN
    CLOSE c_dim_lvl_sn;
  END IF;

  OPEN c_dim_lvl_sn(cp_lvl_values_view => p_view_name ) ;
  FETCH c_dim_lvl_sn INTO l_short_name;
  CLOSE c_dim_lvl_sn;

  l_time_lvl_dep_on_org := BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => l_short_name) ;
  IF (l_short_name IS NOT NULL AND l_time_lvl_dep_on_org = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN
    l_is_dep_on_org := TRUE;
  END IF;


  if p_source = 'EDW' then
    -- All rows in the view should have start/end date. If they don't, we want to avoid them.
     IF ( l_is_dep_on_org ) THEN -- 2684911
      l_sql := ' select ' || p_id_name
             || ' from ' || p_view_name
             || ' where :l_target_date between '
             ||   ' nvl(start_date, trunc(sysdate)+11) and nvl(end_date, trunc(sysdate)+10) '
             ||   ' and ' || p_id_name || ' not in (-1,0) '
             || ' and nvl(organization_id, :l_star1) = nvl(:p_Org_Level_ID, :l_star1) '
             || ' and nvl(organization_type, :l_star) = nvl(:p_Org_Level_Short_name, :l_star) '
             || ' ORDER BY abs( nvl(trunc(start_date), trunc (sysdate)) - '
         ||   '  nvl(trunc(end_date), trunc(sysdate))) ';
    ELSE
      l_sql := ' select ' || p_id_name
             || ' from ' || p_view_name
             || ' where :l_target_date between '
             ||   ' nvl(start_date, trunc(sysdate)+11) and nvl(end_date, trunc(sysdate)+10) '
             ||   ' and ' || p_id_name || ' not in (-1,0) '
             || ' ORDER BY abs( nvl(trunc(start_date), trunc (sysdate)) - '
         ||   '  nvl(trunc(end_date), trunc(sysdate))) ';
   END IF;
     -- Query is supposed to return just one record. However we take the first one.
   BEGIN

     IF (l_is_dep_on_org) THEN --2684911
       OPEN l1_cursor FOR l_sql using p_target_date , l_star1 ,p_Org_Level_ID, l_star1, l_star,p_Org_Level_Short_name , l_star ;
       FETCH l1_cursor INTO l_time_id;
       CLOSE l1_cursor;
     ELSE
       OPEN l1_cursor FOR l_sql using p_target_date;
       FETCH l1_cursor INTO l_time_id;
       CLOSE l1_cursor;
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
       if l1_cursor%isopen then
     close l1_cursor;
       end if;
       BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_sql );
       BIS_UTILITIES_PUB.put_line(p_text =>'Exception executing sql in Get_Time_Level_Value_ID_Date 0100: '||sqlerrm);
   END;
   elsif p_source = 'OLTP' then

    IF (l_is_dep_on_org) THEN --2684911
      l_sql := ' select distinct ' || p_id_name
             || ' from ' || p_view_name
             || ' where :l_target_date between '
             ||   ' nvl(start_date, trunc(sysdate)+11) and nvl(end_date, trunc(sysdate)+10) '
             || ' and nvl(organization_id, :l_star) = nvl(:p_Org_Level_ID, :l_star) '
             || ' and nvl(organization_type, :l_star) = nvl(:p_Org_Level_Short_name, :l_star) ';
    ELSE
      l_sql := ' select distinct ' || p_id_name
             || ' from ' || p_view_name
             || ' where :l_target_date between '
             ||   ' nvl(start_date, trunc(sysdate)+11) and nvl(end_date, trunc(sysdate)+10) '
             ||   ' and rownum < 2';
    END IF;

    BEGIN
      IF (l_is_dep_on_org) THEN --2684911
        EXECUTE IMMEDIATE l_sql INTO l_time_id
         using p_target_date, l_star, p_Org_Level_ID, l_star, l_star, p_Org_Level_Short_name, l_star;
      ELSE
        EXECUTE IMMEDIATE l_sql INTO l_time_id using p_target_date;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_sql );
        BIS_UTILITIES_PUB.put_line(p_text =>'Exception executing sql in Get_Time_Level_Value_ID_Date 0200: '||sqlerrm);
    END;
  end if;
  x_time_id := l_time_id;
Exception
  when others then
    BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_sql );
        BIS_UTILITIES_PUB.put_line(p_text =>'Exception executing sql in Get_Time_Level_Value_ID_Date 0300: '||sqlerrm);
    IF (c_dim_lvl_sn%ISOPEN) THEN
      CLOSE c_dim_lvl_sn;
    END IF;
END Get_Time_Level_Value_ID_Date;

Procedure Get_Time_Level_Value      -- where p_date is between start and end dates.
( p_source      IN varchar2,
  p_table_name      IN varchar2,
  p_value_col_name      IN varchar2,
  p_Org_Level_ID    IN varchar2,
  p_org_level_short_name IN varchar2,
  p_flag        IN varchar2,
  p_date        IN date,
  x_time_value      OUT NOCOPY varchar2
)
IS

  l_selectStmt  VARCHAR2(32000);
  l_time_value  VARCHAR2(32000) := NULL;
  v_value2  VARCHAR2(3000) := NULL;

  l_star    VARCHAR2(2) := '*';

  l_star1   NUMBER :=  -9999;

--2684911
  CURSOR c_dim_lvl_sn( cp_lvl_values_view IN VARCHAR2) IS SELECT short_name FROM bis_levels WHERE
    level_values_view_name =  cp_lvl_values_view ;
  l_short_name   bis_levels.short_name%TYPE;
  l_time_lvl_dep_on_org    NUMBER(3);
  l_is_dep_on_org          BOOLEAN := FALSE;


  TYPE tcursor  IS REF CURSOR;
  l1_cursor tcursor;

BEGIN

-- 2684911
    IF (c_dim_lvl_sn%ISOPEN) THEN
      CLOSE c_dim_lvl_sn;
    END IF;

    OPEN c_dim_lvl_sn(cp_lvl_values_view => p_table_name ) ;
    FETCH c_dim_lvl_sn INTO l_short_name;
    CLOSE c_dim_lvl_sn;

    l_time_lvl_dep_on_org := BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => l_short_name) ;
    IF (l_short_name IS NOT NULL AND l_time_lvl_dep_on_org = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN
      l_is_dep_on_org := TRUE;
    END IF;

  if p_source = 'EDW' then

     l_selectStmt :=  ' SELECT ' || p_value_col_name  ||
                     ' FROM ' || p_table_name;

       if (p_flag = 'BOTH') then
          l_selectStmt := l_selectStmt || ' WHERE END_DATE >= :l_date ' ||
                     '   AND START_DATE <= :l_date ' ;
       elsif (p_flag = 'START') then
          l_selectStmt := l_selectStmt || ' WHERE START_DATE = :l_date ';
       elsif (p_flag = 'END') then
          l_selectStmt := l_selectStmt || ' WHERE END_DATE = :l_date ';
       else
          BIS_UTILITIES_PUB.put_line(p_text =>' Error Get_Time_Level_Value 0100: p_flag can be either START, END or BOTH, flag is ' || p_flag );
       end if;

       IF (l_is_dep_on_org) THEN --2684911
         l_selectStmt :=  l_selectStmt ||
                      '   AND  nvl(organization_id, :l_star1) = nvl(:p_Org_Level_ID, :l_star1) ' ||
                      '   AND  nvl(organization_type, :l_star) = nvl(:p_Org_Level_Short_name, :l_star) ';
       END IF;

       l_selectStmt :=  l_selectStmt ||
                  ' ORDER BY abs( nvl(trunc(end_date), trunc (sysdate)) - ' ||
                       '    nvl(trunc(start_date), trunc(sysdate))) ';

    BEGIN

        if (p_flag = 'BOTH') then
         IF (l_is_dep_on_org) THEN
            OPEN l1_cursor FOR l_selectStmt
             using p_date, p_date,l_star1,p_Org_Level_ID,l_star1,l_star,p_Org_Level_Short_name,l_star;
         ELSE
            OPEN l1_cursor FOR l_selectStmt
             using p_date, p_date;
         END IF;
        else
         IF (l_is_dep_on_org) THEN --2684911
            OPEN l1_cursor FOR l_selectStmt
             using p_date ,l_star1,p_Org_Level_ID,l_star1,l_star,p_Org_Level_Short_name,l_star;
         ELSE
            OPEN l1_cursor FOR l_selectStmt
             using p_date;
         END IF;
        end if;

         FETCH l1_cursor INTO v_value2;
         CLOSE l1_cursor;


        if v_value2 is null then
       BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_selectStmt );
       BIS_UTILITIES_PUB.put_line(p_text =>' Date is ' || p_date );
    end if;


    EXCEPTION

      WHEN OTHERS THEN
    if l1_cursor%isopen then
       close l1_cursor;
    end if;

        v_value2 := null;

    BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_selectStmt );
        BIS_UTILITIES_PUB.put_line(p_text =>'Exception executing sql in Get_Time_Level_Value 0200: '||sqlerrm);

    END;


  else   -- if source =  'OLTP'

    l_selectStmt :=  ' SELECT ' || p_value_col_name  ||
                     ' FROM ' || p_table_name;

       if (p_flag = 'BOTH') then
          l_selectStmt := l_selectStmt || ' WHERE END_DATE >= :l_date ' ||
                     '   AND START_DATE <= :l_date ' ;
       elsif (p_flag = 'START') then
          l_selectStmt := l_selectStmt || ' WHERE START_DATE = :l_date ';
       elsif (p_flag = 'END') then
          l_selectStmt := l_selectStmt || ' WHERE END_DATE = :l_date ';
       else
          BIS_UTILITIES_PUB.put_line(p_text =>' Error Get_Time_Level_Value: p_flag can be either START, END or BOTH, flag is ' || p_flag );
       end if;

       IF (l_is_dep_on_org) THEN --2684911
          l_selectStmt :=  l_selectStmt ||
                     '   AND  nvl(organization_id, :l_star) = nvl(:p_Org_Level_ID, :l_star) ' ||
                      '   AND  nvl(organization_type, :l_star) = nvl(:p_Org_Level_Short_name, :l_star) ';

       ELSE
          l_selectStmt :=  l_selectStmt || ' AND rownum < 2 '; -- take the first row
       END IF;

      Begin


            if (p_flag = 'BOTH') then
                  IF (l_is_dep_on_org) THEN --2684911
             EXECUTE IMMEDIATE  l_selectStmt INTO v_value2
                  USING p_date, p_date, l_star, p_Org_Level_ID, l_star, l_star, p_Org_Level_Short_name, l_star;
          ELSE
             EXECUTE IMMEDIATE  l_selectStmt INTO v_value2 USING p_date, p_date;
                  END IF;
            else
                  IF (l_is_dep_on_org) THEN --2684911
             EXECUTE IMMEDIATE  l_selectStmt INTO v_value2
                  USING p_date, l_star, p_Org_Level_ID, l_star, l_star, p_Org_Level_Short_name, l_star;
                  ELSE
             EXECUTE IMMEDIATE  l_selectStmt INTO v_value2 USING p_date;
                  END IF;
            end if;

      Exception
         when others then
           v_value2 := null;

           -- BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_selectStmt );
           -- BIS_UTILITIES_PUB.put_line(p_text => ' l_date = ' || p_date );
           -- BIS_UTILITIES_PUB.put_line(p_text => ' flag = ' || p_flag );
               -- BIS_UTILITIES_PUB.put_line(p_text =>'Exception executing sql in Get_Time_Level_Value 0300: '||sqlerrm);

      End;

  end if;

  x_time_value := v_value2;


Exception

  when others then
    BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_selectStmt );
        BIS_UTILITIES_PUB.put_line(p_text =>'Exception executing sql in Get_Time_Level_Value 0400: '||sqlerrm);
    IF (c_dim_lvl_sn%ISOPEN) THEN
      CLOSE c_dim_lvl_sn;
    END IF;

END Get_Time_Level_Value;



Procedure Get_Start_End_Dates   -- where level_value_id = p_id_value_name
( p_source      IN varchar2,    --   and level_value = p_time_value
  p_view_name       IN varchar2,    --   need to merge this and Get_Start_End_Dates2
  p_id_col_name         IN varchar2,
  p_id_value_name       IN varchar2,
  --  p_value_col_name      IN varchar2,
  --  p_time_value          IN varchar2,
  p_org_level_id    IN varchar2,
  p_org_level_short_name IN varchar2,
  x_start_date      OUT NOCOPY date,
  x_end_date        OUT NOCOPY date
)

IS

  l_start_date      date;
  l_end_date        date;

  l_sql     VARCHAR2(32000);
  l_star    VARCHAR2(2) := '*';

  l_star1   NUMBER :=  -9999;

--2684911
  CURSOR c_dim_lvl_sn( cp_lvl_values_view IN VARCHAR2) IS SELECT short_name FROM bis_levels WHERE
    level_values_view_name =  cp_lvl_values_view ;
  l_short_name   bis_levels.short_name%TYPE;
  l_time_lvl_dep_on_org    NUMBER(3);
  l_is_dep_on_org          BOOLEAN := FALSE;

  TYPE tcursor  IS REF CURSOR;
  l1_cursor tcursor;

BEGIN
-- 2684911
    IF (c_dim_lvl_sn%ISOPEN) THEN
      CLOSE c_dim_lvl_sn;
    END IF;

    OPEN c_dim_lvl_sn(cp_lvl_values_view => p_view_name ) ;
    FETCH c_dim_lvl_sn INTO l_short_name;
    CLOSE c_dim_lvl_sn;

    l_time_lvl_dep_on_org := BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => l_short_name) ;
    IF (l_short_name IS NOT NULL AND l_time_lvl_dep_on_org = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN
      l_is_dep_on_org := TRUE;
    END IF;

    if p_source = 'EDW' then
      IF (l_is_dep_on_org) THEN --2684911
       l_sql :=  ' SELECT START_DATE, END_DATE ' ||
                ' FROM ' || p_view_name  ||
                ' WHERE '|| p_id_col_name || ' = :p_id' ||
                ' and nvl(organization_id, :l_star1) = nvl(:p_Org_Level_ID, :l_star1) '||
                ' and nvl(organization_type, :l_star) = nvl(:p_Org_Level_Short_name, :l_star) '||
                -- ' AND ' || p_value_col_name || ' = :p_time_value ' ||
                ' ORDER BY abs( nvl(trunc(end_date), trunc (sysdate)) - ' ||
            '  nvl(trunc(start_date), trunc(sysdate))) ';
      ELSE
       l_sql :=  ' SELECT START_DATE, END_DATE ' ||
                ' FROM ' || p_view_name  ||
                ' WHERE '|| p_id_col_name || ' = :p_id' ||
                -- ' AND ' || p_value_col_name || ' = :p_time_value ' ||
                ' ORDER BY abs( nvl(trunc(end_date), trunc (sysdate)) - ' ||
            '  nvl(trunc(start_date), trunc(sysdate))) ';
      END IF;

      -- Query is supposed to return just one record. However we take the first one.
      BEGIN

       IF (l_is_dep_on_org) THEN --2684911
        OPEN l1_cursor FOR l_sql using p_id_value_name,l_star1 , p_Org_Level_ID,l_star1 ,l_star,p_Org_Level_Short_name,l_star  ;
       ELSE
        OPEN l1_cursor FOR l_sql using p_id_value_name;
       END IF;

        FETCH l1_cursor INTO l_start_date, l_end_date;
        CLOSE l1_cursor;

        if l_start_date is null then
       BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_sql );
       BIS_UTILITIES_PUB.put_line(p_text =>' Date is ' || p_id_value_name );
    end if;

      EXCEPTION

       WHEN OTHERS THEN
    if l1_cursor%isopen then
       close l1_cursor;
    end if;

    BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_sql );
        BIS_UTILITIES_PUB.put_line(p_text => ' ID is ' || p_id_value_name );
        BIS_UTILITIES_PUB.put_line(p_text =>'Exception executing sql in Get_Start_End_Dates 0100: '||sqlerrm);

      END;

    elsif p_source = 'OLTP' then -- and substr(l_short_name, 1, 2) <> 'HR' then

       IF (l_is_dep_on_org) THEN --2684911
          l_sql :=  ' SELECT DISTINCT START_DATE, END_DATE ' ||
                ' FROM ' || p_view_name  ||
                ' WHERE '|| p_id_col_name || ' = :p_id'
                     -- || ' and ' || p_value_col_name || ' = :p_time_value '
                         ||' and nvl(organization_id, :l_star) = nvl(:p_Org_Level_ID, :l_star) '
                 ||' and nvl(organization_type, :l_star) = nvl(:p_Org_Level_Short_name, :l_star) ';
       ELSE
         l_sql :=  ' SELECT DISTINCT START_DATE, END_DATE ' ||
                ' FROM ' || p_view_name  ||
                ' WHERE '|| p_id_col_name || ' = :p_id' ;
       END IF;

        begin

          IF (l_is_dep_on_org) THEN --2684911
            EXECUTE IMMEDIATE  l_sql INTO l_start_date, l_end_date
              USING p_id_value_name, l_star, p_Org_Level_ID, l_star, l_star, p_Org_Level_Short_name, l_star;
          ELSE
            EXECUTE IMMEDIATE  l_sql INTO l_start_date, l_end_date USING p_id_value_name;
          END IF;

        Exception
           when others then
          BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_sql );
          BIS_UTILITIES_PUB.put_line(p_text => ' ID is ' || p_id_value_name );
              BIS_UTILITIES_PUB.put_line(p_text =>' Get_Start_End_Dates 0200: Error finding Start date, End date '||sqlerrm);

        end;

    end if;

    x_start_date := l_start_date;
    x_end_date   := l_end_date;

Exception

  when others then
    BIS_UTILITIES_PUB.put_line(p_text => ' SQL is ' || l_sql );
    -- BIS_UTILITIES_PUB.put_line(p_text => ' l_date = ' || p_date );
        BIS_UTILITIES_PUB.put_line(p_text => ' Exception executing sql in Get_Start_End_Dates 0300: '||sqlerrm);
    IF (c_dim_lvl_sn%ISOPEN) THEN
      CLOSE c_dim_lvl_sn;
    END IF;

END Get_Start_End_Dates;



Procedure Get_Min_Max_Start_End_Dates   -- get min start and max end date for a given
( p_source      IN varchar2,    --  time level value.
  p_view_name       IN varchar2,
  p_org_level_id    IN varchar2,
  p_org_level_short_name IN varchar2,
  x_min_start_date  OUT NOCOPY date,
  x_max_end_date    OUT NOCOPY date
)
IS

  l_min_start_date  date;
  l_max_end_date    date;

  l_selectStmt  VARCHAR2(32000);
  l_star    VARCHAR2(2) := '*';

  TYPE tcursor  IS REF CURSOR;
  l_cursor  tcursor;

--2684911
  CURSOR c_dim_lvl_sn( cp_lvl_values_view IN VARCHAR2) IS SELECT short_name FROM bis_levels WHERE
    level_values_view_name =  cp_lvl_values_view ;
  l_short_name   bis_levels.short_name%TYPE;
  l_time_lvl_dep_on_org    NUMBER(3);
  l_is_dep_on_org          BOOLEAN := FALSE;

  l_dim_lvl_view_name VARCHAR2(32000) := NULL;
BEGIN
-- 2684911
    IF (c_dim_lvl_sn%ISOPEN) THEN
      CLOSE c_dim_lvl_sn;
    END IF;

    OPEN c_dim_lvl_sn(cp_lvl_values_view => p_view_name ) ;
    FETCH c_dim_lvl_sn INTO l_short_name;
    CLOSE c_dim_lvl_sn;

    l_time_lvl_dep_on_org := BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => l_short_name) ;
    IF (l_short_name IS NOT NULL AND l_time_lvl_dep_on_org = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN
      l_is_dep_on_org := TRUE;
    END IF;

    if p_source = 'EDW' then
       IF (l_is_dep_on_org) THEN --2684911
            l_selectStmt := ' SELECT MIN(START_DATE), MAX(END_DATE)  ' ||
                            ' FROM  ' || p_view_name ||
                            ' WHERE  nvl(organization_id, :l_star)  = nvl(:p_Org_Level_ID, :l_star) ' ||
                            '   AND  nvl(organization_type, :l_star) = nvl(:p_Org_Level_Short_name, :l_star) ';
       ELSE
            l_selectStmt := ' SELECT MIN(START_DATE), MAX(END_DATE)  ' ||
                            ' FROM  ' || p_view_name ;
       END IF;
        begin

       IF (l_is_dep_on_org) THEN --2684911
            OPEN l_cursor FOR l_selectStmt USING l_star ,p_Org_Level_ID, l_star , l_star ,p_Org_Level_Short_name,l_star  ;
       ELSE
            OPEN l_cursor FOR l_selectStmt ;
       END IF;
            FETCH l_cursor INTO l_min_start_date, l_max_end_date;
            CLOSE l_cursor;

            if l_min_start_date is null then
           BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_selectStmt );
           BIS_UTILITIES_PUB.put_line(p_text =>' min start date is ' || l_min_start_date );
        end if;

        exception
          when others then

        if l_cursor%isopen then
            close l_cursor;
        end if;

            BIS_UTILITIES_PUB.put_line(p_text => ' l_selectStmt is : ' || l_selectStmt);
            BIS_UTILITIES_PUB.put_line(p_text => ' Error Get_Min_Max_Start_End_Dates 100 : ' || sqlerrm );
        end;

    elsif p_source = 'OLTP' then

      IF (l_is_dep_on_org) THEN --2684911
              l_selectStmt := ' SELECT MIN(START_DATE), MAX(END_DATE)  ' ||
                             ' FROM  ' || p_view_name ||
                             ' WHERE  nvl(organization_id, :l_star)  = nvl(:p_Org_Level_ID, :l_star) ' ||
                             '   AND  nvl(organization_type, :l_star) = nvl(:p_Org_Level_Short_name, :l_star) ' ||
                             '   AND  start_date < end_date ';
      ELSE
              l_selectStmt := ' SELECT MIN(START_DATE), MAX(END_DATE)  ' ||
                             ' FROM  ' || p_view_name ||
                             '   WHERE  start_date < end_date ';
      END IF;

          begin
      IF (l_is_dep_on_org) THEN --2684911
            EXECUTE IMMEDIATE  l_selectStmt INTO l_min_start_date, l_max_end_date
        USING l_star, p_Org_Level_ID, l_star, l_star, p_Org_Level_Short_name, l_star;
      ELSE
            EXECUTE IMMEDIATE  l_selectStmt INTO l_min_start_date, l_max_end_date;
      END IF;
        -- BIS_UTILITIES_PUB.put_line(p_text => ' V end date ' || v_end_date ) ;

          exception
            when others then
              BIS_UTILITIES_PUB.put_line(p_text => ' l_selectStmt is : ' || l_selectStmt);
              BIS_UTILITIES_PUB.put_line(p_text =>'Error in Get_Min_Max_Start_End_Dates 200 '||sqlerrm);
          end;

    end if;

    x_min_start_date := l_min_start_date;
    x_max_end_date   := l_max_end_date;


Exception

  when others then
    BIS_UTILITIES_PUB.put_line(p_text =>' SQL is ' || l_selectStmt );
        BIS_UTILITIES_PUB.put_line(p_text =>' Exception executing sql in Get_Min_Max_Start_End_Dates 0300: '||sqlerrm);
    IF (c_dim_lvl_sn%ISOPEN) THEN
      CLOSE c_dim_lvl_sn;
    END IF;
END Get_Min_Max_Start_End_Dates;



--***************************************************************************************
--***************************************************************************************


function target_level_where_clause
(p_user_id                    IN NUMBER
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
)
return varchar2 is

 l_target_level_Tbl         target_level_Tbl_Type;
 l_where_clause             VARCHAR2(32000) := 'target_level_id in (';
 l_return_status            VARCHAR2(200);
 x_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
 l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
begin

    FND_MSG_PUB.initialize;

  Retrieve_User_target_level
     ( p_user_id                  => p_user_id
     , x_Target_Level_Tbl         => l_Target_Level_Tbl
     , x_return_status            => l_return_status);

  if l_Target_Level_Tbl.COUNT <> 0 then
    --
    for i in l_Target_Level_Tbl.first .. l_Target_Level_Tbl.last
    loop
      --
      if i <> 1 then
        --
        l_where_clause := l_where_clause || ',';
        --
      end if;
      --
      l_where_clause := l_where_clause ||
                to_char(l_Target_Level_Tbl(i).Target_level_id);
      --
    end loop;
    --
    l_where_clause := l_where_clause || ')';
    --
  else
    l_where_clause := '';
  end if;
  --
  x_return_status := l_return_status;

  return (l_where_clause);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
end Target_Level_where_clause;
--

--
function Perf_measure_where_clause
(p_user_id                    IN NUMBER
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
)
 return varchar2 is

 l_Perf_measure_Tbl  Perf_Measure_Tbl_Type;
 l_where_clause             VARCHAR2(32000) := 'measure_id in (';
 l_return_status            VARCHAR2(200);
 x_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
 l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

begin

    FND_MSG_PUB.initialize;

  Retrieve_User_perf_measure
     ( p_user_id           => p_user_id
     , x_Perf_measure_Tbl  => l_Perf_measure_Tbl
     , x_return_status     => l_return_status);

  if l_Perf_measure_Tbl.COUNT <> 0 then
    --
    for i in l_Perf_measure_Tbl.first .. l_Perf_measure_Tbl.last
    loop
      --
      if i <> 1 then
        --
        l_where_clause := l_where_clause || ',';
        --
      end if;
      --
      l_where_clause := l_where_clause ||
                to_char(l_perf_measure_Tbl(i).measure_id);
      --
    end loop;
    --
    l_where_clause := l_where_clause || ')';
  else
    l_where_clause := '';
  end if;
  --
  x_return_status := l_return_status;

  return (l_where_clause);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
end perf_measure_where_clause;

FUNCTION Is_Rolling_Period_Level
( p_level_short_name    IN VARCHAR2
)
RETURN NUMBER IS
l_level_id  NUMBER;
BEGIN

  SELECT level_id
  INTO   l_level_id
  FROM   bis_levels
  WHERE       short_name = p_level_short_name
         AND  source = 'OLTP'
         AND  level_values_view_name IS NULL;

  RETURN 1;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END;


--

FUNCTION get_Roll_Period_Start_Date
( p_level_short_name    IN VARCHAR2
, p_end_date        IN DATE
) RETURN DATE IS

  l_temp_level           bis_levels.short_name%TYPE; -- VARCHAR2(15);
  l_start_date           DATE;
  l_dynamic_sql_str      VARCHAR2(4000);

BEGIN

  l_temp_level := substr ( p_level_short_name , 13 );

  IF ( l_temp_level = 'WEEK' ) THEN
    l_dynamic_sql_str := 'BEGIN :1 := FII_TIME_API.rwk_start(:2); END;';
    -- RETURN FII_TIME_API.rwk_start ( p_end_date ) ;
  ELSIF ( l_temp_level = 'MONTH' ) THEN
    l_dynamic_sql_str := 'BEGIN :1 := FII_TIME_API.rmth_start(:2); END;';
    -- RETURN FII_TIME_API.rmth_start ( p_end_date ) ;
  ELSIF ( l_temp_level = 'QTR' ) THEN
    l_dynamic_sql_str := 'BEGIN :1 := FII_TIME_API.rqtr_start(:2); END;';
    -- RETURN FII_TIME_API.rqtr_start ( p_end_date ) ;
  ELSIF ( l_temp_level = 'YEAR' ) THEN
    l_dynamic_sql_str := 'BEGIN :1 := FII_TIME_API.ryr_start(:2); END;';
    -- RETURN FII_TIME_API.ryr_start ( p_end_date ) ;
  ELSE
    RETURN NULL;
  END IF;


  EXECUTE IMMEDIATE l_dynamic_sql_str using OUT l_start_date, IN p_end_date;

  RETURN l_start_date;

EXCEPTION
  WHEN OTHERS THEN
    -- BIS_UTILITIES_PUB.put_line(p_text => ' Error in get_Roll_Period_Start_Date. ' ) ;
    RETURN NULL;

END get_Roll_Period_Start_Date;


FUNCTION Get_FND_Lookup
( p_lookup_type   IN VARCHAR2
, p_lookup_code   IN VARCHAR2
)
RETURN VARCHAR2
IS
l_meaning   VARCHAR2(80);

BEGIN
  SELECT MEANING
  INTO l_meaning
  FROM FND_LOOKUP_VALUES_VL
  WHERE LOOKUP_TYPE = p_lookup_type
  AND   LOOKUP_CODE = p_lookup_code;

  RETURN l_meaning;

END Get_FND_Lookup;
--



FUNCTION get_bis_jsp_path RETURN VARCHAR2 IS

    l_servlet_agent varchar2(500)     :=NULL;
    l_jsp_path  VARCHAR2(500)   := NULL;
    l_url VARCHAR2(500):=NULL;

BEGIN

    l_servlet_agent := FND_WEB_CONFIG.JSP_AGENT;
    l_jsp_path := '';

    if ( l_servlet_agent is null ) then   -- 'APPS_SERVLET_AGENT' is null
    l_servlet_agent := FND_WEB_CONFIG.WEB_SERVER;
        l_jsp_path := 'OA_HTML/';
    end if;

    l_url := l_servlet_agent || l_jsp_path;

    RETURN l_url;

EXCEPTION

   WHEN OTHERS THEN
       RETURN l_jsp_path;

END get_bis_jsp_path;

FUNCTION get_webdb_host RETURN VARCHAR2  -- 1898436
IS
    ws_url VARCHAR2(2000);
    hostname VARCHAR2(2000);
    index1 NUMBER;
    index2 NUMBER;

BEGIN

    ws_url := FND_WEB_CONFIG.WEB_SERVER;  -- ex : 'http://ap100jvm.us.oracle.com:8724/';


    index1 := INSTRB(ws_url, '//', 1) + 2; -- skip 'http://'
    index2 := INSTRB(ws_url, ':', index1);


    IF index2 = 0 THEN     -- ex : 'http://ap100jvm.us.oracle.com/';
      hostname := SUBSTRB(ws_url, index1, length(ws_url)-index1);
    ELSE
      hostname := SUBSTRB(ws_url, index1, index2-index1);
    END IF;


    RETURN hostname;

END get_webdb_host;


FUNCTION get_webdb_port RETURN VARCHAR2
IS
    ws_url VARCHAR2(2000);
    portno VARCHAR2(500);
    index1 NUMBER;
    index2 NUMBER;

BEGIN

    ws_url := FND_WEB_CONFIG.WEB_SERVER;  -- ex :'http://ap100jvm.us.oracle.com:8724/';


    index1 := INSTRB(ws_url, '//', 1) + 2; -- skip 'http://'
    index2 := INSTRB(ws_url, ':', index1);


    IF index2 = 0 THEN     -- ex : 'http://ap100jvm.us.oracle.com/';
      portno := '80';
    ELSE
      portno := SUBSTRB(ws_url, index2+1, length(ws_url)-index2-1);
    END IF;

    RETURN portno;

END get_webdb_port;



--
-- Init debug log file calls get_debug_mode_profile, sets the value
-- of debug flag (BIS_UTILITIES_PUB.G_IS_DEBUG) using set_debug_log_flag
-- and then opens the log file using open_debug_log.
--
PROCEDURE init_debug_log -- 2694978
( p_file_name       IN  VARCHAR2
, p_dir_name        IN  VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_return_status  VARCHAR2(1000) := FND_API.G_RET_STS_SUCCESS;
  l_return_msg     VARCHAR2(10000) := NULL;
  l_is_debug_mode  BOOLEAN := FALSE;

BEGIN

  get_debug_mode_profile
  ( x_is_debug_mode   => l_is_debug_mode
  , x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  );


  -- l_is_debug_mode := TRUE; -- Test onnly, to be removed.

  IF (l_is_debug_mode) THEN
    open_debug_log (
      p_file_name     => p_file_name,
      p_dir_name      => p_dir_name,
      x_return_status => l_return_status,
          x_return_msg    => x_return_msg );
  END IF;

  set_debug_log_flag
  ( p_is_true         => l_is_debug_mode
  , x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  );

  x_return_status := l_return_status;
  x_return_msg    := l_return_msg;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_return_msg    := 'Error in BIS_UTILITIES_PUB.init_debug_log : '|| SQLERRM;

END init_debug_log;


PROCEDURE init_debug_flag -- 2694978
( x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_return_status  VARCHAR2(1000) := FND_API.G_RET_STS_SUCCESS;
  l_return_msg     VARCHAR2(10000) := NULL;
  l_is_debug_mode  BOOLEAN := FALSE;

BEGIN

  get_debug_mode_profile
  ( x_is_debug_mode   => l_is_debug_mode
  , x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  );

  -- l_is_debug_mode := TRUE; -- Test onnly, to be removed.

  set_debug_log_flag
  ( p_is_true         => l_is_debug_mode
  , x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  );

  x_return_status := l_return_status;
  x_return_msg    := l_return_msg;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_return_msg    := 'Error in BIS_UTILITIES_PUB.init_debug_log : '|| SQLERRM;

END init_debug_flag;



PROCEDURE get_debug_mode_profile -- 2694978
( x_is_debug_mode   OUT NOCOPY BOOLEAN
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
) IS
  l_debug_mode  VARCHAR2(10) := 'N';
BEGIN

  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_return_msg      := NULL;
  x_is_debug_mode   := FALSE;

  l_debug_mode := NVL ( FND_PROFILE.value(BIS_UTILITIES_PUB.G_DEBUG_LOG_PROFILE) , 'N' ) ;

  IF ( l_debug_mode = 'Y') THEN
    x_is_debug_mode := TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_return_msg     := 'Error in setting debug log flag in BIS_UTILITIES_PVT.get_debug_mode_profile: '|| SQLERRM;
    x_is_debug_mode  := FALSE;
END get_debug_mode_profile;


--
-- The following api is called (once per program) to set the value of
-- debug flag value.
--
PROCEDURE set_debug_log_flag (  -- 2694978
  p_is_true         IN  BOOLEAN
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_return_status  VARCHAR2(1000)  := FND_API.G_RET_STS_SUCCESS;
  l_return_msg     VARCHAR2(10000) := NULL;
BEGIN

  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_return_msg      := NULL;

  BIS_UTILITIES_PUB.G_IS_DEBUG_ON := NVL(p_is_true, FALSE);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status   := FND_API.G_RET_STS_ERROR;
    x_return_msg      := 'Error in setting debug log flag in BIS_UTILITIES_PVT.set_debug_log_flag: '|| SQLERRM;
END set_debug_log_flag;



FUNCTION is_debug_on -- 2694978
RETURN BOOLEAN
IS
BEGIN

  RETURN BIS_UTILITIES_PUB.G_IS_DEBUG_ON;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END is_debug_on;


FUNCTION get_default_dir_name  -- 2694978
RETURN VARCHAR2
IS
  l_default_dir_name  VARCHAR2(512); -- v$parameter%VALUE; --
BEGIN

  SELECT vp.value
  INTO l_default_dir_name
  FROM v$parameter vp
  WHERE vp.name = BIS_UTILITIES_PUB.G_UTL_FILE_DIR; -- 'utl_file_dir';

  IF (LENGTH(l_default_dir_name) > 0) THEN
    IF (INSTR(l_default_dir_name,',', 1, 1) > 0) THEN

      l_default_dir_name := SUBSTR( l_default_dir_name,
                                    1,
                                    INSTR(l_default_dir_name,',', 1, 1) - 1
                                  );

      RETURN l_default_dir_name;

    ELSE
    RETURN l_default_dir_name;
    END IF;
  ELSE
    RETURN NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_default_dir_name;


FUNCTION get_default_log_name  -- 2694978
RETURN VARCHAR2
IS
  l_default_log_name  VARCHAR2(300) := 'Test';
  l_temp_num          NUMBER := 0;
BEGIN

  /*
  SELECT bis_debug_log_s.nextval
  INTO l_temp_num
  FROM dual;
  */

  l_default_log_name := 'Test' || l_temp_num || '.log';

  RETURN l_default_log_name;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_default_log_name;



PROCEDURE open_debug_log ( -- 2694978
  p_file_name      IN  VARCHAR2,
  p_dir_name       IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_return_msg     OUT NOCOPY VARCHAR2)
IS
  l_default_dir_name  VARCHAR2(512); -- v$parameter%VALUE;
  l_default_log_name  VARCHAR2(512); -- v$parameter%VALUE;

BEGIN
  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_return_msg      := NULL;

  l_default_dir_name := get_default_dir_name; -- ();
  l_default_log_name := get_default_log_name; -- () || '.log';

  IF ( (l_default_dir_name IS NULL ) AND (p_dir_name IS NULL)) THEN
    x_return_status   := FND_API.G_RET_STS_ERROR;
    x_return_msg      := 'Error in opening debug log in BIS_UTILITIES_PVT.open_debug_log: Directory for log file is null';
    RETURN;
  END IF;

  IF ( (l_default_log_name IS NULL ) AND (p_file_name IS NULL)) THEN
    x_return_status   := FND_API.G_RET_STS_ERROR;
    x_return_msg      := 'Error in opening debug log in BIS_UTILITIES_PVT.open_debug_log: Log file name is null';
    RETURN;
  END IF;

  l_default_dir_name := NVL(p_dir_name, l_default_dir_name) ;
  l_default_log_name := NVL(p_file_name, l_default_log_name) ;

  BIS_DEBUG_LOG.setup_file(
    p_log_file  => l_default_log_name
  , p_out_file  => NULL -- We don't want to create an out file.
  , p_directory => l_default_dir_name
  );

EXCEPTION
  WHEN OTHERS THEN
    x_return_status   := FND_API.G_RET_STS_ERROR;
    x_return_msg      := 'Error in setting debug log flag in BIS_UTILITIES_PVT.open_debug_log: '|| SQLERRM;

END open_debug_log;


PROCEDURE close_debug_log ( -- 2694978
  p_file_name      IN  VARCHAR2,
  p_dir_name       IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_return_msg     OUT NOCOPY VARCHAR2)
IS
BEGIN

  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_return_msg      := NULL;

  BIS_DEBUG_LOG.close;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status   := FND_API.G_RET_STS_ERROR;
    x_return_msg      := 'Error in setting debug log flag in BIS_UTILITIES_PVT.close_debug_log: '|| SQLERRM;
END close_debug_log;



PROCEDURE put(p_text IN VARCHAR2) -- 2694978
IS
  l_is_debug_on BOOLEAN := FALSE;
BEGIN

  l_is_debug_on := BIS_UTILITIES_PVT.is_debug_on;

  IF (l_is_debug_on) THEN
    IF (
          ( BIS_UTILITIES_PUB.Value_Not_Missing(p_text) = FND_API.G_TRUE )
      AND ( BIS_UTILITIES_PUB.Value_Not_Null(p_text) = FND_API.G_TRUE)
       ) THEN
      BIS_DEBUG_LOG.put(p_text => p_text);
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END put;


PROCEDURE put_line(p_text IN VARCHAR2) -- 2694978
IS
  l_is_debug_on BOOLEAN := FALSE;
BEGIN

  l_is_debug_on := BIS_UTILITIES_PVT.is_debug_on;

  IF (l_is_debug_on) THEN
    IF (
          ( BIS_UTILITIES_PUB.Value_Not_Missing(p_text) = FND_API.G_TRUE )
      AND ( BIS_UTILITIES_PUB.Value_Not_Null(p_text) = FND_API.G_TRUE)
       ) THEN
      BIS_DEBUG_LOG.put_line(p_text => p_text);
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END put_line;

--------------------------------------------------------------------------

FUNCTION escape_html(
  p_input IN VARCHAR2
)
RETURN VARCHAR2
IS
  l_amp     VARCHAR2(1) := '&';
BEGIN
  --RETURN escape_html(p_input, '<BR>');

  --Bug#3944741: As FND_CSS_PKG.Encode() converts single quote into &#39;
  --this creates problem in escaping the single quote in
  --ICXUtils.replace_onMouseOver_quotes(), hence reverting this conversion
  RETURN (REPLACE(FND_CSS_PKG.Encode(p_input), l_amp||'#39;', ''''));
END escape_html;

--------------------------------------------------------------------------
FUNCTION escape_html_input(
  p_input IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  RETURN escape_html(p_input, '');
END escape_html_input;

--------------------------------------------------------------------------
FUNCTION escape_html(
  p_input IN VARCHAR2
 ,p_cr IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(p_input, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'), '"', '&quot;'), '\n', p_cr);
END escape_html;

--------------------------------------------------------------------------


FUNCTION is_valid_time_dimension_level (
  p_bis_dimlevel_id        IN NUMBER  := NULL
, x_return_status     OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN
IS
  CURSOR c_dims IS
    SELECT  source ,dimension_short_name, dimension_level_short_name
    FROM bisfv_dimension_levels
    WHERE dimension_level_id = p_bis_dimlevel_id;
  l_source      bisfv_dimension_levels.SOURCE%TYPE;
  l_dimshort_name  bisfv_dimension_levels.DIMENSION_SHORT_NAME%TYPE;
  l_dimlevel_name  bisfv_dimension_levels.DIMENSION_LEVEL_SHORT_NAME%TYPE;
  l_dimshortname_time  VARCHAR2(32000);
  l_lvlshortname_total VARCHAR2(32000);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF(c_dims%ISOPEN) THEN
    CLOSE c_dims;
  END IF;
  OPEN c_dims;
  FETCH c_dims INTO l_source,l_dimshort_name,l_dimlevel_name;
  IF (c_dims%NOTFOUND) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_dims;
  IF (l_source = 'EDW') THEN
     l_dimshortname_time  := BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_SRC(p_source => l_source);
     l_lvlshortname_total := BIS_UTILITIES_PVT.GET_TOTAL_DIMLEVEL_NAME_SRC(p_dim_short_name=>l_dimshort_name
                                                                          ,p_source => l_source);
     IF ((l_dimshort_name = l_dimshortname_time) AND
            (l_dimlevel_name <> l_lvlshortname_total)) THEN
           RETURN TRUE;
     ELSE
           RETURN FALSE;
     END IF;
  ELSE
     l_dimshortname_time := BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_SRC(p_Source => l_source);
     IF (l_dimshort_name = l_dimshortname_time) THEN
         RETURN TRUE;
     ELSE
           RETURN FALSE;
     END IF;
  END IF;
  RETURN FALSE;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF(c_dims%ISOPEN) THEN
      CLOSE c_dims;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN FALSE;
  WHEN OTHERS THEN
    IF(c_dims%ISOPEN) THEN
      CLOSE c_dims;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN FALSE;
END is_valid_time_dimension_level;
--

FUNCTION filter_quotes (
  p_filter_string    IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
  RETURN REPLACE(p_filter_string, '''', '''''');
END filter_quotes;
--

FUNCTION get_role_id (
  p_role_name    IN VARCHAR2
)
RETURN NUMBER
IS
  CURSOR c_role_id IS
    SELECT orig_system_id FROM wf_local_roles
    WHERE name = p_role_name
    AND ( orig_system LIKE 'FND_RESP%'
      OR orig_system = 'FND_USR' )
    AND rownum < 2;
  l_role_id  NUMBER;
BEGIN
  IF(c_role_id%ISOPEN) THEN
    CLOSE c_role_id;
  END IF;
  OPEN c_role_id;
  FETCH c_role_id INTO l_role_id;
  CLOSE c_role_id;

  RETURN l_role_id;
EXCEPTION
  WHEN OTHERS THEN
    IF(c_role_id%ISOPEN) THEN
      CLOSE c_role_id;
    END IF;
  RETURN l_role_id;
END get_role_id;

FUNCTION getPMVReport (
  p_report_url  IN VARCHAR2
)
RETURN CLOB
IS
vHTMLPieces     utl_http.html_pieces;
l_html_pieces   VARCHAR2(32000);
report_html     CLOB;
BEGIN

  vHTMLPieces := utl_http.request_pieces(url        => p_report_url,
                                         max_pieces => 32000);

  FOR i IN 1 .. vHTMLPieces.count loop
    l_html_pieces := vHTMLpieces(i);
    IF(report_html IS NULL) THEN
      WF_NOTIFICATION.NewClob(report_html, l_html_pieces);
    ELSE
      WF_NOTIFICATION.WriteToClob(report_html,l_html_pieces);
    END IF;
  END LOOP;

  RETURN report_html;
END getPMVReport;

/******************************************
 NAME   : checkSWANEnabled
 Decsription : This fucntion checks if SWAN is enabled or not.
 created by  : ashankar 21-Dec-05
/******************************************/

FUNCTION checkSWANEnabled
RETURN BOOLEAN IS
 l_swan_enabled   BOOLEAN;
BEGIN

  IF(BIS_PORTLET_CUSTOM_PUB.c_SWAN_ENABLED=FND_API.G_TRUE)THEN
    l_swan_enabled := TRUE;
  ELSE
    l_swan_enabled := FALSE;
  END IF;

RETURN l_swan_enabled;

END checkSWANEnabled;

END BIS_UTILITIES_PVT;

/
