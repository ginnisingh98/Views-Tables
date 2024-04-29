--------------------------------------------------------
--  DDL for Package OE_VERSION_HISTORY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VERSION_HISTORY_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXHVERS.pls 120.1.12010000.2 2010/04/12 10:01:40 msundara ship $ */

G_PKG_NAME       	CONSTANT VARCHAR2(30) := 'OE_VERSION_HISTORY_UTIL';

--This boolean is used to prevent multiple calls to the database to
--determine the current version
G_INTERNAL_QUERY BOOLEAN := FALSE;

--bug 9503990
FUNCTION get_status (p_line_id  IN NUMBER, p_flow_status_code IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE Create_Version_History
 (p_header_id          IN  NUMBER
  ,p_version_number    IN  NUMBER
  ,p_phase_change_flag IN  VARCHAR2
  ,p_changed_attribute IN  VARCHAR2 := NULL
  ,x_return_status     IN OUT NOCOPY VARCHAR2);


Procedure Get_Transaction_Version(
p_header_id              IN NUMBER,
p_version_number         IN NUMBER := NULL,
p_phase_change_flag      IN VARCHAR2 := NULL,
x_header_rec             OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type,
x_header_adj_tbl         OUT NOCOPY OE_ORDER_PUB.Header_Adj_Tbl_Type,
x_header_scredit_tbl     OUT NOCOPY OE_ORDER_PUB.Header_Scredit_Tbl_Type,
x_line_tbl               OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
x_line_adj_tbl           OUT NOCOPY OE_ORDER_PUB.Line_Adj_Tbl_Type,
x_line_scredit_tbl       OUT NOCOPY OE_ORDER_PUB.Line_Scredit_Tbl_Type,
x_return_status          OUT NOCOPY VARCHAR2);


--  Query_Rows with version_number to query from history tables

-- Header Query_Row
PROCEDURE Query_Row
(   p_header_id                     IN  NUMBER,
    p_version_number                IN  NUMBER := NULL,
    p_phase_change_flag      IN VARCHAR2 := NULL,
    x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
) ;

-- Header Adj Query_Row
PROCEDURE Query_Row
(   p_price_adjustment_id           IN  NUMBER
,   p_version_number                IN  NUMBER := NULL
,   p_phase_change_flag             IN VARCHAR2 := NULL
,   x_Header_Adj_Rec			 IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
);

-- Header Adj Query_Rows
PROCEDURE Query_Rows
(   p_price_adjustment_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_version_number                IN  NUMBER := NULL
,   p_phase_change_flag             IN VARCHAR2 := NULL
,   x_Header_Adj_Tbl			 IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
);

-- Header SCredit Query_Row
PROCEDURE Query_Row
(   p_sales_credit_id               IN  NUMBER,
    p_version_number                IN  NUMBER := NULL,
    p_phase_change_flag             IN VARCHAR2 := NULL,
    x_Header_Scredit_Rec      IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type
) ;

-- Header SCredit Query_Rows
PROCEDURE Query_Rows
(   p_sales_credit_id               IN  NUMBER :=
                                    FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                    FND_API.G_MISS_NUM
,   p_version_number                IN  NUMBER := NULL
,   p_phase_change_flag             IN VARCHAR2 := NULL
,   x_Header_Scredit_tbl   IN OUT NOCOPY OE_Order_PUB.Header_Scredit_tbl_Type

);

-- Line Query_Row
PROCEDURE Query_Row
(   p_line_id                       IN  NUMBER
,   p_version_number                IN  NUMBER := NULL
,   p_phase_change_flag             IN VARCHAR2 := NULL
,   x_line_rec                      IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
);

-- Line Query_Rows
PROCEDURE Query_Rows
(   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_set_id                   IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_version_number                IN  NUMBER := NULL
,   p_phase_change_flag             IN VARCHAR2 := NULL
,   x_line_tbl                      IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
);

-- Line Adj Query_Row
PROCEDURE Query_Row
(   p_price_adjustment_id           IN  NUMBER
,   p_version_number                IN  NUMBER := NULL
,   p_phase_change_flag             IN VARCHAR2 := NULL
,   x_Line_Adj_Rec				 IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Rec_Type
);

-- Line Adj Query_Rows
PROCEDURE Query_Rows
(   p_price_adjustment_id          IN  NUMBER :=
                                       FND_API.G_MISS_NUM
,   p_line_id                      IN  NUMBER :=
                                       FND_API.G_MISS_NUM
,   p_Header_id                    IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_version_number                IN  NUMBER := NULL
,   p_phase_change_flag             IN VARCHAR2 := NULL
,   x_Line_Adj_Tbl				IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
);

-- Line Scredit Query_Row
PROCEDURE Query_Row
(   p_sales_credit_id               IN  NUMBER
,   p_version_number                IN  NUMBER := NULL
,   p_phase_change_flag             IN VARCHAR2 := NULL
,   x_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
);

-- Line Scredit Query_Rows
PROCEDURE Query_Rows
(   p_sales_credit_id               IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Header_id                    IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_version_number                IN  NUMBER := NULL
,   p_phase_change_flag             IN VARCHAR2 := NULL
,   x_Line_Scredit_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
);


END OE_VERSION_HISTORY_UTIL;

/
