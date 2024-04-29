--------------------------------------------------------
--  DDL for Package OE_COMMITMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_COMMITMENT_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUCMTS.pls 120.0 2005/06/01 02:21:47 appldev noship $ */


----------------------------------------
-- Procedure Get_Commitment_Info
-- This procedure is provided to be called by OTA team.
-- Abstract: given a line id, return the
--           commitment id, number, start date and end date.
--           Return NULL if there is no commitment on the line.
---------------------------------------

PROCEDURE Get_Commitment_Info
(   p_line_id			IN 	NUMBER := FND_API.G_MISS_NUM
, x_commitment_id OUT NOCOPY NUMBER

, x_commitment_number OUT NOCOPY VARCHAR2

, x_commitment_start_date OUT NOCOPY DATE

, x_commitment_end_date OUT NOCOPY DATE

);



END OE_COMMITMENT_UTIL;

 

/
