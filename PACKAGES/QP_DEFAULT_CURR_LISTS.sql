--------------------------------------------------------
--  DDL for Package QP_DEFAULT_CURR_LISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_CURR_LISTS" AUTHID CURRENT_USER AS
/* $Header: QPXDCURS.pls 120.1 2005/06/09 23:47:33 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
);

END QP_Default_Curr_Lists;

 

/
