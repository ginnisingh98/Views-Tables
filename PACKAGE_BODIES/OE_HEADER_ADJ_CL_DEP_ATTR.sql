--------------------------------------------------------
--  DDL for Package Body OE_HEADER_ADJ_CL_DEP_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_ADJ_CL_DEP_ATTR" AS
/* $Header: OEXNHADB.pls 120.0 2005/05/31 23:46:21 appldev noship $ */


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Header_Adj_Cl_Dep_Attr';

PROCEDURE AUTOMATIC
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_AUTOMATIC
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END AUTOMATIC;

PROCEDURE CREATED_BY
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_CREATED_BY
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END CREATED_BY;

PROCEDURE CREATION_DATE
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_CREATION_DATE
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END CREATION_DATE;

PROCEDURE DISCOUNT
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_DISCOUNT
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END DISCOUNT;

PROCEDURE DISCOUNT_LINE
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_DISCOUNT_LINE
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END DISCOUNT_LINE;

PROCEDURE HEADER
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_HEADER
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END HEADER;

PROCEDURE LAST_UPDATED_BY
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_LAST_UPDATED_BY
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END LAST_UPDATED_BY;

PROCEDURE LAST_UPDATE_DATE
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_LAST_UPDATE_DATE
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END LAST_UPDATE_DATE;

PROCEDURE LAST_UPDATE_LOGIN
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_LAST_UPDATE_LOGIN
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );

END LAST_UPDATE_LOGIN;

PROCEDURE LINE
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_LINE
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END LINE;

PROCEDURE PERCENT
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_PERCENT
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END PERCENT;

PROCEDURE PRICE_ADJUSTMENT
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_PRICE_ADJUSTMENT
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END PRICE_ADJUSTMENT;

PROCEDURE PROGRAM_APPLICATION
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_PROGRAM_APPLICATION
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END PROGRAM_APPLICATION;

PROCEDURE PROGRAM
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN

OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_PROGRAM
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END PROGRAM;

PROCEDURE PROGRAM_UPDATE_DATE
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_PROGRAM_UPDATE_DATE
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END PROGRAM_UPDATE_DATE;

PROCEDURE REQUEST
( p_x_header_adj_rec	IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
BEGIN


OE_Header_Adj_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Adj_Util.G_REQUEST
    , p_x_header_adj_rec  => p_x_header_adj_rec
    );


END REQUEST;


END OE_Header_Adj_Cl_Dep_Attr;

/
