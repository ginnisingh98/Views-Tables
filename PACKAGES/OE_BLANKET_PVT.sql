--------------------------------------------------------
--  DDL for Package OE_BLANKET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BLANKET_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVBSOS.pls 120.0.12010000.2 2008/11/18 01:52:53 smusanna ship $ */

G_BATCH_MODE BOOLEAN := FALSE;

PROCEDURE Header
(   p_control_rec                   IN  OE_BLANKET_PUB.Control_Rec_Type
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_x_header_rec         IN OUT NOCOPY OE_Blanket_PUB.header_Rec_Type
,   p_x_old_header_rec     IN OUT NOCOPY OE_Blanket_PUB.header_Rec_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
);


PROCEDURE Lines
(   p_control_rec                   IN  oe_blanket_pub.Control_Rec_Type
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_x_line_tbl   IN OUT NOCOPY  OE_Blanket_PUB.line_tbl_Type
,   p_x_old_line_tbl IN OUT NOCOPY OE_Blanket_PUB.line_tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
);


--  API name    Process_Blanket
--  Type        Private
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Blanket
(   p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   p_api_version_number            IN  NUMBER := 1.0
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_header_Rec            IN  oe_blanket_pub.header_Rec_type :=
                                        oe_blanket_pub.G_MISS_header_Rec
,   p_line_tbl              IN  oe_blanket_pub.line_tbl_Type :=
                                        oe_blanket_pub.G_MISS_line_tbl
,   p_control_rec                   IN  oe_blanket_pub.Control_rec_type :=
                                oe_blanket_pub.G_MISS_CONTROL_REC
,   x_header_Rec           OUT NOCOPY oe_blanket_pub.header_Rec_type
,   x_line_tbl             OUT NOCOPY oe_blanket_pub.line_tbl_Type
);


END OE_Blanket_PVT;

/
