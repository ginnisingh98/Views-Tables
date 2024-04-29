--------------------------------------------------------
--  DDL for Package QP_DEFAULT_CURR_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_CURR_DETAILS" AUTHID CURRENT_USER AS
/* $Header: QPXDCDTS.pls 120.1 2005/06/09 23:38:56 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_CURR_DETAILS_rec              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Rec_Type
);

END QP_Default_Curr_Details;

 

/
