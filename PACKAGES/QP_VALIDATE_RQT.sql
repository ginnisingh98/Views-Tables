--------------------------------------------------------
--  DDL for Package QP_VALIDATE_RQT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_RQT" AUTHID CURRENT_USER AS
/* $Header: QPXLRQTS.pls 120.1 2005/06/09 00:24:16 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_RQT_rec                       IN  QP_Attr_Map_PUB.Rqt_Rec_Type
,   p_old_RQT_rec                   IN  QP_Attr_Map_PUB.Rqt_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_RQT_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_RQT_rec                       IN  QP_Attr_Map_PUB.Rqt_Rec_Type
,   p_old_RQT_rec                   IN  QP_Attr_Map_PUB.Rqt_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_RQT_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_RQT_rec                       IN  QP_Attr_Map_PUB.Rqt_Rec_Type
);

END QP_Validate_Rqt;

 

/
