--------------------------------------------------------
--  DDL for Package CS_PARTYMERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_PARTYMERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: cssrpmns.pls 120.0 2005/12/22 15:52:28 spusegao noship $ */

PROCEDURE UPDATE_CS_DATA
     ( p_batch_id         IN   NUMBER,
       p_request_id       IN   NUMBER,
       x_return_status    OUT  NOCOPY VARCHAR2) ;

END  CS_PARTYMERGE_PKG;

 

/
