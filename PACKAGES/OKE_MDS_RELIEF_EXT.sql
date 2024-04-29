--------------------------------------------------------
--  DDL for Package OKE_MDS_RELIEF_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_MDS_RELIEF_EXT" AUTHID CURRENT_USER AS
/* $Header: OKEXMRFS.pls 115.0 2002/12/04 08:45:19 alaw noship $ */

--
--  Name          : Relief_Demand
--  Pre-reqs      :
--  Function      : This function returns the cost of sales account
--                  for a given shipping delivery detail
--
--
--  Parameters    :
--  IN            : P_MDS_Rec               OKE_MDS_RELIEF_PKG.mds_rec_type
--
--  OUT           : None
--
--  Returns       : None
--

PROCEDURE Relief_Demand
( P_MDS_Rec                 IN          OKE_MDS_RELIEF_PKG.mds_rec_type
);

END OKE_MDS_RELIEF_EXT;

 

/
